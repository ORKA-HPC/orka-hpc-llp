//===------------------------- fpgapipelinemodel.js -----------------------===//
//
// FPGAPipelineModel computes the number clock cycles for an execution to
// finish.
//
//===----------------------------------------------------------------------===//
"use strict";
/**
 * @function FPGAPipelineModel represents the abstracted pipeline of the entire
 * system or a single function.
 * The hierarchy is:
 * FPGAPipelineModel = The entire system or a single function.
 * |-- FPGABlockNode = The a function, loop, block, or pipe.
 *     |-- FPGAPipelineStage = The individual pipeline stages to represent stall
 *                             enable, stall-free cluster, stallable instruction.
 *
 * Here's an example of a model with 2 blocks and 4 pipelines
 * [  function F ] -> [       F.B0       ]  ->  [       F.B1      ]
 *        |                  /     \                   /     \
 * [func_pipeline]->[pipeline0]->[pipeline1]->[pipeline2]->[pipeline3]
 *
 * Another object the model holds is the loop trip count. The loop trip count
 * stores the function name and FPGATripCountData. Each FPGATripCountData
 * corresponds to the trip count of a loop invocation instance. The model adds
 * a top level function loop with trip count 1 to pretend the function is
 * invoke once.
 * Say there's a nested loop:
 * void foo(...) {
 *   for (i=0; i<X; i++) {
 *     for (j=0; j<Y; j++) { ... }
 *     for (k=0; k<Z; k++) { ... }
 *   }
 * }
 * This will correspond to 2+2*X number of FPGATripCountData elements stored in a
 * tree structure.
 * 2 is from 1 function foo and for loop with induction variable i
 * 2*X is from 2 subloops where they have X number of invocation from their parent
 * loop
 *
 * Example usages:
 * 1) Run till finished
 *  var myModel = new FPGAPipelineModel();
 *  var simCycle = myModel.startRun();
 *
 * 2) Run incrementally
 *  var myModel = new FPGAPipelineModel();
 *  var simCycle = myModel.startRun(0);  // setup but do not run
 *  while(getUserInput() !== 'exit') {
 *    simCycle = myModel.runCycle(getInputBox());  // Run user specified # of cycles
 *  }
 */
