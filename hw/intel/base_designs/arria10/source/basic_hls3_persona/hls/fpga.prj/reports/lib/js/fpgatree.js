"use strict";
// disable JSHint warning: Use the function form of "use strict".
// This warning is meant to prevent problems when concatenating scripts that
// aren't strict, but we shouldn't have any of those anyway.
/* jshint -W097 */
/**
 * @class FPGASummaryTree renders the different summary subsection in summary pane
 * @param {*} pDiv is the parent div which the summary tree is append to
 */
var FPGASummaryTree = function (pDiv) {
    this.div = pDiv;
    this.id = 'summaryList';
    this.name = 'Summary Content'; // Name in the card header
    this.systemNode = createTreeNode('Top', 0, 1, 'system'); // no checkbox; expanded
    // ChildName is the the string to display in the tree
    // ID is the element ID of the DIV which onclick will scroll to
    this.appendChild = function (pChildName, pID) {
        AddChildNode(this.systemNode, createTreeNode(pChildName, 0, 1, '', pID));
    };
    this.draw = function () {
        var vTree = new FPGATree(this.id + 'Tree');
        vTree.treeSource = this.systemNode;
        vTree.clickCallback = scrollToDiv;
        createCard(this.div, this.id, this.name, 'tree', null);
        vTree.drawTree(document.getElementById(this.id + 'Body')); // add the tree to the body
    };
    // private function for to smooth scroll to div when click
    function scrollToDiv(data) {
        var parent = $('#report-summary');
        var elem = $('#' + data.node.data.id);
        scrollToElement(elem, parent);
    }
};
/**
 * @class FPGAAreaTree renders the navigation tree and at kernel/component level
 * @param {} pDiv
 */
var FPGAAreaTree = function (pDiv) {
    this.div = pDiv;
    this.id = 'areaList';
    this.name = 'System'; // Name in the card header
    this.systemNode = null; // pointer to the tree
    this.draw = function () {
        if (this.systemNode === null) {
            // parse the JSON for the first time
            this.systemNode = createTreeNode(areaJSON['name'], 0, 1, 'system', areaJSON['name']);
            let _this = this;
            areaJSON['children'].forEach(function (glbObj) {
                let vGlobalNode = createTreeNode(glbObj['name'], 0, 1, glbObj['type'], glbObj['name']);
                AddChildNode(_this.systemNode, vGlobalNode);
            });
        }
        // add tree
        var vTree = new FPGATree(this.id + 'Tree');
        vTree.treeSource = [this.systemNode]; // include the system node
        vTree.clickCallback = scrollToDiv;
        createCard(this.div, this.id, this.name, 'tree', null);
        vTree.drawTree(document.getElementById(this.id + 'Body')); // add the tree to the body
    };
    function scrollToDiv(data) {
        var parent = $('#report-area');
        var elem = $('#' + data.node.data.id);
        scrollToElement(elem, parent, 40); // 40 is height of the sticky header
    }
};
/**
 * @class FPGALoopTree renders the navigation tree to show real and optimized loop
 * @param {*} pDiv is the parent div which the loop tree is append to
 */