var FPGAPipelineModel = function () {
    this.nodeList = []; // A flatten list of blocks and pipes
    this.functionList = []; // A fictious predecessor for first pipeline
    this.loopTripCount = {}; // function name : FPGATripCountData object
    this.loopLimiterList = [];
    this.cycle = 0; // The total number of clock cycles ran in the simulation
    // TODO: make this work for multiple functions
    this.getFirstBlock = function () {
        return this.functionList[0];
    };
    this.appendFunction = function (val) {
        if (val instanceof FPGABlockNode && val.isFunction()) {
            this.functionList.push(val);
        }
    };
    this.appendNode = function (val) {
        if (val instanceof FPGABlockNode && !val.isFunction()) {
            this.nodeList.push(val);
        }
    };
    this.setCallback = function (val) {
        for (let ni = 0; ni < this.nodeList.length; ni++) {
            this.nodeList[ni].callback = val;
        }
    };
    this.applyLimiterEnd = function () {
        for (let ni = 0; ni < this.nodeList.length; ni++) {
            let vBlock = this.nodeList[ni];
            for (let psi = 0; psi < vBlock.pipelineStages.length; psi++) {
                // Match which limiter end have the same block and pipeline stage
                for (let li = 0; li < this.loopLimiterList.length; li++) {
                    let vLimiter = this.loopLimiterList[li];
                    if (vLimiter.block === vBlock && vLimiter.stage === psi) {
                        let vPS = vBlock.pipelineStages[psi];
                        vPS.appendLimiterEnd(vLimiter);
                    }
                }
            }
        }
    };
    // flattenBlock is A DF traversal with adding pNodeList and recursively
    // add it's children to Nodelist. pParentHeaderID is ID of parent loop header.
    // Use 0 if this is top level loop.
    this.flattenBlock = function (pNodelist, pParentHeaderID) {
        let vLoopHeaderNode;
        for (let ni = 0; ni < pNodelist.length; ni++) {
            let vNode = pNodelist[ni];
            // Ignore runOnce block as I see that it runs in parallel as .start block
            if (vNode['name'].indexOf('.runOnce') > 0) {
                continue;
            }
            // Parse pipepline, II, interleaving for ease of type handling later
            let vPipelined = (vNode['pl'] === 'Yes') ? true : false;
            let vII = (vPipelined) ? parseInt(vNode['ii']) : 0;
            let vInterleaving = parseInt(vNode['mi']);
            if (isNaN(vInterleaving)) {
                vInterleaving = undefined;
            }
            let vNewBlockNode = new FPGABlockNode(vNode['id'], vNode['name'], // User friendely name, i.e. <#>X Partial unroll <name>
            vNode['type'], pParentHeaderID, parseInt(vNode['ll']), // loop layer
            parseInt(vNode['lt']), // latency
            vPipelined, // false for not pipelined
            vII, vInterleaving, (vNode['fo'] === 'Enabled') ? true : false, parseInt(vNode['br']), // branch register
            parseInt(vNode['tn']) // threshold delay
            );
            this.appendNode(vNewBlockNode); // Add itself first
            if (vNode.hasOwnProperty('children')) {
                // Get the ID if this is a nested loop header.
                if (vNewBlockNode.isLoop()) {
                    this.flattenBlock(vNode['children'], vNewBlockNode.id);
                    vLoopHeaderNode = vNewBlockNode;
                }
                // Store a list of children IDs as subloops instead of a list of
                // children nodes. Children will be used to store pipeline and
                // stallable nodes.
                for (let sli = 0; sli < vNode['children'].length; sli++) {
                    let vSubLoop = vNode['children'][sli];
                    vNewBlockNode.subloops.push(vSubLoop['id']);
                }
            }
            // Previous block was loop header. Header and latch are adjacent element 
            // in the list.
            else if (vLoopHeaderNode) {
                vLoopHeaderNode.setHeader(vLoopHeaderNode);
                vLoopHeaderNode.setLatch(vNewBlockNode);
                vNewBlockNode.setHeader(vLoopHeaderNode);
                vNewBlockNode.setLatch(vNewBlockNode);
                vLoopHeaderNode = undefined;
            }
        }
    };
    /**
     * @function flattenLoopAttrJSON converts the hierarchical loop attribute JSON to a
     * list for ease of look up to insert trip count and delays later.
     * loop_attrJSON is hierarchial list of nodes where the children nodes means subloop.
     * After flattening, the children are converted to subloops and contains the ID for
     * look up later.
     */
    this.flattenLoopAttrJSON = function (pFunctionName) {
        let vFuncNode;
        for (let fi = 0; fi < loop_attrJSON['nodes'].length; fi++) {
            vFuncNode = loop_attrJSON['nodes'][fi];
            // Find the function to add
            if (vFuncNode['name'] !== pFunctionName) {
                continue;
            }
            if (!vFuncNode.hasOwnProperty('children')) {
                continue;
            }
            // Top most block level have 0 for parent loop header ID
            this.flattenBlock(vFuncNode['children'], 0);
            // Add a fictitous function block
            let vFuncBlockNode = new FPGABlockNode(vFuncNode['id'], vFuncNode['name'], 'function', 0, // parent ID
            0, // loop layer
            1, // latency
            true, // pipelined
            1, // II
            1, // interleaving
            false, // fast orch
            0, // branch register
            0, // threshold delay
            0 // speculative iteration
            );
            this.appendFunction(vFuncBlockNode);
            break;
        }
    };
    // TODO: remove this once loop speculative iteration is part of loop_attrJSON
    this.populateSpeculation = function () {
        // Parses the loopsJSON and returns a map of loop name and speculative iteration
        function createLegacyLoopSpecMap() {
            // The loopsJSON is structure like user loop hierarchy
            let loopSpeculationDict = {};
            let loopsToVisitQueue = [];
            if (loopsJSON.hasOwnProperty('children')) {
                // Top most children is the function
                loopsJSON['children'].forEach(function (funcNode) {
                    if (funcNode.hasOwnProperty('children')) {
                        // Push all the highest level loop into the queue
                        funcNode['children'].forEach(function (loopNode) {
                            loopsToVisitQueue.push(loopNode);
                        });
                    }
                });
                while (loopsToVisitQueue.length > 0) {
                    let curLoop = loopsToVisitQueue.shift();
                    if (curLoop.data[0] !== "n/a") {
                        // Ignore non-real loop. Real loop would Pipeline is either "Yes" or "No"
                        loopSpeculationDict[curLoop.name] = curLoop.data[2];
                    }
                    if (curLoop.hasOwnProperty('children')) {
                        curLoop['children'].forEach(function (subloop) {
                            loopsToVisitQueue.push(subloop);
                        });
                    }
                }
            }
            return loopSpeculationDict;
        }
        // TODO: Port speculative iteration to loop_attrJSON
        let vLoopSpeculationDict = createLegacyLoopSpecMap();
        for (let ni = 0; ni < this.nodeList.length; ni++) {
            let vLoopNode = this.nodeList[ni];
            if (!vLoopNode.isLoop()) {
                continue;
            }
            if (vLoopSpeculationDict.hasOwnProperty(vLoopNode.name)) {
                let vSpeculation = parseInt(vLoopSpeculationDict[vLoopNode.name]);
                if (!isNaN(vSpeculation)) {
                    vLoopNode.speculation = vSpeculation;
                }
            }
        }
    };
    /**
     * @function createLoopLimiters creates implicit limiters (enforce II and
     * unpipelined loop) and explicit limiters for actual bottleneck
     */
    this.createLoopLimiters = function () {
        for (let ni = 0; ni < this.nodeList.length; ni++) {
            let vLimiter;
            let vLoopNode = this.nodeList[ni];
            if (vLoopNode.isLoop()) {
                // Create implicit unpipeline and II=1 loop limiter
                if (!vLoopNode.pipelined) {
                    vLimiter = vLoopNode.createUnpipelinedLoopLimiter();
                }
                else if (vLoopNode.initInterval === 1) {
                    vLimiter = vLoopNode.createImplicitLoopLimiter(vLoopNode.initInterval);
                }
                //TODO: Add other loop limiters
                if (vLimiter) {
                    vLoopNode.pipelineStages[0].setLimiter(vLimiter);
                    this.loopLimiterList.push(vLimiter);
                }
            }
        }
    };
    // createLoopTripCount returns a dictionary of subloops: key=loop name and 
    // value=FPGATripCount. It recursively gets the children list of each node and
    // create a dictionary.
    // pNodeList is list of block and loop that matches loop_attrJSON nodes.
    this.createLoopTripCount = function (pNodelist) {
        let vNewTCDict = {};
        for (let li = 0; li < pNodelist.length; li++) {
            let vLoopNode = pNodelist[li];
            // Only care about loop and ignore blocks
            if (vLoopNode['type'] === 'loop') {
                let vStatic;
                let vTripCountVal = parseInt(vLoopNode['tc']);
                // Trip value of 0 means compiler does not know the trip count at compile
                // time. It will be default to 1 to show a minimum of 1 iteration in the GUI.
                if (vTripCountVal === 0) {
                    vStatic = false;
                    vTripCountVal = 1;
                }
                else {
                    vStatic = true;
                }
                let vNewTCData = new FPGATripCountData(vLoopNode['name'], vTripCountVal, vStatic);
                // Add subloops trip count data. The amount of dictionary to add equals
                // to the trip count value.
                if (vLoopNode.hasOwnProperty('children')) {
                    let vSubloopTCDict = this.createLoopTripCount(vLoopNode['children']);
                    for (let i = 0; i < vTripCountVal; i++) {
                        vNewTCData.appendSubloopTripCount(vSubloopTCDict);
                    }
                }
                vNewTCDict[vLoopNode['name']] = vNewTCData;
            }
        }
        return vNewTCDict;
    };
    /**
     * @function initializeLoopTripCount parses loop_attrJSON and create trip count
     * object for all loops. All non-statically known trip count are set to 1.
     */
    this.initializeLoopTripCount = function (pFunctionName) {
        for (let fi = 0; fi < loop_attrJSON['nodes'].length; fi++) {
            let vFuncNode = loop_attrJSON['nodes'][fi];
            // Find the function to add
            if (vFuncNode['name'] !== pFunctionName) {
                continue;
            }
            if (!vFuncNode.hasOwnProperty('children')) {
                continue;
            }
            // Create a top most trip count node, that is the function with trip count 1
            // and it's static
            let vFuncName = pFunctionName;
            let vFuncTCData = new FPGATripCountData(vFuncName, 1, true);
            vFuncTCData.appendSubloopTripCount(this.createLoopTripCount(vFuncNode['children']));
            this.loopTripCount[vFuncName] = vFuncTCData;
            return;
        }
    };
    // Assigns each loop node with top level trip count data object
    this.assignTripCountToLoopNode = function (pFunctionName) {
        for (let i = 0; i < this.nodeList.length; i++) {
            let vNode = this.nodeList[i];
            if (vNode.isLoop()) {
                vNode.setTripCountData(this.loopTripCount[pFunctionName]);
            }
        }
    };
    /**
     * @function initializeData parses the JSON for static data and dynamic data from
     * emulator/simulator (in the future).
     * @param {string} pFunctionName is the name of the function which the sim engine
     * want to initialize the data for.
     */
    this.initializeData = function (pFunctionName) {
        // Converts the hierarchical loop structure into a flatten list
        this.flattenLoopAttrJSON(pFunctionName);
        // Speculative iteration is still in legacy loopsJSON
        this.populateSpeculation();
        // TODO: Create pipeline stages in each block and respective pipeline depth
        // Add block successors and predecessors for divergent paths.
        // TODO: Add limiters to loops
        // Initialize any non-statically trip count to 1 for all loop nodes and assign
        // the trip count to each loop node
        this.initializeLoopTripCount(pFunctionName);
        this.assignTripCountToLoopNode(pFunctionName);
    };
    this.launchOneThread = function () {
        let vFirstBlock = this.getFirstBlock();
        // 0th iteration, start cycle 0, real iteration
        let vFirstIteration = new FPGAIteration(vFirstBlock, 0, this.cycle, false, undefined);
        let vlastPipeline = vFirstBlock.getLastPipeline();
        vlastPipeline.shiftPipeline(vFirstIteration);
        vlastPipeline.computeData();
    };
    this.removeFirstThread = function () {
        let vFirstBlock = this.getFirstBlock();
        let vlastPipeline = vFirstBlock.getLastPipeline();
        vlastPipeline.shiftPipeline(undefined);
        vlastPipeline.computeData();
    };
    /**
     * @function startRun is the entry point of the program after all static and dynamic
     * data are initialized.
     * @param {integer} pStopCycle is an optional integer specifies the number of cycles
     * to run. Not specified means run till end. 0 means initialize but not run. Negative
     * number will result in an error.
     * @returns the cycle the simulation stopped at.
     */
    this.startRun = function (pStopCycle) {
        let vStopCycle;
        if (pStopCycle === undefined) {
            vStopCycle = -1;
        }
        else {
            if (pStopCycle < 0) {
                console.error('Error! Negative stop cycle not allowed');
            }
            vStopCycle = pStopCycle;
        }
        // Place a token at the predecessor of block0
        this.launchOneThread();
        // Do noting as specified to run zero cycles
        if (vStopCycle === 0) {
            return 0;
        }
        return this.runCycle(vStopCycle);
    };
    // Iterate through every block and every pipeline to check if it has at least
    // one thread
    this.hasThread = function () {
        for (let ni = 0; ni < this.nodeList.length; ni++) {
            let vBlock = this.nodeList[ni];
            for (let pli = 0; pli < vBlock.pipelineStages.length; pli++) {
                let vPL = vBlock.pipelineStages[pli];
                // Handle the last stage differently when it has an exit FIFO because the
                // intermediate iterations valid's are dropped by the loop orchestration in
                // last pipeline stage to avoid sending the to successor block.
                if (pli === vBlock.pipelineStages.length - 1 && vPL.hasFifo()) {
                    let vTotalOccupied = vPL.getTotalOccupied();
                    // Check 2 conditions: total occupied or check last pipeline index to make
                    // there is something that needs to be dropped but it's still in the pipeline
                    if (vPL.getTotalOccupied() || vPL.pipeline[vPL.depth - 1]) {
                        return true;
                    }
                }
                else {
                    if (vPL.getTotalOccupied()) {
                        return true;
                    }
                }
            }
        }
        return false;
    };
    /**
     * @function runCycle simulate the model for the specified number of cycle from where it
     * was previous left off. The prerequiste is startRun.
     * @param {integer} pStopCycle is an optional integer specified the number of clock
     * cycles to run the simulation. Not specified, zero and less means run till end.
     * @returns the cycle the simulation stopped at.
     */
    this.runCycle = function (pStopCycle) {
        let vStopCycle = (pStopCycle) ? this.cycle + pStopCycle : 0;
        // Start the execution at time 0 or continue as long as it a thread
        while (this.cycle === 0 || this.hasThread()) {
            // Early exit: user specified exit
            if (vStopCycle > 0 && this.cycle >= vStopCycle) {
                return this.cycle;
            }
            // Main engine steps
            // Evaluate all temporal nodes pipeline, buffer and busy
            for (let ni = this.nodeList.length - 1; ni >= 0; ni--) {
                this.nodeList[ni].evaluateTemporalPipelines();
            }
            // Shift all value in datapath forward by one
            for (let ni = this.nodeList.length - 1; ni >= 0; ni--) {
                this.nodeList[ni].shiftPipelineStages(this.cycle);
            }
            // Generate stall out to predecessors starting from the back
            for (let ni = this.nodeList.length - 1; ni >= 0; ni--) {
                this.nodeList[ni].generateStalls();
            }
            // Update valids and the concurrency in limiters
            for (let ni = 0; ni < this.nodeList.length; ni++) {
                this.nodeList[ni].generateValids(this.cycle);
            }
            if (this.cycle === 0) {
                this.removeFirstThread();
            }
            // TODO: deal with hangs, i.e. 2 consecutive iteration and have the same state
            this.cycle++;
        }
        return this.cycle;
    };
};
/**
 * @class FPGATripCountData holds the trip count for current loop and a tree
 * structure that contain the trip count for all it's subloops.
 * @param {string} pLoopName is the name of the loop header
 * @param {integer} pTripCount is the trip count of the loop
 * @param {boolean} pIsStatic means the trip count is static and cannot be changed
 */
var FPGATripCountData = function (pLoopName, pTripCount, pIsStatic) {
    if (pTripCount < 0) {
        console.error('Error! FPGATripCountData ' + pLoopName +
            ' have invalid trip count.');
    }
    this.loopName = pLoopName;
    this.tripCount = pTripCount;
    this.isStatic = pIsStatic;
    // The number of element equals to trip count of the loop. Undefined when this 
    // loop have no subloop.
    // Each element is a dictionary of name : FPGATripCountData
    // TODO: Add temporal pipeline name : Delay value
    this.tripCountNodes;
    this.getSubloopTripCount = function (pIterIndex, pSubloopName) {
        if (pIterIndex < this.tripCount) {
            if (this.tripCountNodes[pIterIndex].hasOwnProperty(pSubloopName)) {
                return this.tripCountNodes[pIterIndex][pSubloopName];
            }
        }
    };
    // Returns the first element if it's initialized since that's not going to be removed.
    this.getSubloopNameList = function () {
        if (this.tripCountNodes) {
            return Object.keys(this.tripCountNodes[0]);
        }
    };
    // Add a subloop to iteration index specified. It also initialize tripCountNodes
    // for the first time. It can only add iteration that is less than the tripCount.
    this.addSubloopTripCount = function (pSubloopTCData, pIterIndex) {
        // Simple error checks: Must be FPGATripCountData, cannot recursively add itself
        // index must be less than trip count
        if (pSubloopTCData instanceof FPGATripCountData &&
            pSubloopTCData !== this &&
            pIterIndex < this.tripCount) {
            // initialize the array for the first time
            if (this.tripCountNodes === undefined) {
                this.tripCountNodes = [];
            }
            // Save the information in a dictionary for each iteration index
            if (this.tripCountNodes[pIterIndex] === undefined) {
                this.tripCountNodes[pIterIndex] = {};
            }
            this.tripCountNodes[pIterIndex][pSubloopTCData.loopName] = pSubloopTCData;
        }
    };
    /**
     * @function appendSubloopTripCount adds the subloop trip count tree to the last
     * iteration element.
     * @param {*} pSubloopTCDict is a dictionary of FPGATripCount: key=loop name
     * value=FPGATripCount
     */
    this.appendSubloopTripCount = function (pSubloopTCDict) {
        let _this = this;
        let vLastIterIndex = (_this.tripCountNodes) ? _this.tripCountNodes.length : 0;
        Object.keys(pSubloopTCDict).forEach(function (vLoopName) {
            let vSubloopTCData = pSubloopTCDict[vLoopName];
            _this.addSubloopTripCount(vSubloopTCData, vLastIterIndex);
        });
    };
    // Returns a copy of tripCoundNodes of the given index. The copying is a done on the
    // entire tripCountNode tree.
    this.copyTripCountNodesIndex = function (pIndex) {
        if (pIndex < 0 || pIndex >= this.tripCountNodes.length) {
            return;
        }
        let vTCDict = this.tripCountNodes[pIndex];
        let vNewTCDict = {};
        Object.keys(vTCDict).forEach(function (vLoopName) {
            let vTCData = vTCDict[vLoopName];
            let vNewTC = new FPGATripCountData(vLoopName, vTCData.tripCount, vTCData.isStatic);
            vNewTCDict[vLoopName] = vNewTC;
            // Copy all subloop tripcount
            if (vTCData.tripCountNodes) {
                for (let iv = 0; iv < vTCData.tripCount; iv++) {
                    let vNewSubloopTCDict = vTCData.copyTripCountNodesIndex(iv);
                    vNewTC.appendSubloopTripCount(vNewSubloopTCDict);
                }
            }
        });
        return vNewTCDict;
    };
    /**
     * @function setTripCount sets tripcount member. The function updates subloops iteration
     * tree based on the new trip count number. If the new trip count value is less than
     * current one, it will remove any extra iteration such that the tripCountNodes list
     * length is same as new trip count value. If the new trip count value is greater than
     * the current tripcount value, the function copies the last iteration for all the
     * additional iteraions.
     * @param {integer} pLoopTripCoundVal defineds the trip count value. The value can be
     * 0 and any positive integer.
     */
    this.setTripCount = function (pLoopTripCoundVal) {
        // Cannot reinitialize if static. Skip initialize if its same value
        if (this.isStatic || this.tripCount === pLoopTripCoundVal || pLoopTripCoundVal < 0) {
            return;
        }
        // Trip count could be 0 even if tripCountNodes have 1 element
        let prevTripCountVal = (this.tripCount) ? this.tripCount : 1;
        this.tripCount = pLoopTripCoundVal;
        // Expand or delete subloops tripcount
        if (this.tripCountNodes) {
            // Expand the subloop trip count list. All new iteration element will
            // have a copy of last element of the subloop trip count tree.
            if (pLoopTripCoundVal > prevTripCountVal) {
                for (let iv = prevTripCountVal; iv < pLoopTripCoundVal; iv++) {
                    // Make a deep copy of the tripCountNodes[last element] and add it
                    // as new element
                    let vNewSubloopTC = this.copyTripCountNodesIndex(prevTripCountVal - 1);
                    this.appendSubloopTripCount(vNewSubloopTC);
                }
            }
            // delete extra elements at the end
            else {
                // do not remove element 0 even if trip count is 0
                if (pLoopTripCoundVal === 0) {
                    this.tripCountNodes.length = 1;
                }
                else {
                    this.tripCountNodes.length = pLoopTripCoundVal;
                }
            }
        }
    };
};
/* TODO: Add dynamic delay data */
/**
 * @class FPGAIteration is an object that holds information about a single valid
 * travelling through the pipeline. It contains information about the cycle it is
 * created, the start and end cycle which it enters and leaves a block.
 * The parent loop iteration information allows to find the trip count.
 * @param {object} pLoop is the loop block which the iteration original from.
 * @param {integer} pIterationIndex is the loop iteration index. Starts at 0.
 * @param {integer} pStartCycle is the original start cycle of the iteration.
 * @param {boolean} pIsSpeculation true to speculation, false otherwise.
 * @param {object } pParentLoopIter is FPGAIteration object that points to outer
 * loop iteration object. Undefined if this iteration is top most iteration.
 */