var FPGALoopTree = function (pDiv) {
    this.div = pDiv;
    this.id = 'loopsList';
    this.name = 'Loop List';
    this.tree;
    this.loopNestHasTypes = null; // A dict key=parent type, value = Set of children types, children of children included
    this.subloopParentTypes = null; // A dict key=child type, value = Set of parents types, parent of parent
    this.source = loopsJSON;
    this.getOriginalParentLine = function (pLoopDetails) {
        for (let i = 0; i < pLoopDetails.length; i++) {
            let d = pLoopDetails[i];
            let vOrigLineExp = /Original parent is at line:\s(\d+)/;
            let m = d['text'].match(vOrigLineExp);
            if (m)
                return m[1];
        }
        return 0;
    };
    this.getLoopType = function (pLoopName, pFuncName) {
        if (pLoopName === 'Fully unrolled loop') {
            return 'loop_fully_unroll';
        }
        else if (pLoopName.indexOf(': ' + pFuncName) !== -1) {
            let typeExp = /^(\S+):\s/; // kernel or component
            let m = pLoopName.match(typeExp);
            if (m)
                return m[1];
        }
        else if (pLoopName.indexOf(pFuncName + '.B') !== -1) {
            return 'loop';
        }
        else if (pLoopName === 'Fused subloop') { // Loop that got fused
            return 'loop_fused';
        }
        return 'loop_coalesced';
    };
    this.addSubLoop = function (pLoop, pParentNode, pFuncName) {
        let vLoopName = pLoop['name'];
        let vType = this.getLoopType(vLoopName, pFuncName);
        let vCaption;
        let vLocation = getFirstDebug(pLoop);
        if (vLocation) {
            if (vLocation['line']) {
                let vDebugLocElement = createDebugLocation(vLocation);
                vDebugLocElement.innerHTML = "(" + vDebugLocElement.innerHTML + ")";
                vCaption = vDebugLocElement.outerHTML;
            }
            else {
                vCaption = '(' + vLocation['filename'] + ')';
            }
        }
        let vCurNode = createTreeNode(vLoopName, 0, 1, vType, 0, vLocation, vCaption); // the tree does not need multiple
        let vTypeSet = new Set([vType]);
        AddChildNode(pParentNode, vCurNode);
        let vLoopHasOriginalParentDict = {}; // key based on line # of original parent, value is a list subloops
        if (pLoop.hasOwnProperty('children') && Array.isArray(pLoop['children'])) {
            for (let ci = 0; ci < pLoop['children'].length; ci++) {
                // Ignore children with orignal parent
                let vSubloop = pLoop['children'][ci];
                let originalParentLine = 0;
                if (vSubloop.hasOwnProperty('details'))
                    originalParentLine = this.getOriginalParentLine(vSubloop['details']);
                if (!originalParentLine) {
                    let subloopTypes = this.addSubLoop(vSubloop, vCurNode, pFuncName);
                    subloopTypes.forEach(function (t) { vTypeSet.add(t); });
                }
                else {
                    // create a list of loops with original parent - defer traversal
                    if (!vLoopHasOriginalParentDict.hasOwnProperty(originalParentLine))
                        vLoopHasOriginalParentDict[originalParentLine] = [];
                    vLoopHasOriginalParentDict[originalParentLine].push(vSubloop);
                }
            }
            // Iterate all the children again, one of them must be the original parent
            for (let ci = 0; ci < vCurNode['children'].length; ci++) {
                let vSubloopNode = vCurNode['children'][ci];
                let vSubloopLine = vSubloopNode['debug']['line'];
                if (vLoopHasOriginalParentDict.hasOwnProperty(vSubloopLine)) {
                    for (let i = 0; i < vLoopHasOriginalParentDict[vSubloopLine].length; i++) {
                        let vOriginalSubloop = vLoopHasOriginalParentDict[vSubloopLine][i];
                        let subloopTypes = this.addSubLoop(vOriginalSubloop, vSubloopNode, pFuncName);
                        subloopTypes.forEach(function (t) { vTypeSet.add(t); });
                    }
                }
            }
        }
        return vTypeSet;
    };
    this.buildChildParentMap = function (pParentNode, pTypeSubloopMap, pSubloopParentMap) {
        // BFS for subloop-parent map
        // DFS for parent-subloop map
        if (pParentNode['children'].length) {
            let pParentType = pParentNode['type'];
            for (let ci = 0; ci < pParentNode['children'].length; ci++) {
                let pCurNode = pParentNode['children'][ci];
                let pCurType = pCurNode['type'];
                if (!pSubloopParentMap.hasOwnProperty(pCurType))
                    pSubloopParentMap[pCurType] = new Set();
                pSubloopParentMap[pCurType].add(pParentType);
                if (pSubloopParentMap.hasOwnProperty(pParentType))
                    pSubloopParentMap[pParentType].forEach(function (p) { pSubloopParentMap[pCurType].add(p); });
            }
            for (let ci = 0; ci < pParentNode['children'].length; ci++) {
                let pCurNode = pParentNode['children'][ci];
                this.buildChildParentMap(pCurNode, pTypeSubloopMap, pSubloopParentMap);
            }
            if (!pTypeSubloopMap.hasOwnProperty(pParentType))
                pTypeSubloopMap[pParentType] = new Set();
            for (let ci = 0; ci < pParentNode['children'].length; ci++) {
                let pCurNode = pParentNode['children'][ci];
                let pCurType = pCurNode['type'];
                pTypeSubloopMap[pParentType].add(pCurType);
                if (pTypeSubloopMap.hasOwnProperty(pCurType))
                    pTypeSubloopMap[pCurType].forEach(function (s) { pTypeSubloopMap[pParentType].add(s); });
            }
        }
    };
    /**
     * @function draw adds a table of loop attributes
     */
    this.draw = function () {
        this.treeID = this.id + 'Tree';
        this.tree = new FPGATree(this.treeID);
        this.tree.setAttributeMap({ 'Loops': 'loop',
            'Coalesced Inner Loops': 'loop_coalesced',
            'Fused Inner Loops': 'loop_fused',
            'Fully Unrolled Loops': 'loop_fully_unroll' });
        // Icons needed: system (like class), kernel (function), loops
        var vTopName = (product === PRODUCTS.HLS) ? 'System' : 'Kernel System';
        var vSystemNode = createTreeNode(vTopName, 0, 1, 'system');
        var vSystemLoopTypes = new Set(); // All possible loop types found in the design
        if (this.source.hasOwnProperty('children') && Array.isArray(this.source['children'])) {
            let _this = this;
            this.source['children'].forEach(function (func) {
                // Example: "Kernel: write_kernel" --> want "write_kernel"
                let funcName = func['name'].substring(func['name'].indexOf(': ') + 2);
                _this.addSubLoop(func, vSystemNode, funcName).forEach(function (loopType) {
                    vSystemLoopTypes.add(loopType);
                });
            });
        }
        this.loopNestHasTypes = {};
        this.subloopParentTypes = {};
        this.buildChildParentMap(vSystemNode, this.loopNestHasTypes, this.subloopParentTypes);
        // Don't include Kernel or Component in the selection list
        // TODO: We should sort it alphabetically or define some fix order
        let vAttrMap = this.tree.attrSelectionMap;
        let vSelectionList = Object.keys(vAttrMap).filter(function (typeLabel) {
            let loopType = vAttrMap[typeLabel];
            if (vSystemLoopTypes.has(loopType))
                return true;
            return false;
        });
        this.tree.setSelections.apply(this.tree, vSelectionList);
        this.tree.treeSource = [vSystemNode]; // Put in a list if we want system shows up in the tree
        this.tree.redrawCallback = this.updateLoopTree;
        createCard(this.div, this.id, this.name, 'tree', null);
        this.tree.drawFilterButton(document.getElementById(this.id), this);
        this.tree.drawTree(document.getElementById(this.id + 'Body')); // add the tree to the body
    };
    /**
     * @function updateLoopTree changes the selected checkbox value and re-renders the tree
     * @param {*} event is the click event on the checkbox
     * @param {*} pLoopTreeObj is the FPGALoopTree itself to get dependency
     */
    this.updateLoopTree = function (event, pLoopTreeObj) {
        var $target = $(event.currentTarget), eventLoopType = $target.attr('data-value');
        // Note: 'this' equals to FPGATree object, not FPGALoopTree object
        // Preprocess step:  Iterate through the entire selections in the filter list and find all the uncheckboxes
        // Compare each unchecked item against all checked ones for displaying dependencies
        // Two corner cases:
        //  1) When deselecting, ...
        //  2) When selecting, the selectedList hasn't updated to include the newly selected one
        let vAttrMap = pLoopTreeObj.tree.attrSelectionMap;
        var checkBoxes = document.getElementById(pLoopTreeObj.treeID + 'Filter').getElementsByTagName('input');
        let vPrevSelectedList = pLoopTreeObj.tree.selectedList;
        let vPreviousSelected = pLoopTreeObj.tree.hasSelected(eventLoopType);
        let vCheckBoxIndex = 0;
        pLoopTreeObj.tree.selections.forEach(function (item, i) {
            let vLoopType = vAttrMap[item];
            if (vLoopType === eventLoopType)
                vCheckBoxIndex = i;
            if (checkBoxes[i]['checked'] && vLoopType !== eventLoopType)
                return; // ignored checked box that is not from this event
            // If the event one is in the selected list, this means this was due to unchecking
            // compare the dependencies against the event, all the other unchecked boxes now the dependency doesnt exist b/c of the event
            if (vPreviousSelected && // the action here is unselected
                (pLoopTreeObj.loopNestHasTypes.hasOwnProperty(vLoopType) && pLoopTreeObj.loopNestHasTypes[vLoopType].has(eventLoopType)) ||
                (pLoopTreeObj.subloopParentTypes.hasOwnProperty(vLoopType) && pLoopTreeObj.subloopParentTypes[vLoopType].has(eventLoopType))) {
                checkBoxes[i]['indeterminate'] = false; // now I can remove the dependency
                return;
            }
            // Compare the newly checked one against only possible parent loop dependency
            if (!vPreviousSelected &&
                (pLoopTreeObj.subloopParentTypes.hasOwnProperty(eventLoopType) && pLoopTreeObj.subloopParentTypes[eventLoopType].has(vLoopType))) {
                checkBoxes[i]['indeterminate'] = true;
                return;
            }
            //no dependencies
            checkBoxes[i]['indeterminate'] = false;
        });
        // Update selected event checkbox
        if (vPreviousSelected) { // Unchecking
            pLoopTreeObj.tree.removeSelected(eventLoopType); // Update the previous selected list
            let found = 0; // Compare the remaining selected against event loop, can only uncheck if does not have any subloop of dependency
            for (let i = 0; i < pLoopTreeObj.tree.selectedList.length; i++) {
                if (pLoopTreeObj.loopNestHasTypes.hasOwnProperty(eventLoopType) && pLoopTreeObj.loopNestHasTypes[eventLoopType].has(vPrevSelectedList[i])) {
                    found = 1;
                    break;
                }
            }
            if (found)
                setTimeout(function () { checkBoxes[vCheckBoxIndex]['indeterminate'] = true; }, 0);
            else
                setTimeout(function () {
                    checkBoxes[vCheckBoxIndex]['indeterminate'] = false;
                    checkBoxes[vCheckBoxIndex]['checked'] = false;
                }, 0);
        }
        else { // Checking
            pLoopTreeObj.tree.appendSelected(eventLoopType);
            setTimeout(function () {
                checkBoxes[vCheckBoxIndex]['indeterminate'] = false;
                checkBoxes[vCheckBoxIndex]['checked'] = true;
            }, 0);
        }
        // Filter tree by node type, always keep system, kernel or component
        let pLoopTree = this.getTree();
        pLoopTree.filterNodes(function (node) {
            if (node.data.type === 'system' || node.data.type === 'Kernel' || node.data.type === 'Component')
                return true;
            else if (vPrevSelectedList.indexOf(node.data.type) > -1)
                return true;
            else
                return false;
        });
    };
};
/**
 * @class FPGABottleneckTree creates navigation tree for bottlenecks
 * @param {*} pDiv is the parent div which the bottleneck tree is append to
 */