var FPGAIteration = function (pLoop, pIterationIndex, pStartCycle, pIsSpeculation, pParentLoopIter) {
    this.loop = pLoop;
    this.loopName = pLoop.name;
    this.iterationIndex = pIterationIndex; // Iteration index
    this.origStartCycle = pStartCycle;
    this.isSpeculation = pIsSpeculation;
    this.parentLoopIteration; // Parent loop iteration object
    if (pParentLoopIter instanceof FPGAIteration) {
        this.parentLoopIteration = pParentLoopIter;
    }
    // Captures the cycle when iteration enters and leaves a block
    this.startCycle = 0;
    this.endCycle = 0;
    this.exitBlockName = ''; // Name of the block which the iteration leaves
};
/**
 * @class FPGABlockNode is an object that holds the static information of a block.
 * @param {string} pName is the name of the block.
 * @param {integer} pID is the ID of the block.
 * @param {string} pType is either loop or bb.
 * @param {integer} pParentLoopID is the parent loop ID. 0 if this the outermost
 * loop.
 * @param {integer} pLayer is the integer for depth of the loop. 1 means outermost
 * loop.
 * @param {integer} pLatency latency of the block. Latency includes Exit FIFO read
 * latency, and so it is not the same as pipeline depth.
 * @param {boolean} pPipelined means if this block is pipelined or not.
 * @param {integer} pInitInterval is initiation interval. 0 when not pipelined.
 * @param {integer} pInterleaving only applicable for pipelined loop.
 * @param {boolean} pHyperflexOrch  means if the loop has hyperflex optimized loop
 * orchestration.
 * @param {integer} pBranchRegister can only be 0 or 1. 0 means no branch register.
 * @param {integer} pThresHoldDelay can only be 0 or 1. 1 means throttle the
 * initiation interval.
 * @param {integer} pSpeculation means number of speculative iterations the loop
 * uses to compute exit condition.
 */
var FPGABlockNode = function (pID, pName, pType, pParentLoopID, pLayer, pLatency, pPipelined, pInitInterval, pInterleaving, pHyperflexOrch, pBranchRegister, pThresHoldDelay, pSpeculation) {
    this.id = pID;
    this.name = pName;
    this.type = pType;
    this.parentLoopID = pParentLoopID;
    this.layer = pLayer;
    this.latency = pLatency;
    this.pipelined = pPipelined;
    this.initInterval = pInitInterval;
    this.interleaving = pInterleaving;
    this.hyperflexOrch = pHyperflexOrch;
    this.branchRegister = pBranchRegister;
    this.thresholdDelay = pThresHoldDelay;
    this.speculation = (pSpeculation !== undefined) ? pSpeculation : 0;
    this.header; // Use for nested loop
    this.latch; // Use for nested loop, especially for trip count is 0
    this.subloops = []; // List of subloop ID's
    // Only add forward edges, i.e. no self edge nor back edge
    this.predecessors = [];
    this.successors = [];
    // Trip count data points the outer loop trip count data to handle non-constant trip
    // counts on every invocation
    this.tripCountData;
    // For rendering engine usage:
    // Callback is the user defined function to get the iteration object when the
    // iteration object leaves the last pipeline stage in every block.
    this.callback = undefined;
    // Variables to keep the states during model execution and loop orchestration
    // List of physical pipeline and temporal pipeline stages
    this.pipelineStages = [];
    // A list of trip counts for invocation entered
    this.tripCountList = new Array(this.interleaving);
    // A list of number of iterations that has executed so far. Initialized to 0
    this.numIteration = new Array(this.interleaving);
    // A list of invocation to this loop from parent loop for tracking nested loop
    // interations in subloop
    this.invocation = new Array(this.interleaving);
    // initialize iteration count to mimic loop orchestration
    for (let tci = 0; tci < this.interleaving; tci++) {
        this.numIteration[tci] = 0;
    }
    this.isNestedLoop = function () { return (this.subloops.length > 0); };
    this.isFunction = function () { return (this.type === 'function'); };
    this.isLoop = function () { return (this.type === 'loop'); };
    this.isBlock = function () { return (this.type === 'bb'); };
    this.isHeader = function () { return (this.header === this); };
    this.isLatch = function () { return (this.latch === this); };
    this.getLastPipeline = function () {
        return this.pipelineStages[this.pipelineStages.length - 1];
    };
    this.getNumIteration = function (interleaveIndex) {
        return this.numIteration[interleaveIndex];
    };
    this.getTripCount = function (interleaveIndex) {
        return this.tripCountList[interleaveIndex];
    };
    this.isLoopFinished = function (interleaveIndex) {
        return (this.getNumIteration(interleaveIndex) >= this.getTripCount(interleaveIndex) + this.speculation);
    };
    this.getParentInvocation = function (interleaveIndex) {
        return this.invocation[interleaveIndex];
    };
    this.setHeader = function (val) {
        if (val instanceof FPGABlockNode) {
            this.header = val;
            return;
        }
        console.log('Warning. FPGABlockNode::setHeader() argument is not type FPGABlockNode');
    };
    this.setLatch = function (val) {
        if (val instanceof FPGABlockNode) {
            this.latch = val;
            return;
        }
        console.log('Warning. FPGABlockNode::setLatch() argument is not type FPGABlockNode');
    };
    this.setTripCountData = function (val) {
        if (val instanceof FPGATripCountData) {
            this.tripCountData = val;
            return;
        }
        console.log('Warning. FPGABlockNode::setTripCountData() argument is not type FPGATripCountData');
    };
    this.appendPipelineStage = function (val) {
        // Only add it is type FPGAPipelineStage
        if (val instanceof FPGAPipelineStage) {
            this.pipelineStages.push(val);
            return;
        }
        console.log('Warning. FPGABlockNode::appendPipelineStage() argument is not type FPGAPipelineStage');
    };
    this.appendPredecessor = function (val) {
        if (val instanceof FPGABlockNode) {
            this.predecessors.push(val);
            return;
        }
        console.log('Warning. FPGABlockNode::appendPredecessor() argument is not type FPGABlockNode');
    };
    this.appendSuccessor = function (val) {
        if (val instanceof FPGABlockNode) {
            this.successors.push(val);
            return;
        }
        console.log('Warning. FPGABlockNode::appendSuccessor() argument is not type FPGABlockNode');
    };
    this.incrNumIteration = function (interleaveIndex) {
        this.numIteration[interleaveIndex]++;
    };
    this.setNumIteration = function (val, interleaveIndex) {
        this.numIteration[interleaveIndex] = val;
    };
    this.setParentInvocation = function (val, interleaveIndex) {
        this.invocation[interleaveIndex] = val;
    };
    // create limiters for unpipelined loop. Unlike a pipelined loop, 
    // unpiplined one doesn't have II
    this.createUnpipelinedLoopLimiter = function () {
        // for a nested loop, limiter ends at the end of its latch block
        // for a single loop, limiter ends the the end of the current block.
        let endBlock = this.isNestedLoop() ? this.latch : this;
        let stage = endBlock.pipelineStages.length - 1;
        let index = endBlock.getLastPipeline().pipeline.length - 1;
        return new FPGALoopLimiter(endBlock, stage, index, 1, 1);
    };
    this.createImplicitLoopLimiter = function (pInitInterval) {
        if (pInitInterval <= 0) {
            console.error('Error! createImplicitLoopLimiter have invalid II.');
        }
        // II minus 1 because index starts at 0. The limiter endpoint is looking at
        // the last element before it exit the pipeline.
        return new FPGALoopLimiter(this, 0, pInitInterval - 1, 1, 1);
    };
    /**
     * @function getTripCountFor queries the trip count data to retrieve the trip counts
     * for the iteration.
     * @param {object} pIteration is the FPGAIteration object.
     */
    this.getTripCountFor = function (pIteration) {
        if (!pIteration instanceof FPGAIteration) {
            return;
        }
        // Push the entire loop structure to function invocation into a stack, then find
        // the trip count based on iteration index
        let vIterStack = [];
        vIterStack.push({ 'name': pIteration.loopName, 'index': pIteration.iterationIndex });
        let vParentIter = pIteration.parentLoopIteration;
        while (vParentIter) {
            vIterStack.push({ 'name': vParentIter.loopName, 'index': vParentIter.iterationIndex });
            vParentIter = vParentIter.parentLoopIteration;
        }
        let vTCData = this.tripCountData;
        let vCurrIterData = vIterStack.pop();
        let vCurrIterIndex = vCurrIterData['index'];
        // To figure out the trip, it needs the iteration index and subloop name
        while (vIterStack.length > 0) {
            vCurrIterData = vIterStack.pop();
            let vSubloopName = vCurrIterData['name'];
            vTCData = vTCData.getSubloopTripCount(vCurrIterIndex, vSubloopName);
            if (vTCData === undefined) {
                console.error('Error! FPGABlockNode::getTripCountFor iteration and trip count mismatch');
            }
            vCurrIterIndex = vCurrIterData['index'];
        }
        return vTCData.tripCount;
    };
    this.setLoopTripCount = function (pIteration, pInterleaveIndex) {
        let vTC = this.getTripCountFor(pIteration);
        this.tripCountList[pInterleaveIndex] = vTC;
    };
    // Shift temporal pipeline stages. Update busy asynchronously.
    this.evaluateTemporalPipelines = function () {
        for (let psi = this.pipelineStages.length - 1; psi >= 0; psi--) {
            let vPS = this.pipelineStages[psi];
            if (!vPS.temporal) {
                continue;
            }
            vPS.evalTemporalValues();
        }
    };
    // Generate stalls for each pipeline stage
    this.generateStalls = function () {
        // Compute stall on all stages
        for (let psi = this.pipelineStages.length - 1; psi >= 0; psi--) {
            let vPS = this.pipelineStages[psi];
            if (this.temporal) {
                continue;
            }
            if (psi === 0 && this.isLoop()) {
                // loop pipeline stage is also busy when it executing or
                // cannot accept any new invocation
                let vLoopLimiter = vPS.limiter;
                // loop allows a new iteration but is already executing the current one
                if (!vLoopLimiter.isFull() &&
                    this.getNumIteration(0) > 0 && !this.isLoopFinished(0)) {
                    vPS.busy = true;
                    continue;
                }
            }
            vPS.computeBusy();
        }
    };
    // Get value from predecessor and insert to the first pipeline stage. Shift all
    // subsequent pipeline stages.
    // When this block is a loop, the new data to be inserted is either a new outer
    // invocation or a continuation of current loop iteration.
    this.shiftPipelineStages = function (pCycle) {
        // Shift the rest of the pipeline stages
        if (this.pipelineStages.length > 1) {
            for (let psi = this.pipelineStages.length - 1; psi > 0; psi--) {
                let vPS = this.pipelineStages[psi];
                if (vPS.temporal) {
                    continue;
                }
                if (!vPS.isPipelineStalled()) {
                    let vLoopLimiter = vPS.limiter;
                    let vNewData = undefined;
                    if ((vLoopLimiter === undefined || !vLoopLimiter.isFull()) && !vPS.isPipelineFull()) {
                        vNewData = vPS.getPredecessorsData();
                    }
                    vPS.shiftPipeline(vNewData);
                }
            }
        }
        let vPS = this.pipelineStages[0]; // Get the first pipeline stage
        if (vPS.temporal) {
            return;
        }
        let vLoopLimiter = vPS.limiter;
        let vNewData = undefined;
        // Stall region or stall enable cluster and it's busy. That means pipeline is frozen
        if (!vPS.isPipelineStalled()) {
            // If this is a loop and the pipeline allows inserting a new iteration
            if (this.isLoop()) {
                let vNextIteration = undefined;
                // Insert a bubble if loop limiter is full
                if (!vLoopLimiter.isFull() && !vPS.isPipelineFull()) {
                    // A loop can allow a new iteration under 2 prioritized scenarios when the
                    // limiter is not full. This matches with hardware mux where it prioritize
                    // backedge before new invocation.
                    // 1) Insert the next iteration, i.e. current invocation is not done and
                    //    the loop can accept next current iteration.
                    // 2) Insert a new outer iteration, i.e. allows interleaving or current
                    //    invocation have finished.
                    // TODO: Handle interleaving, currently I only consider 1st outer iterations
                    // TODO: Handle trip count = 0, need to skip everything
                    let vNextIterNum = this.getNumIteration(0);
                    if (vNextIterNum > 0 && // loop have been invoked
                        !this.isLoopFinished(0) && // loop is not finish
                        vLoopLimiter.acceptNextIteration()) {
                        // insert a new self iteration, aka backedge if did not finish execution
                        // speculative iterations 
                        let vSpeculation = (vNextIterNum >= this.getTripCount(0)) ? true : false;
                        vNextIteration = new FPGAIteration(this, vNextIterNum, pCycle, vSpeculation, this.getParentInvocation(0));
                        this.incrNumIteration(0);
                    }
                    else if (vLoopLimiter.acceptNewInvocation()) {
                        // first pipeline stage valid in
                        let vNewOuterIter = this.pipelineStages[0].getPredecessorsData();
                        // Generate a new invocation if outer loop have an invocation ready.
                        // Otherwise insert a bubble if no outer invocation available.
                        if (vNewOuterIter) {
                            // The first iteration is 0th, start on this cycle, not speculative, set parent invocation
                            vNextIteration = new FPGAIteration(this, 0, pCycle, false, vNewOuterIter);
                            // Save outer-iteration at interleaving slot 0 for later use
                            this.setParentInvocation(vNewOuterIter, 0);
                            // Save trip count and number of iterations to slot 0
                            this.setLoopTripCount(vNextIteration, 0);
                            this.setNumIteration(1, 0); // reset the iteration number to 1
                        }
                    }
                }
                if (vNextIteration) {
                    vNextIteration.startCycle = pCycle;
                }
                // Shift in next iteration to first pipeline
                vNewData = vNextIteration;
            }
            else {
                // For non-loop block, get the predecessor data and shift
                // No limiter or limiter is not full means it can get the next predecessor
                if ((vLoopLimiter === undefined || !vLoopLimiter.isFull()) && !vPS.isPipelineFull()) {
                    vNewData = vPS.getPredecessorsData();
                }
                if (vNewData) {
                    vNewData.startCycle = pCycle;
                }
                ;
            }
            // shift in first data to first pipeline
            vPS.shiftPipeline(vNewData);
        }
    };
    // Updates valid for all pipeline stages
    this.generateValids = function (pCycle) {
        // Generate valids for all stages except for the last one
        if (this.pipelineStages.length > 1) {
            for (let psi = 0; psi < this.pipelineStages.length - 1; psi++) {
                let vPS = this.pipelineStages[psi];
                if (vPS.temporal) {
                    continue;
                }
                if (!vPS.isPipelineStalled()) {
                    vPS.computeData();
                }
            }
        }
        let vLastPS = this.getLastPipeline();
        if (vLastPS.isPipelineStalled()) {
            return;
        }
        let vIter = vLastPS.tempBuffer;
        // Visualization tracking and loop exit condition handling
        if (vIter) {
            // This is a valid iteration that just finished
            // Captures exit block name and end cycle + 1 since tmp buffer represents data in
            // the next clock cycle
            if (this.callback) {
                vIter.exitBlockName = this.name;
                vIter.endCycle = pCycle + 1;
                this.callback(vIter);
            }
            // Drop intermediate iterations and speculative for most inner loop and
            // for loop latch. Only send 1 valid after loop finishes.
            // Drop speculative iterations for nested loop header to avoid invocating
            // fake inner loop iterations.
            if ((this.isLoop() && !this.isNestedLoop()) ||
                (this.isBlock() && this.isLatch())) {
                // This is a loop latch of most inner loop or latch of nested loop
                // Only generate a vaid to predecessor when loop finishes
                let vLoopHeader = (this.isBlock()) ? this.header : this;
                // Do not set valid if this iteration is speculation or not the last iteration
                // Minus 1 is due to iteration starts at 0.
                if (vIter.isSpeculation ||
                    (vIter.iterationIndex < vLoopHeader.getTripCount(0) - 1)) {
                    vLastPS.tempBuffer = undefined;
                }
                else { // Loop finishes, pass back the outer iteration
                    vLastPS.tempBuffer = vIter.parentLoopIteration;
                }
            }
            else if (this.isNestedLoop() && this.isLoop() && vIter.isSpeculation) {
                // Nested loop header, drop speculation
                vLastPS.tempBuffer = undefined;
            }
        }
        // Propagate the valid to next block if this is just a regular block or the loop
        // has finished execution
        if (vLastPS.temporal) {
            return;
        }
        vLastPS.computeData();
    };
};
/**
 * @class FPGAPipelineStage holds the state of the pipeline in the simulation
 * model.
 * @param {integer} pDepth is the depth of the pipeline, value must be greater than
 * zero.
 * @param {integer} pNumberRegister is number of registers at the output data path.
 * @param {boolean} pTemporal is true if this pipeline is a models a valid shift in
 * time. False to represent a physical pipeline stage.
 * @param {integer} pFifoDepth is the fifo depth. A value of 0 means there's no sfc
 * in the current pipelineStage.
 * @param {integer} pFifoLatency is the latency of the fifo
 */