var fpgaSelectedBottleneckIDs = []; // store the source of bottleneck as that's unique
var FPGABottleneckTree = function (pDiv) {
    this.div = pDiv;
    this.id = 'bottleneck';
    this.name = 'Bottlenecks'; // Bottleneck in throughput, future add area
    this.tree = null;
    // create an empty card
    createCard(this.div, this.id, this.name, 'tree', null);
    // when click the bottleneck
    function clickBottleneckNode(pBottleneckTreeData) {
        // TODO: support system
        // TODO: handle explanation for throughput bottlenecks and no bottlenecks
        let formattedDetails = 'No info';
        let vNodeData = pBottleneckTreeData.node.data;
        if (vNodeData.hasOwnProperty('id')) {
            let vIndex = parseInt(vNodeData['id'].substring(4));
            formattedDetails = getHTMLDetailsFromJSON(bottleneckJSON['bottlenecks'][vIndex]['details']);
        }
        changeDivContent(0, formattedDetails);
    }
    // when select the bottleneck - only for schedule viewer
    function selectBottleneckNode(event, pBottleneckTreeData) {
        // Check if checkbox is clicked by first getting the current selected
        let vCurrSelBottlenecks = {};
        pBottleneckTreeData.tree.getSelectedNodes().forEach(function (n) {
            if (n.data.type === 'Occupancy limiter' || n.data.type === 'fMAX/II') {
                vCurrSelBottlenecks[n.data.id] = 1;
            }
        });
        // Compare the checked boxes against what was previously checked
        // remove bottleneck limiter that's not part of current selected
        let vNewSelected = true;
        for (let bi = 0; bi < fpgaSelectedBottleneckIDs.length; bi++) {
            let n = fpgaSelectedBottleneckIDs[bi];
            if (!vCurrSelBottlenecks.hasOwnProperty(n['id'])) {
                removeBottleneck(n);
                fpgaSelectedBottleneckIDs.splice(bi, 1);
                vNewSelected = false;
                break;
            }
        }
        if (vNewSelected) {
            let vNodeData = pBottleneckTreeData.node.data;
            if (vNodeData.hasOwnProperty('id')) {
                let vIndex = parseInt(vNodeData['id'].substring(4));
                let vSchBottleneck = addBottleneck(bottleneckJSON['bottlenecks'][vIndex]);
                vSchBottleneck['id'] = vNodeData['id'];
                fpgaSelectedBottleneckIDs.push(vSchBottleneck);
            }
        }
        redrawSchedule();
    }
    // There are two modes in the draw function
    // pNodeName: "" or none means system level where it just show the number of bottleneck
    // under each the kernel. Otherwise it will show only the name of bottleneck.
    this.draw = function (pTreeData, pCheckBox) {
        let vCheckBox = (typeof pCheckBox != "undefined" && pCheckBox) ? true : false;
        let vTopNode = createTreeNode('Throughput bottlenecks', 0, 1, 'system');
        let vBottleneckList = bottleneckJSON['bottlenecks'];
        // Extract the function name out of loop name
        function getFunctionName(pLoopName) {
            // Some loop name contains extra user friendly string, i.e. "4X Partially unrolled vector_dot.B2"
            let vLastIndex = pLoopName.lastIndexOf(' ');
            if (vLastIndex < 0) {
                vLastIndex = 0;
            }
            else {
                vLastIndex++; // Get the next character
            }
            return pLoopName.substring(vLastIndex, pLoopName.indexOf('.'));
        }
        if (!pTreeData.hasOwnProperty('message') && pTreeData !== "") {
            let vFoundBottleneck = false;
            let vNodeData = pTreeData.node.data;
            let vRealNodeName = getRealName(vNodeData.name);
            let vFunctionDict = {}; // key=function name, value tree node
            if (vNodeData.type === 'system') {
                // When someone click the system, first add an extra level for function scope
                if (loop_attrJSON.hasOwnProperty('nodes')) {
                    loop_attrJSON['nodes'].forEach(function (vFuncObj) {
                        let vFuncName = vFuncObj['name'];
                        vFunctionDict[vFuncName] = createTreeNode(vFuncName, 0, 1, 'function');
                        AddChildNode(vTopNode, vFunctionDict[vFuncName]);
                    });
                }
            }
            // find the bottleneck matching the node name
            for (let i = 0; i < vBottleneckList.length; i++) {
                let vBottleneck = vBottleneckList[i];
                let vLoopName = vBottleneck['loop'];
                let vFuncName = getFunctionName(vLoopName);
                if (vNodeData.type === 'system') {
                    // add the bottleneck under the function
                    if (vFunctionDict.hasOwnProperty(vFuncName)) {
                        AddChildNode(vFunctionDict[vFuncName], createTreeNode(vBottleneck['name'], vCheckBox, 1, vBottleneck['type'], 'idx=' + i, '', '(in ' + vBottleneck['loop'] + ')'));
                    }
                    else {
                        console.log("Function not found: " + vFuncName);
                    }
                }
                else if (vNodeData.name === vLoopName || vRealNodeName === vLoopName || vRealNodeName === vFuncName) {
                    // Match function name and or loop name to output the bottlenecks under that scope
                    // caption in which loop. id can't be 0 and so prefix with idx=
                    AddChildNode(vTopNode, createTreeNode(vBottleneck['name'], vCheckBox, 1, vBottleneck['type'], 'idx=' + i, '', '(in ' + vBottleneck['loop'] + ')'));
                }
                vFoundBottleneck = true;
            }
            if (!vFoundBottleneck)
                vTopNode = createTreeNode('No bottlenecks', 0, 1, 'system'); // dummy node
        }
        else if (pTreeData['message']) { // nothing is clicked
            vTopNode = createTreeNode(pTreeData['message'], 0, 1, 'system');
        }
        else { // not supported
            vTopNode = createTreeNode('This viewer cannot provide bottleneck information', 0, 1, 'system');
        }
        if (this.tree === null) {
            // initialize a new tree for the first time
            this.tree = new FPGATree(this.id + 'Tree');
            this.tree.showCheckbox = true;
            this.tree.clickCallback = clickBottleneckNode; // render details callback
            this.tree.selectCallback = selectBottleneckNode;
            this.tree.treeSource = [vTopNode]; // add the source
            this.tree.drawTree(document.getElementById(this.id + 'Body')); // add the tree to the body
        }
        else {
            this.tree.treeSource = [vTopNode]; // add the source
            this.tree.reLoadTree();
        }
    };
};
/**
 * @class FPGASystemViewerTree is the entry point to draw system viewer
 * navigation tree.
 * @param {object} pDiv is the html div where the tree will be added to.
 * @param {string} pName is the name to be display on the top of navigation.
 * @param {string} pTopName is the name of the highest level node.
 */