var FPGAPipelineStage = function (pDepth, pNumRegister, pTemporal, pFifoDepth, pFifoLatency) {
    if (pDepth <= 0 && !pTemporal || pDepth < 0) {
        console.error('Error! FPGAPipelineStage::constructor with invalid depth');
        return;
    }
    if (pFifoDepth < 0 || pFifoDepth < pFifoLatency) {
        console.error('Error! FPGAPipelineStage::constructor with invalid fifo parameter');
        return;
    }
    this.depth = pDepth; // Pipeline depth
    this.pipeline = new Array(this.depth);
    this.numRegister = pNumRegister; // Number of output registers to the next block
    this.outputRegister = new Array(this.numRegister);
    this.temporal = pTemporal;
    this.busy = false; // Stall out to predecessor
    this.data = undefined; // Valid out to successor
    this.fifoDepth = pFifoDepth;
    this.fifoLatency = pFifoLatency;
    this.predecessors = [];
    this.successors = [];
    this.numOccupied = 0; // Number of valids occupied
    // temp buffer holds the last element of pipeline after shift to avoid race condition
    // between the pipeline stages in the simulator
    this.tempBuffer = undefined;
    // A limiter determines how many concurrent iteration can enter into the region.
    // Each loop block must have a limiter in 0th pipeline stage. 
    this.limiter = undefined;
    // Limiter end list defines limiters that have endpoints in the is pipeline
    this.limiterEndList = [];
    // TODO support 0 latency fifo 
    if (this.fifoLatency > 0) {
        this.latencyFifo = new Array(this.fifoLatency);
    }
    this.dataFifo = [];
    this.numDataInLatFifo = 0;
    this.hasFifo = function () { return (this.fifoDepth > 0); };
    // get total number of valid data (#valid data in the pipeline + #valid data in 
    // consume registers)
    this.getTotalOccupied = function () {
        let vOccupied = 0;
        // if the successor is not stalling, the data will be poped from datafifo in the
        // cycle as it was pushed into the datafifo. After this cycle, dataFifo will have
        // length-1 since data is sitting at this.data now. We need to add this valid data
        // Similar mechanism if this has a branch register
        if (this.hasFifo() || this.numRegister) {
            vOccupied = (this.data) ? vOccupied + 1 : vOccupied;
        }
        if (this.numRegister) {
            this.outputRegister.forEach(function (reg) {
                if (reg !== undefined) {
                    vOccupied++;
                }
            });
        }
        return vOccupied + this.getNumOccupied();
    };
    // Get the number of valid data in the pipeline (# of valid data in flight and # of valid data 
    // in the exit fifo).
    this.getNumOccupied = function () {
        return this.dataFifo.length + this.numDataInLatFifo + this.numOccupied;
    };
    // Act like full detector for sfc. A full detector is a counter that keeps track 
    // of number of valid data in the pipeline (data in flight and data in exit fifo). 
    // If number of valid data equals the fifo depth, it signals pipeline full.
    this.isPipelineFull = function () {
        if (this.hasFifo()) {
            return this.getNumOccupied() >= this.fifoDepth;
        }
        return false;
    };
    this.isPipelineValid = function (index) {
        if (index >= this.depth) {
            console.error('Error! isPipelineValid() index out of bounds');
        }
        return (this.pipeline[index] !== undefined);
    };
    this.appendPredecessor = function (val) {
        if (val instanceof FPGAPipelineStage) {
            this.predecessors.push(val);
        }
    };
    this.appendSuccessor = function (val) {
        if (val instanceof FPGAPipelineStage) {
            this.successors.push(val);
        }
    };
    this.setLimiter = function (val) {
        if (val instanceof FPGALoopLimiter) {
            this.limiter = val;
            return;
        }
        console.log('Warning. FPGABlockNode::setLimiter() argument is not type FPGALoopLimiter');
    };
    this.appendLimiterEnd = function (val) {
        if (val instanceof FPGALoopLimiter) {
            this.limiterEndList.push(val);
            return;
        }
        console.log('Warning. FPGABlockNode::appendLimiterEnd() argument is not type FPGALoopLimiter');
    };
    this.getSuccessorBusy = function () {
        if (this.successors.length) {
            // TODO: Handle divergent path by logical OR all successor's busy
            return this.successors[0].busy;
        }
        return false;
    };
    // Returns a valid data if valid and not stall. Otherwise returns undefined to mimic
    // injecting a bubble.
    this.getPredecessorsData = function () {
        let vPredData = undefined;
        if (this.predecessors.length) {
            // TODO: Handle divergent path
            vPredData = this.predecessors[0].data;
        }
        // Returns the predecessor data if it is valid data and not stall.
        return (vPredData && !this.busy) ? vPredData : undefined;
    };
    // The pipeline is stalled if no Fifo and successor is busy
    // No Fifo implies this pipeline is either stall-region or stall-enable cluster
    this.isPipelineStalled = function () {
        return (!this.hasFifo() && this.getSuccessorBusy());
    };
    this.isLimiterII1 = function () {
        return (this.limiter.block.pipelineStages[this.limiter.stage] === this &&
            this.limiter.index === 0);
    };
    // Shift only temporal pipelines. Temporal pipeline only allows a single
    // thread to be in the pipeline. The valid can still propagate through the
    // model pipeline even when successor busy because this is just a model for time.
    // As soon as a valid instruction enters into the pipeline, it will assert busy
    // predecessor to avoid iteration leaving the predecessor data. Then only 
    // deasserts the busy when it reaches to the end.
    this.evalTemporalValues = function () {
        // Do nothing if it's a physical pipeline
        if (!this.temporal) {
            return;
        }
        // Do no shifting if the data from previous iteration have not been shifted out
        let vInBusy = this.getSuccessorBusy();
        if (this.numOccupied && this.data && vInBusy) {
            return;
        }
        let vNewData = undefined;
        // Try to take a new piece of data when there's nothing in the pipeline
        if (this.numOccupied === 0) {
            // Clear any previous busy first in order to take a new data and all
            // previous states
            this.busy = false;
            this.data = undefined;
            vNewData = this.getPredecessorsData();
            // Nothing in the pipeline and no new data came in
            if (vNewData === undefined)
                return;
        }
        // TODO: Change the pipeline depth based on the iteration of vNewData
        // Depth 0 means assert the valid right away for the successor
        // Set temp buffer to nothing so that it gets clear during computeData
        if (this.depth === 0) {
            this.tempBuffer = vNewData;
            this.data = vNewData;
            this.busy = false;
            return;
        }
        // Do not shift if there's something in the pipeline that wasn't shift out
        if (!this.data) {
            // Shift in new data and shift out previous data. Note here that that the
            // valid is shifted independent of successor busy. It's designed this way such
            // that it masks the any stall in successor while waiting.
            // data uses the pop so the depth of the pipeline equals the number clock cycles.
            // temp buffer is set only when the data can be absorb in this iteration for
            // tracking purpose in generate valid for cases where a temporal pipeline is the
            // last node in the block.
            this.pipeline.unshift(vNewData);
            this.data = this.pipeline.pop();
        }
        // Compute occupancy, increment when there's new data
        // Decrement only when there's data and successor not busy, i.e. ready to absorb the
        // valid. When the successor is not ready to take this data, it holds the data in the
        // temp buffer to save the state to avoid any shifting
        if (vNewData) {
            this.numOccupied++;
        }
        // Valid not stall means it will be read by the next pipeline
        if (this.data && !vInBusy) {
            this.numOccupied--;
        }
        // Temporal pipeline busy behaviour: busy as soon as it one thread until it reaches
        // to the end and it's ready to shifted by successor
        this.busy = (this.numOccupied) ? true : false;
    };
    // Set the busy flag when there's a limiter and the limiter is full.
    // For stall-enable and stall region, the busy is same as successor busy.
    this.computeBusy = function () {
        if (this.temporal) {
            return;
        }
        // Set busy to true if there's a limiter and it's full
        if (this.limiter && this.limiter.isFull()) {
            this.busy = true;
            return;
        }
        let vInBusy = this.getSuccessorBusy();
        // model the full detector behavior. 
        if (this.hasFifo()) {
            this.busy = this.isPipelineFull();
        }
        else {
            this.busy = vInBusy; // No Exit FIFO means busy propagate from input to output
        }
    };
    // Add element to the beginning of the pipeline.
    // Value is expects either a FPGAIteration object or undefined to mimic bubble
    this.shiftPipeline = function (pNewData) {
        if (this.temporal) {
            return;
        }
        // Shift in new data and shift out previous data
        if (pNewData) {
            this.numOccupied++;
        }
        this.pipeline.unshift(pNewData);
        let validPop = this.pipeline.pop();
        // Update the temp buffer to last value for the next iteration
        this.tempBuffer = this.pipeline[this.pipeline.length - 1];
        // if this pipeline stage contains a fifo, the value tempBuffer holds will 
        // be shiftd to the latency fifo. The same Iteration object will be sitting 
        // at the last position of the pipelinestages and in the latency fifo.
        // In this case, we want to decrement the numOccupied a clock cycle earlier.      
        if ((!this.hasFifo() && validPop) ||
            (this.hasFifo() && this.tempBuffer)) {
            this.numOccupied--;
        }
        // Dequeue limiter that has an end in this pipeline
        for (let li = 0; li < this.limiterEndList.length; li++) {
            let vLimiter = this.limiterEndList[li];
            // 2 cases: limiter within the same pipeline or limiter across 2 pipelines
            // When the start and end are the same pipeline, shift guareentees the next
            // iteration will also be shift out the exiting. So it's safe to decrement
            // the occupancy to allow the next iteration to enter in the next cycle.
            // When the start and end are on the different pipeline, we checked if there
            // was a previous iteration saved first.
            if ((vLimiter === this.limiter && vLimiter.getLimiterEnd()) ||
                vLimiter.saveLeavingIteration()) {
                vLimiter.decrNumOccupied();
            }
        }
        // Enqueue any limiter
        if (this.limiter) {
            // For II=1 limiter, do not increment since decrement floors at zero
            if (!this.isLimiterII1() && this.isPipelineValid(0)) {
                this.limiter.incrNumOccupied();
            }
        }
    };
    // Sets the data when the last element in the pipeline is being shifted out
    this.computeData = function () {
        if (this.temporal) {
            return;
        }
        // Either push data into Exit Fifo, or set branch register, or data
        let vTempData;
        if (this.hasFifo()) {
            // data is pushed into latencyFifo first to mimic the latency of the
            // exit fifo. After #latency cycles, valid data will be pushed to  
            // dataFifo and is ready to be read. 
            this.latencyFifo.unshift(this.tempBuffer);
            if (this.tempBuffer)
                this.numDataInLatFifo++;
            let vTempOut = this.latencyFifo.pop();
            if (vTempOut) {
                this.numDataInLatFifo--;
                this.dataFifo.push(vTempOut);
            }
            if (this.numDataInLatFifo < 0 || this.numDataInLatFifo > this.fifoLatency)
                console.error('Error! numDataInLatFifo is wrong');
            if (this.dataFifo.length > 0 && !this.getSuccessorBusy()) {
                vTempData = this.dataFifo.shift();
            }
        }
        else {
            // stall region or stall enable cluster, busy means pipeline is frozen
            vTempData = this.tempBuffer;
        }
        // Add Branch register for stall-valid protocol
        if (this.numRegister > 0) {
            this.outputRegister.unshift(vTempData);
            vTempData = this.outputRegister.pop();
        }
        this.data = vTempData;
    };
};
/**
 * @class FPGALoopLimiter determines if next iteration can enter into the loop.
 * In our model, we do not have cases where concurrency and interleaving are
 * both greater than 1.
 * Note, for most inner loop with data dep, this is same as II
 * @param {object} pBlock is a the first of a tuple (block, stage, end) that represent
 * the pipeline endpoint of the limiter. As in, when valid reached to the endpoint,
 * the number of occupied decrements.
 * @param {integer} pStage is the index for which pipeline stage for the push
 * @param {integer} pIndex is the index for in the stage for the push. Use -1 for
 * handy method to the temp buffer (aka the last element of a pipeline)
 * @param {integer} pConcurrency is the maximum number of self iterations allowed.
 * Minimum number is 1.
 * @param {integer} pInterleaving is the maximum number of outer iterations allowed.
 * Minimum number is 1.
 */