var FPGASystemViewerTree = function (pDiv, pName, pTopName) {
    this.div = pDiv;
    this.id = 'systemList';
    this.name = pName;
    this.tree;
    this.source = treeJSON;
    this.topName = pTopName;
    this.addChildren = function (pParentNode, pChildrenList) {
        for (let ci = 0; ci < pChildrenList.length; ci++) {
            let vChild = pChildrenList[ci];
            let vChildNode = createTreeNode(vChild['name'], 0, 1, vChild['type'], vChild['id']);
            if (vChild.hasOwnProperty('children')) {
                this.addChildren(vChildNode, vChild['children']);
            }
            AddChildNode(pParentNode, vChildNode);
        }
    };
    /**
     * @funciton draw renders the navigation tree using fancy tree library.
     * @param {boolean} pFunctionOnly only adds the function to the system when set to
     * true. False means adds all hierarchies in the tree.
     * @param {boolean} pGlobalMemory adds global memory to the tree when set to true.
     * False means no global memory is added.
     */
    this.draw = function (pFunctionOnly, pGlobalMemory) {
        let vSystemNode = null;
        if (this.source.hasOwnProperty('nodes')) {
            // Build a tree from system, function, block, cluster
            vSystemNode = createTreeNode(this.topName, 0, 1, 'system');
            // Add global memory node for OpenCL/SYCL when trying to get all hierarchy
            if (pGlobalMemory && !pFunctionOnly) {
                // TODO: Add global memory to treeJSON instead of using mavJSON
                let vMavNodes = mavJSON['nodes'];
                if (vMavNodes) {
                    let vGlbMemNode;
                    for (let ni = 0; ni < vMavNodes.length; ni++) {
                        if (vMavNodes[ni]['type'] === 'memtype') {
                            vGlbMemNode = createTreeNode('Global memory', 0, 1, 'memory');
                            break;
                        }
                    }
                    if (vGlbMemNode) {
                        vMavNodes.filter(function (memNode) {
                            return (memNode['type'] === 'memtype');
                        }).forEach(function (memNode) {
                            memNode['children'].forEach(function (curr_memsys) {
                                let vMemName = curr_memsys['name'];
                                AddChildNode(vGlbMemNode, createTreeNode(vMemName, 0, 1, 'memsys'));
                            });
                        });
                        AddChildNode(vSystemNode, vGlbMemNode);
                    }
                }
            }
            for (let ci = 0; ci < this.source['nodes'].length; ci++) {
                let vChild = this.source['nodes'][ci];
                let vChildNode = createTreeNode(vChild['name'], 0, 1, vChild['type'], vChild['id']);
                // Add all hierarchies below the function
                if (!pFunctionOnly && vChild.hasOwnProperty('children')) {
                    this.addChildren(vChildNode, vChild['children']);
                }
                AddChildNode(vSystemNode, vChildNode);
            }
        }
        // Disable tree if data is not valid, i.e. no tree would mean empty data
        if (vSystemNode) {
            createCard(this.div, this.id, this.name, 'tree', null);
            this.tree = new FPGATree(this.id + 'Tree');
            // TODO: Add filter capability on the tree for global, memory, block
            // Put in a list if we want system shows up in the tree and add the tree to the body
            this.tree.treeSource = [vSystemNode];
            this.tree.drawTree(document.getElementById(this.id + 'Body'));
        }
        else {
            let vEmptySystem = newFPGAElement(null, 'P', null, undefined, 'Empty kernel system');
            createCard(this.div, this.id, this.name, 'tree', vEmptySystem);
        }
    };
    /**
     * @function renderSystemGraph invokes FPGAGVGraph to render a graph based on the
     * the node selected by user.
     * @param {object} data is a FPGATree node.
     */
    this.renderSystemGraph = function (data) {
        // Keep going to parent to get the entire hierarchy
        function getTitle(pNode) {
            let vCurrNode = pNode;
            let vTitle = vCurrNode.data.name;
            if (vCurrNode.data.type === 'system')
                return vTitle;
            while (vCurrNode.data.type !== 'system') {
                vCurrNode = vCurrNode.parent;
                if (vCurrNode.hasOwnProperty('data')) {
                    vTitle = vCurrNode.data.name + ' > ' + vTitle;
                }
            }
            return vTitle;
        }
        let vNodeData = data.node.data;
        let vTitle = getTitle(data.node);
        $("#GVG").parent().find(".currentEntity").text(": " + vTitle);
        let gv_graph = new FPGAGVGraph(vNodeData);
        gv_graph.draw('#GVG');
    };
    /**
     * @function renderScheduleChart invokes renderScheduleBeta to render a gantt
     * chart rendering to show the static schedule of every instructions.
     * @param {object} data is a FPGATree node.
     */
    this.renderScheduleChart = function (data) {
        let vNodeData = data.node.data;
        // clicked a function
        let source = scheduleJSON[vNodeData.id];
        let treeData = data;
        // Simple error check
        if (source === undefined) {
            source = { 'message': 'No graph available' };
            treeData['message'] = 'Click on ' + function_prefix + ' list to see bottleneck information';
        }
        renderScheduleBeta(source, vNodeData.id);
        // Only show the bottleneck associated with the function
        vBottleneckTree.draw(treeData, true);
    };
};
/**
 * @function FPGATree is a wrapper around library fancytree with an additional add-on
 * with a filter dropdown.
 * @param {string} pID is the ID use for tree.
 */