var FPGALoopLimiter = function (pBlock, pStage, pIndex, pConcurrency, pInterleaving) {
    // Basic error checking
    if (!pBlock instanceof FPGABlockNode || pStage < 0 ||
        pIndex < -1 || pConcurrency <= 0 || pInterleaving <= 0) {
        console.error('Error! FPGALoopLimiter have invalid parameters');
    }
    this.block = pBlock;
    this.stage = pStage;
    this.index = pIndex;
    this.concurrency = pConcurrency;
    this.interleaving = pInterleaving;
    // Variables for state keeping
    this.numOccupied = 0; // Total number of valids in the limiter region
    this.previousValid; // The valid iteration for limiter across 2 different pipelines
    if (this.concurrency > 1 && this.interleaving > 1) {
        console.error('Error! Loop has a limiter with concurrency and interleaving both greater than 1.');
    }
    this.incrNumOccupied = function () {
        // avoid overflow
        if (!this.isFull()) {
            this.numOccupied++;
        }
    };
    this.decrNumOccupied = function () {
        // avoid underflow
        if (this.numOccupied > 0) {
            this.numOccupied--;
        }
    };
    this.isFull = function () {
        return (this.numOccupied >= this.concurrency * this.interleaving);
    };
    this.acceptNextIteration = function () {
        return (this.numOccupied < this.concurrency);
    };
    this.acceptNewInvocation = function () {
        return (this.numOccupied < this.interleaving);
    };
    // Determine if this valid is going to leave the pipeline. 
    this.getLimiterEnd = function () {
        let vPipeStage = this.block.pipelineStages[this.stage];
        if (this.index >= 0) {
            return vPipeStage.pipeline[this.index];
        }
        return vPipeStage.tempBuffer;
    };
    // Save the outgoing iteration
    // Return true if there's a valid previous iteration
    this.saveLeavingIteration = function () {
        // curr = 0 + prev = 0 --> do nothing, return 0
        // curr = 0 + prev = 1 --> shift out, update and return 1
        // curr = 1 + prev = 1 --> shift out, update and return 1
        // curr = 1 + prev = 0 --> shift in, update and return 0
        let vSucceed = this.previousValid;
        this.previousValid = (this.getLimiterEnd()) ? true : false;
        return vSucceed;
    };
};