var FPGATree = function (pID) {
    this.id = pID;
    // Tree controls
    this.treeDiv = null;
    this.treeSource = null;
    this.clickCallback = null; // Callback when a node is clicked
    this.selectCallback = null; // Callback when showCheckbox
    this.showCheckbox = 0;
    this.showIcon = false;
    // Filter controls
    this.selections = null; // The list of items to be shown for different filter or
    // sorting option
    this.attrSelectionMap = null;
    this.selectedList = null; // The list of selected items (a subset of selections)
    this.redrawCallback = null; // The callback used click. The callback needs 2 
    // arguments: value from type, input for .prop('checked')
    this.showFilter = 0; // Have a filter button
    //TODO: this.showRadio = 0;   // radio button
    this.getTree = function () { return $(this.treeDiv).fancytree("getTree"); };
    // Returns true if value was previously selected
    this.hasSelected = function (val) { return (this.selectedList.indexOf(val) !== -1); };
    this.removeSelected = function (val) {
        let idx;
        if ((idx = this.selectedList.indexOf(val)) !== -1)
            this.selectedList.splice(idx, 1);
    };
    this.appendSelected = function (val) {
        if (this.selectedList.indexOf(val) === -1)
            this.selectedList.push(val); // don't add duplicate
    };
    this.setSelections = function () {
        this.selections = new Array();
        for (var i = 0; i < arguments.length; i++) {
            this.selections.push(arguments[i]);
        }
    };
    this.setAttributeMap = function (val) {
        this.attrSelectionMap = {};
        if (!(typeof val === "object"))
            return;
        for (var key in val) {
            this.attrSelectionMap[key] = val[key];
        }
    };
    this.drawFilterButton = function (pDiv, pArg) {
        // Add list to dropdown ID
        // Button (div)
        //  |__ Button (button)
        //  |__ Filter (div)
        let vTmpGroup = newFPGAElement(pDiv, 'div', 'btn-group float-right', this.id + 'Button');
        let vTmpDiv = newFPGAElement(vTmpGroup, 'button', 'btn btn-default btn-sm dropdown-toggle');
        vTmpDiv.setAttribute("data-toggle", "dropdown");
        newFPGAElement(vTmpDiv, 'span', 'body glyphicon', 0, '&#xe138;');
        newFPGAElement(vTmpDiv, 'span', 'caret');
        // If no loop to show, disable the button and return
        if (!Array.isArray(this.selections) || this.selections.length == 0) {
            vTmpDiv.setAttribute("disabled", "true");
            return;
        }
        let vFilterID = this.id + 'Filter';
        vTmpDiv = newFPGAElement(vTmpGroup, 'div', 'dropdown-menu dropdown-menu-right', vFilterID);
        // Populate the dropdown
        if (!this.selectedList) { // Start with everything checked if selected list is empty
            this.selectedList = [];
            for (let si = 0; si < this.selections.length; si++) {
                let item = this.selections[si];
                let attr = this.attrSelectionMap[item];
                this.selectedList.push(attr);
                let vItemDiv = newFPGAElement(vTmpDiv, 'li');
                vItemDiv = newFPGAElement(vItemDiv, 'a', 'small', 0);
                vItemDiv.href = '#';
                vItemDiv.setAttribute('data-value', attr);
                vItemDiv.setAttribute('tabIndex', -1);
                let vCBDiv = newFPGAElement(vItemDiv, 'input', '');
                vCBDiv.setAttribute('type', 'checkbox');
                vCBDiv.setAttribute('checked', true);
                vItemDiv.insertAdjacentHTML('beforeend', '&nbsp;' + item);
            }
        }
        // TODO: Only check the ones user wants to initialize
        var _this = this;
        // Bind the checkbox click event to callback
        if (!_this.redrawCallback)
            _this.redrawCallback = function (event) { console.log('Default filter click.'); };
        $('#' + vFilterID + ' a').on('click', function (event) {
            _this.redrawCallback(event, pArg);
        });
    };
    /**
     * @function drawTree initialize fancytree library to render a navigation tree in the div
     * @param {object} pDiv is the HTML div object which fancytree will populate
     */
    this.drawTree = function (pDiv) {
        if (!pDiv)
            return;
        this.treeDiv = pDiv;
        if (this.clickCallback === null) {
            this.clickCallback = function (data) { console.log('Default: Click=' + data.node.data.name + ' Type=' + data.node.data.type); }; // only for debugging purpose
        }
        var _this = this;
        // invoke fancy tree with settings commonly used in FPGA
        let vFancyTreeParams = {
            extensions: ["filter"],
            checkbox: _this.showCheckbox,
            selectMode: 3,
            source: _this.treeSource,
            icon: _this.showIcon,
            clickFolderMode: 3,
            filter: {
                fuzzy: false,
                nodata: false,
                mode: "hide" // Remove unmatched nodes (use "dimm" to grey them out instead)
            },
            // Bind the click action
            click: function (event, data) { _this.clickCallback(data); }
        };
        // TODO: if (pPreprocessCallback) initalize the tree w/ beforeActivate:
        if (this.selectCallback) {
            vFancyTreeParams['select'] = this.selectCallback;
        }
        $(this.treeDiv).fancytree(vFancyTreeParams);
        this.treeDiv.firstChild.id = this.id;
        // Add connectors to fancytree
        $(".fancytree-container").addClass("fancytree-connectors");
        $('#' + this.id).css('height', '100%');
    };
    this.reLoadTree = function () {
        this.getTree().reload(this.treeSource);
    };
};
// === Utility functions ===
/**
 *
 * @param {string} pName is the name shown in the tree
 * @param {boolean} pCheckBox means 1 to show a checkbox. 0 to hide checkbox
 * @param {boolean} pExpand means 1 the default is expand its children
 * @param {string} pType is value use for filtering or passing simple data around.
 * Use 0 or '' for not use.
 * @param {string} pID is value unique value for linking in the report
 * @param {*} pLocation is the optional argument for debug location
 * { filename:<string>, line:<int> }
 * @param {string} pCaption is the optional argument that can be appended to title
 * @param {string} pIcon is an optional argument that defines location of the icon
 * @param {*} pChildren is an optional argument to add children
 */
function createTreeNode(pName, pCheckBox, pExpand, pType, pID, pLocation, pCaption, pIcon, pChildren) {
    var treeNode = {};
    treeNode['name'] = pName;
    treeNode['title'] = document.createTextNode(pName).data;
    let vLocation = (pLocation) ? pLocation : null;
    if (vLocation)
        treeNode['debug'] = vLocation;
    if (pCaption)
        treeNode['title'] += '&nbsp;' + pCaption;
    if (pType)
        treeNode['type'] = pType;
    if (pID)
        treeNode['id'] = pID;
    treeNode['hideCheckbox'] = !pCheckBox; // old verion is hide (inverted)
    treeNode['expanded'] = pExpand;
    if (pIcon)
        treeNode['icon'] = pIcon;
    treeNode['children'] = [];
    if (pChildren !== undefined && pChildren !== null && Array.isArray(pChildren) && pChildren.lenght > 0) {
        for (let c = 0; c < pChildren.length; c++) {
            this.vChildren.push(pChildren[ci]);
        }
    }
    return treeNode;
}
/**
 * @function AddchildNode appends child tree node into parent.
 * @param {*} pParent is the parent tree node
 * @param {*} pChild is the child tree node
 */
function AddChildNode(pParent, pChild) {
    pParent['children'].push(pChild);
}
if (typeof exports == "object" && typeof module != "undefined") {
    module.exports = {
        'FPGABottleneckTree': FPGABottleneckTree
    };
}
