"use strict";
if (!Object.entries)
    Object.entries = function (obj) {
        var ownProps = Object.keys(obj), i = ownProps.length, resArray = new Array(i); // preallocate the Array
        while (i--)
            resArray[i] = [ownProps[i], obj[ownProps[i]]];
        return resArray;
    };
// Global variable:
// Commonly used by HLD report
var loopIDSaved;
// To be cleared out upon updateTripCountTree is called
var loopDataNodes; // a list of blocks used gantt chart
var loopDataNodesPassedInSaved;
var invocationMap;
var gantt_chart;
var top_node_id;
var func_node_id;
var verificationMode;
var debugMode;
var maxCycle;
var outerMostLoopNodesList;
var taskNodePairsWithTripCounts;
var tripCountNodeMap;
// Show color by type variable
var loopsViewerColorTypeDict = {
    'bb': "#003C71",
    'cluster': "#0071C5",
    'inst': "#00AEEF",
    'limiterBlock': "#FFA300",
    'speculation': 'gtaskpink',
    'regular': 'gtaskblue',
    'register': 'gtasklightblue',
    'iteration': 'gtaskpurple',
    'nested_iteration': 'gtaskpurple',
};
function updateTripCountTree() {
    console.log("Update button!");
    let loopNodeIDTripCountPairs = [];
    for (let i = 0; i < taskNodePairsWithTripCounts.length; i++) {
        let taskNodePair = taskNodePairsWithTripCounts[i];
        let loopNode = getNodeFromArray(taskNodePair.node_copy.loop_node_id, loopDataNodes);
        let tripCount = taskNodePair.task.getTripCount();
        if (debugMode) {
            console.log("\n\nName: " + taskNodePair.node_copy.name);
            console.log("NodeCopy ID: " + taskNodePair.node_copy.id);
            console.log("Original Loop ID: " + taskNodePair.node_copy.loop_node_id);
            console.log("Original Loop Name: " + loopNode.name);
            console.log("Trip Count: " + tripCount);
        }
        let loopNodeIDTripCountPair = {};
        loopNodeIDTripCountPair["loop_node_id"] = taskNodePair.node_copy.loop_node_id;
        loopNodeIDTripCountPair["trip_count"] = tripCount;
        loopNodeIDTripCountPairs.push(loopNodeIDTripCountPair);
    }
    // Keep loopNodeIDTripCountPair, delete 
    // everything else and call renderLoopVis again
    loopDataNodes = undefined;
    loopDataNodesPassedInSaved = undefined;
    invocationMap = undefined;
    gantt_chart = undefined;
    outerMostLoopNodesList = undefined;
    taskNodePairsWithTripCounts = undefined;
    tripCountNodeMap = undefined;
    top_node_id = undefined;
    func_node_id = undefined;
    ;
    renderLoopVis(loopNodeIDTripCountPairs, loopIDSaved, verificationMode, invocationMap, loopDataNodesPassedInSaved);
}
// Create zoom level list. The list value represent each clock cycle divison, i.e. 4 means four clock cycle per column
// Each zoom level is double the other one
function createGanttZoomList(latency) {
    var zoomLevelList = new Array(1);
    var curZoom = 1;
    while (curZoom * 16 < latency) {
        curZoom *= 2;
        if (curZoom > latency) {
            zoomLevelList.push(latency);
        }
        else {
            zoomLevelList.push(curZoom);
        }
    }
    return zoomLevelList;
}
function createTask(node, parentID) {
    let debugCreateTask = false;
    // Create new bar
    let nodeColor = (loopsViewerColorTypeDict.hasOwnProperty(node.type)) ? loopsViewerColorTypeDict[node.type] : 'ggroupblack';
    // TODO: Possible feature, different shades per loop level
    //if (node.ll > 0) {
    //  nodeColor = nodeColor + parseInt(node.hierarchy).toString(10);
    //}
    let group;
    if ((node.type === 'iteration' || node.type === 'loop_latch' ||
        node.type === 'regular' || node.type === 'speculation')) {
        if (shouldRegisterBranch(node)) {
            group = 2;
        }
        else {
            group = 0;
        }
    }
    else {
        group = 1;
    }
    //TODO let nodeDetails = getDetails(node);
    //TODO let nodeDebug   = (hasDebug(node)) ? getFirstDebug(node) : null;
    if (debugCreateTask && debugMode)
        console.log("Adding: " + node.name + ", own ID is: " + node.id + ", parentID is: " + parentID + ", start: " + node.start + ", end: " + node.end);
    // Some basic error checking and hack for now
    if (node.hasOwnProperty("start") && node.hasOwnProperty("end")) {
        if (isNaN(node.start) || isNaN(node.end)) {
            if (debugCreateTask && debugMode)
                console.log("Error! Data error: start cycle or latency is not a number: " + node.name);
            return; // don't add to avoid crashing
        }
        node.start = parseInt(node.start);
        node.end = parseInt(node.end);
        if (node.start === node.end && node.start != -1) {
            // Temporary workaround by setting the latency to 1/2 clock cycle
            node.end = node.start + 0.5;
        }
    }
    else {
        if (debugCreateTask && debugMode)
            console.log("Warning! Node has no start and end " + node.name);
        return; // don't add
    }
    if (node.hasOwnProperty('id')) {
        node.id = parseInt(node.id);
    }
    else {
        if (debugCreateTask && debugMode)
            console.log("Warning! Node has no ID " + node.name);
        return;
    }
    // Parameters        (pID,  pName,       pStart,     pEnd,  pClass,    pLink, pMile, pRes ,  pComp, pGroup, pParent, pOpen, pDepend, pCaption, pNotes, pGantt, pCost)
    //   20.1              id   name         start       end    hex(color)  NA     0     debug,  stall %,  0|1,  parent ID, 1,     '',      '',    details, gantt_chart,    tripcount 
    //   stretch goals                                                  online references                                                  tooltip
    var curTask;
    let iterTask;
    let branchRegisterTask;
    if (group === 0) {
        if (debugCreateTask && debugMode)
            console.log("  is iteration, color: " + nodeColor);
        if (debugCreateTask && debugMode)
            console.log("  ID: " + node.id);
        curTask = new JSGantt.TaskItem(node.id, node.name, node.start, node.end, nodeColor, '', 0, /*TODOnodeDebug*/ '', 0, group, parentID, 1, '', '', /*TODOnodeDetails*/ '', gantt_chart);
        if (debugCreateTask && debugMode)
            console.log("  curTask ID: " + curTask.getOriginalID());
    }
    else if (group === 1) {
        if (debugCreateTask && debugMode)
            console.log("  is not, color: " + nodeColor);
        if (debugCreateTask && debugMode)
            console.log("  ID: " + node.id);
        if (node.type == "nested_iteration") {
            curTask = new JSGantt.TaskItem(node.id, node.name, node.start, node.end, nodeColor, '', 0, /*TODOnodeDebug*/ '', 0, group, parentID, 1, '', '', /*TODOnodeDetails*/ '', gantt_chart);
        }
        else {
            let isSpeculated = (node.hasOwnProperty("speculation") && !isNaN(parseInt(node.speculation)) && node.speculation > 0);
            curTask = new JSGantt.TaskItem(node.id, node.name, node.start, node.end, nodeColor, '', 0, /*TODOnodeDebug*/ '', 0, group, parentID, 1, '', '', /*TODOnodeDetails*/ '', gantt_chart, node.untouched_trip_count, null, null, null, null, isSpeculated);
        }
        if (debugCreateTask && debugMode)
            console.log("  curTask ID: " + curTask.getOriginalID());
    }
    else if (group === 2) {
        if (shouldRegisterBranch(node)) {
            curTask = new JSGantt.TaskItem(node.id, node.name, node.start, node.end, nodeColor, '', 0, /*TODOnodeDebug*/ '', 0, group, parentID, 1, '', '', /*TODOnodeDetails*/ '', gantt_chart);
            let iterTaskStart = node.start;
            let iterTaskEnd = node.end - 1;
            branchRegisterTask = new JSGantt.TaskItem(getAvailableTaskID(), "Branch Register", node.end - 1, node.end, loopsViewerColorTypeDict['register'], '', 0, /*TODOnodeDebug*/ '', 0, 0, node.id, 1, '', '', /*TODOnodeDetails*/ '', gantt_chart);
            iterTask = new JSGantt.TaskItem(getAvailableTaskID(), node.name, iterTaskStart, iterTaskEnd, nodeColor, '', 0, /*TODOnodeDebug*/ '', 0, 0, node.id, 1, '', '', /*TODOnodeDetails*/ '', gantt_chart);
        }
    }
    node["task_id"] = curTask.getID();
    if (group == 1 && !isComponentOrFunctionNode(node) && node.type != "nested_iteration") {
        // These tasks have text boxes with trip count info we're interested in
        let taskNodePair = {};
        taskNodePair["task"] = curTask;
        taskNodePair["node_copy"] = node;
        taskNodePairsWithTripCounts.push(taskNodePair);
        if (verificationMode) {
            // Also, we want to verify this task's start/end
            if (!invocationMap.hasOwnProperty(node.loop_node_id)) {
                invocationMap[node.loop_node_id] = [];
            }
            invocationMap[node.loop_node_id].push(curTask);
        }
    }
    gantt_chart.AddTaskItem(curTask);
    if (group == 2) {
        gantt_chart.AddTaskItem(iterTask);
        gantt_chart.AddTaskItem(branchRegisterTask);
    }
    return curTask;
}
function flattenNode(node, listToUpdate, parentID, sameLevelPredecessorID, sameLevelSuccessor) {
    if (parentID === undefined) {
        parentID = -1;
    }
    if (sameLevelPredecessorID === undefined) {
        sameLevelPredecessorID = -1;
    }
    if (sameLevelSuccessor === undefined) {
        sameLevelSuccessor = {};
    }
    var newNode = {};
    // Custom deep copy to copy the necessary attributes on the newNode
    // Children will be replace with a list of ID for memory saving and details from
    // are ported it over since they are not relevant
    Object.keys(node).filter(function (key) {
        return (key !== 'children' || key !== 'details');
    }).forEach(function (key) {
        newNode[key] = node[key];
    });
    if (parseInt(parentID) > 0)
        newNode["parent_id"] = parentID;
    newNode["predecessor_id"] = sameLevelPredecessorID;
    newNode["invocation_count"] = 1;
    let childrenToVisit = [];
    if (node.hasOwnProperty('children')) {
        // Store a list of children IDs in the node (instead of a list of children nodes)
        newNode['children'] = [];
        let nestedLoopEncountered = false;
        node['children'].forEach(function (childNode) {
            childrenToVisit.push(childNode);
            if (nestedLoopEncountered) {
                // We're a latch block
                nestedLoopEncountered = false;
                return;
            }
            newNode['children'].push(childNode['id']);
            if (childNode.hasOwnProperty("type") &&
                childNode.type == "loop" &&
                childNode.hasOwnProperty('children')) {
                // Nested loop: skip the next child
                nestedLoopEncountered = true;
            }
        });
        if (node.hasOwnProperty("type") &&
            node.type == "loop" &&
            node.hasOwnProperty('children')) {
            // We are a header of a nested loop, we should grab our successor (latch) as a child
            newNode['children'].push(sameLevelSuccessor.id);
            // Hacky, but assume latch has no children
            var newSameLevelSuccessor = {};
            Object.keys(sameLevelSuccessor).forEach(function (key) {
                if (key !== 'children') {
                    newSameLevelSuccessor[key] = sameLevelSuccessor[key];
                    //console.log("Adding key: " + key);
                }
            });
            newSameLevelSuccessor.ll = parseInt(newSameLevelSuccessor.ll) + 1;
            childrenToVisit.push(newSameLevelSuccessor);
        }
    }
    listToUpdate.push(newNode);
    if (node.hasOwnProperty('children')) {
        let nestedLoopEncountered = false;
        let latchEncountered = false;
        // recursively call its children
        for (let i = 0; i < childrenToVisit.length; i++) {
            if (nestedLoopEncountered) {
                // We're a latch block
                nestedLoopEncountered = false;
                latchEncountered = true;
                continue;
            }
            let childNode = childrenToVisit[i];
            let predecessorId = newNode.id;
            if (i > 0) {
                if (latchEncountered && i > 1) {
                    predecessorId = node['children'][i - 2].id;
                }
                else if (!latchEncountered) {
                    predecessorId = childrenToVisit[i - 1].id;
                }
            }
            // Switch it back off
            if (latchEncountered)
                latchEncountered = false;
            let successorNode = {};
            if (i < childrenToVisit.length - 1)
                successorNode = childrenToVisit[i + 1];
            flattenNode(childNode, listToUpdate, newNode.id, predecessorId, successorNode);
            if (childNode.hasOwnProperty("type") &&
                childNode.type == "loop" &&
                childNode.hasOwnProperty('children')) {
                // Nested loop: skip the next child
                nestedLoopEncountered = true;
            }
        }
    }
}
// Input is hierarchial list of nodes where the children nodes is in the attribute
// name children. The returned is a single list of nodes. The children just holds
// the ID for look up later.
function flattenJSON(oldJSON, funcNodeID) {
    if (funcNodeID === undefined) {
        funcNodeID = -1;
    }
    var newJSON = [];
    if (debugMode)
        console.log("JSON IS AN ARRAY ");
    for (let i = 0; i < oldJSON.length; i++) {
        let node = oldJSON[i];
        if (i > 0) {
            flattenNode(node, newJSON, funcNodeID, oldJSON[i - 1].id);
        }
        else {
            flattenNode(node, newJSON, funcNodeID, funcNodeID);
        }
    }
    return newJSON;
}
function isComponentOrFunctionNode(node) {
    if (node.type == "function" ||
        node.type == "component" ||
        node.type == "kernel") {
        return true;
    }
    else {
        return false;
    }
}
/// Parse block.json to find if any block contains stall free clusters, 
/// if so, find the amount of data each cluster is able to hold.
/// Note: we use fifo depth here because of rounding.
function populateSFCInLoopData(loopDataNodes) {
    for (let i = 0; i < loopDataNodes.length; i++) {
        let sfcDepth = [];
        // this id is the one that matched the block.json's id
        if (blockJSON.hasOwnProperty(loopDataNodes[i]['id'])) {
            let blockNodes = blockJSON[loopDataNodes[i]['id']]['nodes'];
            blockNodes.forEach(function (blockNode) {
                if (blockNode.hasOwnProperty('children')) {
                    for (let k = 0; k < blockNode['children'].length; k++) {
                        // check for stall free clusters
                        if (blockNode['children'][k]['name'] == 'Exit') {
                            // TODO: blockJSON needs to have this data so we dont have to parse the details
                            // TODO: to model SFC the model needs to go 1 level below, may need to add more info
                            let fifoDepth = parseInt(blockNode['children'][k]['details'][0]['Exit FIFO Depth']);
                            sfcDepth.push(fifoDepth);
                        }
                    }
                }
            });
        }
        if (sfcDepth.length > 0) {
            loopDataNodes[i]['sfc'] = sfcDepth;
        }
    }
}
/**
 * @function renderLoopVis clears everything that was there and restart the whole graph
 * @param {Array} loopNodeIDTripCountPairs is a list of loop nodes and their desired trip counts, optional
 * @param {Integer} loopID the loop ID selected from the list of loops, optional
 * @param {Bool} verificationModePassedIn switch turning on verification against simualtion data, optional
 * @param {Object} invocationMapPassed saves loop invocation gantt chart tasks for verification purposes, optional
 * @param {Object} loopDataNodesPassedIn saves loopDataNodes database for verification purposes, optional
 * @param {Bool} debugModePassedIn switch turning on debug mode (verbose messages), optional
 */
function renderLoopVis(loopNodeIDTripCountPairs, loopID, verificationModePassedIn, invocationMapPassedIn, loopDataNodesPassedIn, debugModePassedIn) {
    if (loopNodeIDTripCountPairs === undefined) {
        loopNodeIDTripCountPairs = [];
    }
    if (loopID === undefined) {
        loopID = -1;
    }
    if (verificationModePassedIn === undefined) {
        verificationModePassedIn = false;
    }
    if (invocationMapPassedIn === undefined) {
        invocationMapPassedIn = {};
    }
    if (loopDataNodesPassedIn === undefined) {
        loopDataNodesPassedIn = {};
    }
    if (debugModePassedIn === undefined) {
        debugModePassedIn = false;
    }
    verificationMode = verificationModePassedIn;
    loopIDSaved = loopID;
    invocationMap = invocationMapPassedIn;
    debugMode = debugModePassedIn;
    maxCycle = 0;
    // Clear details pane before rendering
    if (!verificationMode)
        clearDivContent();
    if (loopID !== undefined && top_node_id === loopID && top_node_id > 0)
        return; // do nothing if user clicks the same ID
    top_node_id = loopID;
    loopDataNodes = flattenJSON(loop_attrJSON['nodes']);
    populateSFCInLoopData(loopDataNodes);
    loopDataNodesPassedIn = loopDataNodes;
    taskNodePairsWithTripCounts = [];
    let CID;
    if (verificationModePassedIn)
        CID = "GanttChartDIV";
    else
        CID = getViewerConst().gid;
    gantt_chart = new JSGantt.GanttChart(document.getElementById(CID), 1);
    var centerPaneWidth;
    if (verificationModePassedIn)
        centerPaneWidth = 200;
    else
        centerPaneWidth = (CID != null && $('#' + CID).width() > 200 ? $('#' + CID).width() : 200); // This is just an error handling, take width=200 if it's smaller than 200px
    if (gantt_chart.getDivId() != null) {
        gantt_chart.setShowRes(1); // TODO: repurpose for debug
        gantt_chart.setShowDur(0);
        gantt_chart.setShowComp(0);
        gantt_chart.setShowStartDate(0);
        gantt_chart.setShowEndDate(0);
        gantt_chart.setShowStartCycle(1);
        gantt_chart.setShowEndCycle(1);
        gantt_chart.setCaptionType('Complete'); // Set to Show Caption (None,Caption,Resource,Duration,Complete)
        gantt_chart.setQuarterColWidth(36);
        gantt_chart.setShowTaskInfoLink(1); // Show link in tool tip (0/1)
        gantt_chart.setShowEndWeekDate(0); // Show/Hide the date for the last day of the week in header for daily view (1/0)
        gantt_chart.setUseSingleCell(10000); // Set the threshold at which we will only use one cell per table row (0 disables).  Helps with rendering performance for large charts.
        gantt_chart.setUseZoom(1);
        gantt_chart.setShowTripCount(1);
        gantt_chart.setTotalHeight("100%");
        gantt_chart.setUpdateCallback(updateTripCountTree);
        populateIterations(loopNodeIDTripCountPairs, loopID);
        var minCycle = 0;
        // Calculate total latency size base on min_cycle and max_cycle
        var latencySize = (maxCycle > minCycle ? maxCycle - minCycle : 0);
        if (latencySize <= 0) {
            $('#' + CID).html("Screen size too small to load data.");
            return;
        }
        else {
            gantt_chart.setFormatArr.apply(gantt_chart, createGanttZoomList(latencySize, gantt_chart.getCycleColWidth(), centerPaneWidth));
            gantt_chart.setFormat(gantt_chart.getFormatArr()[gantt_chart.getFormatArr().length - 1]); //use the last element in zoomLevelAry to zoom in full
        }
    }
    gantt_chart.Draw();
    return;
}
function removeArrayElement(arr, value) {
    for (var i = 0; i < arr.length; i++) {
        if (arr[i] === value) {
            arr.splice(i, 1);
        }
    }
}
function getNodeFromArray(nodeKey, array, isName) {
    if (isName === undefined) {
        isName = false;
    }
    let nodeIndex = getNodeIndex(nodeKey, array, isName);
    if (nodeIndex >= 0 && nodeIndex < array.length) {
        return array[nodeIndex];
    }
    else {
        // Error out?
        console.log("Error: Array does not contain key: " + nodeKey);
        let emptyObj = {};
        return emptyObj;
    }
}
function sortNumber(a, b) {
    return a - b;
}
function getSuccessorNodeID(nodeID, array) {
    for (let i = 0; i < array.length - 1; i++) {
        if (array[i].id == nodeID) {
            return array[i + 1].id;
        }
    }
    return -1;
}
function getSuccessorNode(nodeID, array) {
    let successorNodeID = getSuccessorNodeID(nodeID, array);
    return getNodeFromArray(successorNodeID, array);
}
function getPredecessorNodeID(nodeID, array) {
    if (array[0].id == nodeID)
        return -1;
    for (let i = 1; i < array.length; i++) {
        if (array[i].id == nodeID) {
            return array[i - 1].id;
        }
    }
    // Should reach here, unless we were provided a non-existent ID
    return -1;
}
function getPredecessorNode(nodeID, array) {
    //let predecessorNodeID = getPredecessorNodeID(nodeID, array);
    let predecessorNodeID = getNodeFromArray(nodeID, loopDataNodes).predecessor_id;
    return getNodeFromArray(predecessorNodeID, array);
}
function getMostRecentNodeCopy(node) {
    if (!node.hasOwnProperty("threads"))
        return {};
    //let lastInvocIndex = node.copies.length-1;
    //let lastIterIndex = node.copies[lastInvocIndex].length-1;
    lastIterIndex = node.copies[lastInvocIndex].length - 1;
    return node.copies[lastInvocIndex][lastIterIndex];
}
function propComparator(property) {
    return function (a, b) {
        if (a[property] < b[property]) {
            return -1;
        }
        if (a[property] > b[property]) {
            return 1;
        }
        return 0;
    };
}
function sortArray(array, property) {
    // Sort node.limiter_start_objects array using partition_start value
    array.sort(propComparator(property));
}
function shouldRegisterBranch(loopNode) {
    return (loopNode.hasOwnProperty("br") && parseInt(loopNode.br) == 1);
}
function createImplicitLimiter(startNode, endNode, startPoint, endPoint, capacity, checkPreviousIteration, parentNode, thresholdDelay) {
    if (capacity === undefined) {
        capacity = -1;
    }
    if (checkPreviousIteration === undefined) {
        checkPreviousIteration = false;
    }
    if (parentNode === undefined) {
        parentNode = {};
    }
    if (thresholdDelay === undefined) {
        thresholdDelay = false;
    }
    let limiterStartElement = {};
    let limiterEndElement = {};
    if (!startNode.hasOwnProperty('implicit_limiter_count'))
        startNode['implicit_limiter_count'] = 0;
    if (!endNode.hasOwnProperty('implicit_limiter_count'))
        endNode['implicit_limiter_count'] = 0;
    limiterStartElement['id'] = "implicit_" + startNode['implicit_limiter_count'].toString(10);
    startNode['implicit_limiter_count'] = parseInt(startNode['implicit_limiter_count']) + 1;
    limiterEndElement['id'] = "implicit_" + endNode['implicit_limiter_count'].toString(10);
    endNode['implicit_limiter_count'] = parseInt(endNode['implicit_limiter_count']) + 1;
    limiterStartElement["start"] = startPoint;
    limiterEndElement["start"] = endPoint;
    if (capacity < 0)
        capacity = endPoint - startPoint; // Change this, JSON file should contain explicit capacity info
    if (capacity < 0)
        capacity = 1;
    // Parent: Should be smallest ancestor  
    if (Object.entries(parentNode).length > 0)
        addLimiterToLoopNodes(parentNode, startNode, endNode, limiterStartElement, limiterEndElement, capacity, checkPreviousIteration, thresholdDelay);
    else
        addLimiterToLoopNodes(startNode, startNode, endNode, limiterStartElement, limiterEndElement, capacity, checkPreviousIteration, thresholdDelay);
}
function createImplicitLimiterDetailNode(start, end) {
    let implicitLimiterDetailNode = {};
    implicitLimiterDetailNode["start"] = parseInt(start);
    implicitLimiterDetailNode["end"] = parseInt(end);
    return implicitLimiterDetailNode;
}
/*
 * This function adds an implicit limiter between the node start and the start of the first limited region
 * It also calculates and adds the distance between each limited region
 * Expects node.limiter_objects to be sorted by partition start time
 * Should be called after addLimiterToLoopNodes is called for every limiter of a loop
 * Create limiters between any stallable points - that is, if there are ANY starts in the node, then there should be <num of starts> + 1 limiters created
 * Ends need to know the distance of the closest start before it, since that start is stallable and we will need that <start point> + <distance to end point> = <end point>
 */
function postProcessLimiters(node) {
    if (isComponentOrFunctionNode(node))
        return;
    // Do the first if statement for both starts/ends
    let allObjects = [];
    if (node.hasOwnProperty("limiter_start_objects"))
        allObjects = allObjects.concat(node.limiter_start_objects);
    if (node.hasOwnProperty("limiter_end_objects")) {
        let limiter_end_objects_values = Object.keys(node.limiter_end_objects).map(function (key) {
            return node.limiter_end_objects[key];
        });
        allObjects = allObjects.concat(limiter_end_objects_values);
    }
    if (allObjects.length > 0) {
        let implicitLimiterDetails = [];
        sortArray(allObjects, "partition_start");
        if (parseInt(allObjects[0].partition_start) != 0) {
            implicitLimiterDetails.push(createImplicitLimiterDetailNode(0, allObjects[0].partition_start));
        }
        for (let i = 0; i < allObjects.length; i++) {
            // Create implicit limiters between stallable points of the block
            if (i == allObjects.length - 1) {
                if (allObjects[i].partition_start != node.latency)
                    // Don't create something that spans the whole block - why not? avoid duplicates? I'll add a duplicate checker to addLimiterToNode
                    // Don't create a probe (start end at the same point)
                    implicitLimiterDetails.push(createImplicitLimiterDetailNode(allObjects[i].partition_start, node.latency));
                //createImplicitLimiter(node, node, node.limiter_start_objects[i].partition_start, node.latency);
            }
            else {
                if (allObjects[i].partition_start != allObjects[i + 1].partition_start)
                    implicitLimiterDetails.push(createImplicitLimiterDetailNode(allObjects[i].partition_start, allObjects[i + 1].partition_start));
                //createImplicitLimiter(node, node, node.limiter_start_objects[i].partition_start, node.limiter_start_objects[i+1].partition_start);
            }
        }
        // Actually add the limiters
        for (let i = 0; i < implicitLimiterDetails.length; i++) {
            let implicitLimiterStart = implicitLimiterDetails[i].start;
            let implicitLimiterEnd = implicitLimiterDetails[i].end;
            //if (node.interleaving > 1) createImplicitLimiter(node, node, parseInt(implicitLimiterStart), parseInt(implicitLimiterEnd), -1, true);
            //else 
            createImplicitLimiter(node, node, parseInt(implicitLimiterStart), parseInt(implicitLimiterEnd));
        }
    }
    // if (node.hasOwnProperty("limiter_start_objects")) {
    //   let implicitLimiterDetails = [];
    //   let nodeLimiterStartObjectLength = node.limiter_start_objects.length;
    //   if (parseInt(node.limiter_start_objects[0].partition_start) != 0) {
    //     implicitLimiterDetails.push(createImplicitLimiterDetailNode(0, node.limiter_start_objects[0].partition_start));
    //   }    
    //   for (let i = 0; i < nodeLimiterStartObjectLength; i++) {
    //     // Create implicit limiters between stallable points of the block
    //     if (i == node.limiter_start_objects.length - 1 ) {
    //       if (parseInt(node.limiter_start_objects[i].partition_start) != 0 && node.limiter_start_objects[i].partition_start != node.latency)
    //         // Don't create something that spans the whole block - why not?
    //         // Don't create a probe (start end at the same point)
    //         implicitLimiterDetails.push(createImplicitLimiterDetailNode(node.limiter_start_objects[i].partition_start, node.latency ));
    //         //createImplicitLimiter(node, node, node.limiter_start_objects[i].partition_start, node.latency);
    //     } else {
    //       if (node.limiter_start_objects[i].partition_start != node.limiter_start_objects[i+1].partition_start) 
    //         implicitLimiterDetails.push(createImplicitLimiterDetailNode(node.limiter_start_objects[i].partition_start, node.limiter_start_objects[i+1].partition_start ));       
    //         //createImplicitLimiter(node, node, node.limiter_start_objects[i].partition_start, node.limiter_start_objects[i+1].partition_start);
    //     }
    //   } 
    //   // Actually add the limiters
    //   for (let i = 0; i < implicitLimiterDetails.length; i++) {
    //     let implicitLimiterStart = implicitLimiterDetails[i].start;
    //     let implicitLimiterEnd = implicitLimiterDetails[i].end;
    //     createImplicitLimiter(node, node, parseInt(implicitLimiterStart), parseInt(implicitLimiterEnd));
    //   } 
    // }
    // Find the closest start point before each end point, within the same node
    if (node.hasOwnProperty("limiter_end_objects")) {
        let limiter_end_objects_values = Object.keys(node.limiter_end_objects).map(function (key) {
            return node.limiter_end_objects[key];
        });
        limiter_end_objects_values.forEach(function (endObject) {
            let lastStartPoint = 0;
            let lastStartLimiterID = "";
            if (node.hasOwnProperty("limiter_start_objects")) {
                for (let i = 0; i < node.limiter_start_objects.length; i++) {
                    if (parseInt(node.limiter_start_objects[i].partition_start) > parseInt(endObject.partition_start) && i > 0) {
                        lastStartPoint = node.limiter_start_objects[i - 1].partition_start;
                        lastStartLimiterID = node.limiter_start_objects[i - 1].id;
                        break; // Found the last start point
                    }
                    // If a stall point is equal to the end point, then it should use it
                    if (parseInt(node.limiter_start_objects[i].partition_start) == parseInt(endObject.partition_start)) {
                        lastStartPoint = node.limiter_start_objects[i].partition_start;
                        lastStartLimiterID = node.limiter_start_objects[i].id;
                        break; // Found the last start point
                    }
                }
            }
            let distanceFromLastStartPoint = parseInt(endObject.partition_start) - parseInt(lastStartPoint);
            endObject["distance_from_last_start_point"] = distanceFromLastStartPoint;
            endObject["last_start_point"] = lastStartPoint; //lastStartLimiterID; // If this value is empty, use the node's start point
        });
    }
}
function doesLimiterExist(limiterStartParentNode, limiterEndParentNode, limiterStartElement, limiterEndElement, limitedRegionCapacity) {
    if (limiterStartParentNode.limiter_start_objects_map_by_startpoint.hasOwnProperty(limiterStartElement.start)) {
        // Loop through array of start objects
        let startObjectsArrLength = limiterStartParentNode.limiter_start_objects_map_by_startpoint[limiterStartElement.start].length;
        for (let i = 0; i < startObjectsArrLength; i++) {
            let startObject = limiterStartParentNode.limiter_start_objects_map_by_startpoint[limiterStartElement.start][i];
            if (parseInt(startObject.limiter_end_node_id) == parseInt(limiterEndParentNode.id) &&
                parseInt(limiterEndElement.start) == limiterEndParentNode.limiter_end_objects[startObject.limiter_end_id].start) {
                // Then this start object and end object already exists
                // Modify the capacity of the start object, then return true
                startObject.limited_region_capacity = Math.min(startObject.limited_region_capacity, limitedRegionCapacity);
                return true;
            }
        }
    }
    return false;
}
/*
 * This function should be called when preprocessing loops with limiters
 * A loop limiter should have a start and an end, each with its own block parent
 * (start means 2 things, limiter start, and startpoint of the node that indicates
 * a bookend of the limited region - considering renaming something)
 */
function addLimiterToLoopNodes(limiterParentNode, limiterStartParentNode, limiterEndParentNode, limiterStartElement, limiterEndElement, limitedRegionCapacity, checkPreviousIteration, thresholdDelay) {
    if (checkPreviousIteration === undefined) {
        checkPreviousIteration = false;
    }
    if (thresholdDelay === undefined) {
        thresholdDelay = false;
    }
    // Sanity check that limiterElement's block parent == node
    if (isComponentOrFunctionNode(limiterStartParentNode) || isComponentOrFunctionNode(limiterEndParentNode))
        return;
    if (!limiterStartParentNode.hasOwnProperty("limiter_start_objects")) {
        limiterStartParentNode["limiter_start_objects"] = [];
        limiterStartParentNode["limiter_start_objects_map_by_startpoint"] = {};
    }
    if (!limiterEndParentNode.hasOwnProperty("limiter_end_objects")) {
        limiterEndParentNode["limiter_end_objects"] = {};
    }
    // doesLimiterExist finds a limiter that starts and ends at the exact same places, and updates the capacity to the lower between two options
    // Returns true if a duplicate limiter is found/updated
    if (doesLimiterExist(limiterStartParentNode, limiterEndParentNode, limiterStartElement, limiterEndElement, limitedRegionCapacity))
        return;
    let limiterStartObject = {};
    let limiterEndObject = {};
    limiterStartObject["is_limiter_start"] = true;
    limiterStartObject['id'] = limiterStartElement.id;
    limiterEndObject["is_limiter_start"] = false;
    limiterEndObject['id'] = limiterEndElement.id;
    limiterStartObject["limiter_parent_id"] = limiterParentNode.id;
    limiterEndObject["limiter_parent_id"] = limiterParentNode.id;
    limiterStartObject["check_prev_iter"] = checkPreviousIteration;
    limiterEndObject["check_prev_iter"] = checkPreviousIteration;
    limiterStartObject["threshold_delay"] = thresholdDelay;
    limiterEndObject["threshold_delay"] = thresholdDelay;
    // Limiter start needs to know the ID of the limiter end, to gather endpoint encounter data 
    limiterStartObject["limiter_end_node_id"] = limiterEndParentNode.id;
    limiterStartObject["limiter_end_id"] = limiterEndElement.id; // To find the correct element in the limiter_end_objects hash
    // Limiter end needs to know the ID of the limiter start, to see if there is a new start encounter it needs to address
    limiterEndObject["limiter_start_node_id"] = limiterStartParentNode.id;
    limiterEndObject["limiter_start_id"] = limiterStartElement.id; // To find the correct element in the limiter_end_objects hash
    limiterStartObject["partition_start"] = limiterStartElement.start;
    limiterEndObject["partition_start"] = limiterEndElement.start;
    limiterStartObject["limited_region_capacity"] = limitedRegionCapacity;
    limiterStartObject["limited_region_num_threads"] = 0; // Initialize to zero, every encounter of the limited region start should increment this
    // Not sure if this is necessary:
    // I don't love this name
    limiterStartObject["partition_start_encounters"] = [];
    limiterEndObject["partition_start_encounters"] = [];
    if (limiterStartParentNode.id == limiterEndParentNode.id) {
        // Limiter is within the same node
        // Can calculate its latency
        limiterStartObject["latency"] = parseInt(limiterEndElement.start) - parseInt(limiterStartElement.start);
    }
    else {
        limiterStartObject["latency"] = parseInt(limiterStartParentNode.latency) - parseInt(limiterStartElement.start);
    }
    if (limiterStartObject.latency < 0)
        limiterStartObject.latency = 0;
    limiterStartParentNode.limiter_start_objects.push(limiterStartObject);
    if (!limiterStartParentNode.limiter_start_objects_map_by_startpoint.hasOwnProperty(limiterStartElement.start))
        limiterStartParentNode.limiter_start_objects_map_by_startpoint[limiterStartElement.start] = [];
    limiterStartParentNode.limiter_start_objects_map_by_startpoint[limiterStartElement.start].push(limiterStartObject);
    limiterEndParentNode.limiter_end_objects[limiterEndElement.id] = limiterEndObject;
    // Sort limiter objects by partition_start value
    sortArray(limiterStartParentNode.limiter_start_objects, "partition_start");
}
// Parses the loopsJSON and returns a map of loop name and speculative iteration
// TODO: remove this once loop speculative iteration is part of loop_attrJSON
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
/*
 * This function is to take all the nodes, and "preprocess them"
 * This involves:
 *    1) Transferring various JSON file info into loop nodes
 *    2) Creating implicit limiters:
 *       a) An inner loop will produce a limiter for its direct outer loop parent
 *          The limiter starts at the beginning of the inner loop, and ends at the beginning + II
 *          Interleaving # will be the capacity of the limited region
 *       b) An unpipelined outer loop will produce a limiter that starts at the start of the header
 *          and ends at the end of the latch
 *    Unpipelined inner loop will have II = latency --> make sure this is true, no preprocessing necessary
 *    Type of nodeCopy - speculative - but it's the same node...
 */
function preProcessNodes() {
    let loopSpeculationDict = createLegacyLoopSpecMap();
    for (let i = 0; i < loopDataNodes.length; i++) {
        let loopNode = loopDataNodes[i];
        if (isComponentOrFunctionNode(loopNode))
            continue;
        // Get the unroll factor
        // TODO: What is block name for?
        let partUnrollRegEx = /(.+)X Partially unrolled (.+)/;
        let match = partUnrollRegEx.exec(loopNode.name);
        if (match != null) {
            loopNode["unroll_factor"] = match[1];
            loopNode["block_name"] = match[2];
        }
        else {
            loopNode["unroll_factor"] = -1;
        }
        let fusedLoopRegEx = /Fused loop (.+)/;
        match = fusedLoopRegEx.exec(loopNode.name);
        if (match != null) {
            loopNode["block_name"] = match[1];
        }
        loopNode["threads"] = [];
        loopNode["thread_count"] = 0;
    }
    // Translate II, loop layer, pipelined values and insert loop speculative iteration
    for (let i = 0; i < loopDataNodes.length; i++) {
        let loopNode = loopDataNodes[i];
        if (isComponentOrFunctionNode(loopNode)) {
            continue;
        }
        if (loopSpeculationDict.hasOwnProperty(loopNode.name)) {
            let speculation = parseInt(loopSpeculationDict[loopNode.name]);
            if (!isNaN(speculation)) {
                loopNode['speculation'] = speculation;
            }
        }
        if (loopNode.hasOwnProperty('ii'))
            loopNode['ii'] = parseInt(loopNode['ii']); // II
        if (loopNode.hasOwnProperty('ll'))
            loopNode['ll'] = parseInt(loopNode['ll']); // loop layer
        if (loopNode.hasOwnProperty('pl'))
            loopNode['pl'] = (loopNode['pl'] === 'Yes') ? 1 : 0; // pipelined
        if (loopNode.hasOwnProperty("mi"))
            loopNode["interleaving"] = parseInt(loopNode.mi);
        if (isComponentOrFunctionNode(loopNode))
            continue;
        loopNode["latency"] = parseInt(Math.floor(Number(loopNode.lt)));
        // Branch register
        if (shouldRegisterBranch(loopNode))
            loopNode.latency += 1;
        console.log("ID: " + loopNode.id + " Latency: " + loopNode.latency);
    }
    // Take bottleneckNodes and update loopDataNodes: loopNode
    let bottleneckList = bottleneckJSON['bottlenecks'];
    for (let i = 0; i < bottleneckList.length; i++) {
        // Bottleneck node should have:
        let bottleneckNode = bottleneckList[i];
        // TODO: Answer: should we ignore data dependencies for innermost loops?
        //if (bottleneckNode.brief == "Data dependency") continue;
        let limiterStartElement = bottleneckNode.nodes[0];
        let limiterEndElement = bottleneckNode.nodes[bottleneckNode.nodes.length - 1];
        if (parseInt(bottleneckNode.src) != parseInt(limiterStartElement.id))
            console.error("First limiter node is not the bottleneck source");
        if (parseInt(bottleneckNode.dst) != parseInt(limiterEndElement.id))
            console.error("Last limiter node is not the bottleneck destination");
        let limiterStartParentNode = getNodeFromArray(limiterStartElement.parent, loopDataNodes);
        let limiterEndParentNode = getNodeFromArray(limiterEndElement.parent, loopDataNodes);
        let limiterParentNode = getNodeFromArray(bottleneckNode.loop, loopDataNodes);
        if (!limiterEndElement.hasOwnProperty("start"))
            limiterEndElement["start"] = limiterEndElement.end;
        if (!limiterStartElement.hasOwnProperty("start"))
            continue; // Dependencies should be fully populated
        if (limiterStartElement.start == "n/a" || limiterEndElement.start == "n/a")
            continue;
        let checkPreviousIteration = false;
        if (limiterParentNode.interleaving > 1 && bottleneckNode.brief == "Data dependency")
            checkPreviousIteration = true;
        limiterEndElement.start = parseInt(Math.floor(Number(limiterEndElement.start)));
        limiterStartElement.start = parseInt(Math.floor(Number(limiterStartElement.start)));
        let concurrency = 1;
        if (bottleneckNode.hasOwnProperty("concurrency"))
            concurrency = bottleneckNode.concurrency;
        addLimiterToLoopNodes(limiterParentNode, limiterStartParentNode, limiterEndParentNode, limiterStartElement, limiterEndElement, concurrency, checkPreviousIteration);
    }
    // Create Implicit limiters
    for (let i = 0; i < loopDataNodes.length; i++) {
        // If this is a nested loop, add an implicit limiter
        let loopNode = loopDataNodes[i];
        if (loopNode.hasOwnProperty("children") && loopNode.children.length > 0) {
            if (isComponentOrFunctionNode(loopNode))
                continue;
            // Add an implicit limiter, that starts at each inner loop's predecessor's endpoint, and ends at each inner loop's startpoint + its II
            for (let j = 0; j < loopNode.children.length; j++) {
                let childLoopNodeID = loopNode.children[j];
                let childLoopNode = getNodeFromArray(childLoopNodeID, loopDataNodes);
                if (childLoopNode.type === 'loop' && childLoopNode.pl) {
                    let predecessorNode = getPredecessorNode(childLoopNodeID, loopDataNodes);
                    let parentNode = {};
                    if (predecessorNode.ll == childLoopNode.ll) {
                        // Same level, specify the parent
                        parentNode = getNodeFromArray(childLoopNode.parent_id, loopDataNodes);
                        if (childLoopNode.parent_id != predecessorNode.parent_id)
                            console.error("Predecessor and Current nodes are on the same loop level but have different parents");
                    }
                    if (parseInt(childLoopNode.interleaving) > 1) {
                        // Create an implicit Limiter for II=1 for inner loop
                        createImplicitLimiter(predecessorNode, childLoopNode, predecessorNode.latency, childLoopNode.ii, childLoopNode.interleaving, false, parentNode, childLoopNode.threshold_delay);
                        // Enforce II for same outer loop iteration
                        createImplicitLimiter(childLoopNode, childLoopNode, 0, childLoopNode.ii, 1, true);
                        childLoopNode.ii = 1;
                        createImplicitLimiter(childLoopNode, childLoopNode, 0, 1, 1);
                    }
                    else {
                        createImplicitLimiter(predecessorNode, childLoopNode, predecessorNode.latency, childLoopNode.ii, 1, false, parentNode, childLoopNode.threshold_delay);
                    }
                }
            }
            if (!loopNode.pl) {
                // Outer loop is unpipelined
                let headerNodeID = loopNode.id;
                let latchNodeID = loopNode.children[loopNode.children.length - 1];
                let headerNode = getNodeFromArray(headerNodeID, loopDataNodes);
                let latchNode = getNodeFromArray(latchNodeID, loopDataNodes);
                createImplicitLimiter(headerNode, latchNode, 0, latchNode.latency, 1);
            }
        }
    }
    for (let i = 0; i < loopDataNodes.length; i++) {
        let loopNode = loopDataNodes[i];
        postProcessLimiters(loopNode);
    }
}
// header copy should have all the 
function getNodeCopyThread(nodeID, threadNum) {
    let node = getNodeFromArray(nodeID, loopDataNodes);
    if (node.hasOwnProperty("threads") && node.threads.length > parseInt(threadNum))
        return node.threads[parseInt(threadNum)];
    else
        return {};
}
function getLatestElementOfThread(nodeID, threadNum) {
    let nodeCopy = getNodeCopyThread(nodeID, threadNum);
    if (!nodeCopy.hasOwnProperty('children') || nodeCopy['children'].length == 0) {
        return nodeCopy;
    }
    else {
        // You're a header
        let nestedDetails = getNestedDetails(nodeID, threadNum);
        // Grab your last child's last iteration
        let lastChildID = nodeCopy['children'][nodeCopy['children'].length - 1];
        if (!nestedDetails.children_info[lastChildID].hasOwnProperty("invocation_details"))
            return {};
        let childTripCount = nestedDetails.children_info[lastChildID].invocation_details.speculated_trip_count;
        if (nestedDetails.children_info[lastChildID].iteration_threads.length != childTripCount)
            return {}; // Child is not done yet!
        let lastIter = nestedDetails.children_info[lastChildID].iteration_threads.length - 1;
        let lastThreadNum = nestedDetails.children_info[lastChildID].iteration_threads[lastIter].thread_num;
        return getNodeCopyThread(lastChildID, lastThreadNum);
    }
}
function getParentHeaderNestedDetails(nodeCopy) {
    let parentID = nodeCopy.parent_id;
    let threadNum = nodeCopy.parent_thread_num;
    return getNestedDetails(parentID, threadNum);
}
function getPreviousIteration(nodeCopy) {
    if (nodeCopy.iteration_num == 0)
        return {};
    let parentHeaderNestedDetails = getParentHeaderNestedDetails(nodeCopy);
    let previousIterationThreadNum = parentHeaderNestedDetails.children_info[nodeCopy.id].iteration_threads[parseInt(nodeCopy.iteration_num) - 1].thread_num;
    return getNodeCopyThread(nodeCopy.id, previousIterationThreadNum);
}
function getInvocationDetails(nodeID, threadNum) {
    let parentNestedDetails = getNestedDetails(node.parent_id, parentThreadNum);
    // Look at your parentNestedDetails object, if there is already information about your invocation from your parent thread then skip the initialization
    if (parentNestedDetails.children_info[node.id].hasOwnProperty("invocation_details")) {
        return parentNestedDetails.children_info[node.id].invocation_details;
    }
    else {
        return {};
    }
}
function getNestedDetails(nodeID, threadNum) {
    let nodeCopy = getNodeCopyThread(nodeID, threadNum);
    if (!nodeCopy.hasOwnProperty("nested_iter_detail"))
        console.error("Missing nested iteration details");
    return nodeCopy.nested_iter_detail;
}
function getLimiterParentThread(nodeCopy, limiterObj) {
    let limiterParentID = limiterObj.limiter_parent_id;
    if (parseInt(nodeCopy.loop_node_id) == parseInt(limiterParentID))
        return nodeCopy.own_thread_num;
    let parentNodeCopy = getNodeCopyThread(nodeCopy.parent_id, nodeCopy.parent_thread_num);
    return getLimiterParentThread(parentNodeCopy, limiterObj);
}
function isLastInstanceOfLimiterEnd(nodeCopy, limiterObj) {
    let limiterParentID = limiterObj.limiter_parent_id;
    if (parseInt(nodeCopy.loop_node_id) == parseInt(limiterParentID))
        return nodeCopy.own_thread_num;
    let nodeCopyToRecurse = nodeCopy;
    let parentNodeCopy = {};
    while (true) {
        if (nodeCopyToRecurse.is_last_iteration == false)
            return -1;
        console.log("Parent ID: " + nodeCopyToRecurse.parent_id + " Name: " + nodeCopyToRecurse.name);
        console.log("Thread num: " + nodeCopyToRecurse.parent_thread_num);
        parentNodeCopy = getNodeCopyThread(nodeCopyToRecurse.parent_id, nodeCopyToRecurse.parent_thread_num);
        if (nodeCopyToRecurse.is_last_iteration && (parentNodeCopy.loop_node_id) == parseInt(limiterParentID))
            return nodeCopyToRecurse.parent_thread_num;
        nodeCopyToRecurse = parentNodeCopy;
    }
}
function initializeInvocationDetails(node, parentChildInfoMap, scheduleHeader, parentTaskID) {
    parentChildInfoMap["invocation_details"] = {};
    let tripCount = 1;
    if (node.hasOwnProperty("trip_count_nodes") && !scheduleHeader) {
        let tripCountObject = node.trip_count_nodes.shift(); // Take first element - can't assume we're taking these in order any more right? Or maybe we can (initialize before scheduling)
        tripCount = parseInt(tripCountObject.trip_count);
    }
    node["untouched_trip_count"] = tripCount;
    if (node.hasOwnProperty("unroll_factor") && parseInt(node.unroll_factor) > 0) {
        tripCount = Math.ceil(parseInt(tripCount) / parseInt(node.unroll_factor));
    }
    parentChildInfoMap.invocation_details["unspeculated_trip_count"] = tripCount;
    console.log("Unspeculated trip count: " + parentChildInfoMap.invocation_details["unspeculated_trip_count"]);
    if (node.hasOwnProperty("speculation") && !isNaN(parseInt(node.speculation)) &&
        (!node.hasOwnProperty('children') || node['children'].length == 0)) { // Only support for innermost loops for now, 
        tripCount += parseInt(node.speculation);
        console.log("Unspeculated trip count: " + parentChildInfoMap.invocation_details["unspeculated_trip_count"]);
    }
    parentChildInfoMap.invocation_details["speculated_trip_count"] = tripCount;
    let loopTotalLatencyTaskID = node.invocation_count.toString(10) + node.id.toString(10);
    node.invocation_count = parseInt(node.invocation_count) + 1;
    let loopTotalLatencyTask = {};
    // Make a task that will hold all the iterations
    if (node.type == "loop" && !scheduleHeader) {
        Object.keys(node).forEach(function (key) {
            loopTotalLatencyTask[key] = node[key];
        });
        loopTotalLatencyTask["loop_node_id"] = node.id;
        loopTotalLatencyTask["name"] = node.name + " Total Latency";
        loopTotalLatencyTask["start"] = -1;
        loopTotalLatencyTask["end"] = -1;
        loopTotalLatencyTask["trip_count"] = tripCount;
        loopTotalLatencyTask.id = loopTotalLatencyTaskID;
        parentChildInfoMap.invocation_details["loop_total_latency_task_obj"] = createTask(loopTotalLatencyTask, parentTaskID);
    }
    parentChildInfoMap.invocation_details["loop_total_latency_task_id"] = loopTotalLatencyTaskID;
}
function initializeNodeCopy(nodeCopy, node, iterationIsSpeculative, scheduleHeader, parentThreadNum, iterationNum, tripCount, headerNestedIterDetail) {
    Object.keys(node).forEach(function (key) {
        nodeCopy[key] = node[key];
    });
    if (iterationIsSpeculative) {
        nodeCopy["type"] = "speculation";
    }
    node.threads.push(nodeCopy);
    nodeCopy["loop_node_id"] = node.id;
    if (!nodeCopy.hasOwnProperty("parent_thread_num"))
        nodeCopy["parent_thread_num"] = parentThreadNum;
    if (!nodeCopy.hasOwnProperty("own_thread_num")) {
        nodeCopy["own_thread_num"] = node.thread_count;
        node.thread_count = parseInt(node.thread_count) + 1;
    }
    if (scheduleHeader) {
        // We are scheduling the header of an outer nested loop
        // Add the nested iter object to this node copy, that should be passed in with this flag
        nodeCopy["nested_iter_detail"] = headerNestedIterDetail;
        // Once I know my thread number, update the nested iter object
        nodeCopy.nested_iter_detail["thread_num"] = nodeCopy.own_thread_num;
    }
    // Update your parent's children_info->iteration_threads
    let nestedIterDetail = getParentHeaderNestedDetails(nodeCopy);
    if (Object.entries(nestedIterDetail).length > 0) {
        let iterThreadObj = {};
        iterThreadObj["thread_num"] = nodeCopy.own_thread_num;
        iterThreadObj["done"] = false;
        nestedIterDetail.children_info[node.id].iteration_threads.push(iterThreadObj);
    }
    nodeCopy["iteration_num"] = iterationNum;
    if (iterationNum == tripCount - 1) {
        nodeCopy["is_last_iteration"] = true;
    }
    else {
        nodeCopy["is_last_iteration"] = false;
    }
}
var currTaskID = -1;
function getAvailableTaskID() {
    if (currTaskID < 0) {
        currTaskID = 1000;
        return currTaskID;
    }
    else {
        currTaskID = parseInt(currTaskID) + 1;
        return currTaskID;
    }
}
function isRealLimiterStartEncounter(nodeCopy, limiterStartObject) {
    if (!limiterStartObject.hasOwnProperty("parent_threads"))
        limiterStartObject["parent_threads"] = {};
    let limiterParentThread = getLimiterParentThread(nodeCopy, limiterStartObject);
    if (!limiterStartObject.parent_threads.hasOwnProperty(limiterParentThread)) {
        limiterStartObject.parent_threads[limiterParentThread] = nodeCopy.own_thread_num;
        return true;
    }
    else if (limiterStartObject.parent_threads[limiterParentThread] != nodeCopy.own_thread_num) {
        return false;
    }
    return true;
}
function initializeLimiterObjectCopies(node, nodeCopy) {
    if (nodeCopy.hasOwnProperty("limiter_start_objects_copy") && nodeCopy.hasOwnProperty("limiter_end_objects_copy"))
        return;
    for (let k = 0; k < node.limiter_start_objects.length; k++) {
        let limiterStartObject = node.limiter_start_objects[k];
        if (limiterStartObject.check_prev_iter == true) {
            if (!nodeCopy.hasOwnProperty("limiter_start_objects_copy"))
                nodeCopy["limiter_start_objects_copy"] = {};
            if (!nodeCopy.hasOwnProperty("limiter_end_objects_copy"))
                nodeCopy["limiter_end_objects_copy"] = {};
            let limiterStartNode = node;
            let limiterEndNode = getNodeFromArray(limiterStartObject.limiter_end_node_id, loopDataNodes);
            let limiterEndObject = limiterEndNode.limiter_end_objects[limiterStartObject.limiter_end_id];
            let limiterStartObjectCopy = {};
            Object.keys(limiterStartObject).forEach(function (key) {
                if (key != "partition_start_encounters" && key != "parent_threads")
                    limiterStartObjectCopy[key] = limiterStartObject[key];
            });
            limiterStartObjectCopy["partition_start_encounters"] = [];
            limiterStartObjectCopy["parent_threads"] = {};
            let limiterEndObjectCopy = {};
            Object.keys(limiterEndObject).forEach(function (key) {
                if (key != "partition_start_encounters")
                    limiterEndObjectCopy[key] = limiterEndObject[key];
            });
            limiterEndObjectCopy["partition_start_encounters"] = [];
            nodeCopy.limiter_start_objects_copy[limiterStartObject.id] = limiterStartObjectCopy;
            nodeCopy.limiter_end_objects_copy[limiterEndObject.id] = limiterEndObjectCopy;
        }
    }
    return;
}
/*
 * Ensure partition_start_encounters are all accurate for this current iteration
 */
function reanalyzeLimiterStartObject(node, nodeCopy, predecessorEnd) {
    // We have a map of limiter starts by startpoint
    // Go in order
    // For each startpoint, pick max between: all the starts at the startpoint, and <previous max start point> + <distance from that start point>
    let previousMaxStartPoint = -1;
    let previousMaxStartPartitionStart = -1;
    Object.entries(node.limiter_start_objects_map_by_startpoint).forEach(function (limiterStartPointObjects) {
        let partitionStart = limiterStartPointObjects[1][0].partition_start;
        let maxEncounterPoint = -1;
        for (let i = 0; i < limiterStartPointObjects[1].length; i++) {
            let limiterStartObject = limiterStartPointObjects[1][i];
            if (limiterStartPointObjects[1][i].check_prev_iter == true) {
                limiterStartObject = nodeCopy.limiter_start_objects_copy[limiterStartObject.id];
            }
            let mostRecentStartObjectIndex = limiterStartObject.partition_start_encounters.length - 1;
            if (mostRecentStartObjectIndex >= 0) {
                let mostRecentStartObjectEncounter = limiterStartObject.partition_start_encounters[mostRecentStartObjectIndex];
                maxEncounterPoint = Math.max(parseInt(maxEncounterPoint), parseInt(mostRecentStartObjectEncounter));
            }
        }
        if (previousMaxStartPoint >= 0) {
            let previousPointPlusDistance = parseInt(previousMaxStartPoint) + parseInt(partitionStart) - parseInt(previousMaxStartPartitionStart);
            maxEncounterPoint = Math.max(parseInt(maxEncounterPoint), parseInt(previousPointPlusDistance));
        }
        if (partitionStart == 0) {
            maxEncounterPoint = Math.max(parseInt(maxEncounterPoint), parseInt(predecessorEnd));
        }
        for (let i = 0; i < limiterStartPointObjects[1].length; i++) {
            let mostRecentStartObjectIndex = limiterStartPointObjects[1][i].partition_start_encounters.length - 1;
            if (mostRecentStartObjectIndex >= 0) {
                limiterStartPointObjects[1][i].partition_start_encounters[mostRecentStartObjectIndex] = maxEncounterPoint;
            }
        }
        previousMaxStartPoint = maxEncounterPoint;
        previousMaxStartPartitionStart = partitionStart;
    });
}
function analyzeLimiterStartObject(node, nodeCopy, limiterStartObject, limiterEndObject, selfNextAvailableStart, predecessorEnd, observedEncounterObj, limitedStartEnd) {
    if (!isRealLimiterStartEncounter(nodeCopy, limiterStartObject))
        return;
    let currentStartEncounter = -1;
    if (limiterStartObject.limited_region_num_threads < limiterStartObject.limited_region_capacity
        && !limiterStartObject.check_prev_iter) { // <-- TODO a little hacky
        // Limited region isn't full yet, proceed as usual
        if (limiterStartObject.partition_start_encounters.length == 0) {
            currentStartEncounter = Math.max(parseInt(selfNextAvailableStart), parseInt(predecessorEnd)) + parseInt(limiterStartObject.partition_start);
        }
        else {
            let lastPartitionStartEncounterIndex = parseInt(limiterStartObject.partition_start_encounters.length) - 1;
            if (node.hasOwnProperty("ii") && !isNaN(parseInt(node.ii))) {
                currentStartEncounter = limiterStartObject.partition_start_encounters[lastPartitionStartEncounterIndex] + parseInt(node.ii);
            }
        }
        if (Object.entries(observedEncounterObj).length == 0) {
            limiterStartObject.partition_start_encounters.push(parseInt(currentStartEncounter));
            limiterStartObject.limited_region_num_threads = parseInt(limiterStartObject.limited_region_num_threads) + 1;
        }
    }
    else {
        let lastStartEncounterIndex = parseInt(limiterStartObject.partition_start_encounters.length) - 1;
        let lastStartEncounter;
        if (lastStartEncounterIndex < 0 || limiterStartObject.partition_start_encounters.length == 0)
            lastStartEncounter = -1;
        else
            lastStartEncounter = limiterStartObject.partition_start_encounters[lastStartEncounterIndex];
        if (limiterEndObject.partition_start_encounters.length > 0) {
            // Need to compare between previous limiterObject.partition_start_encounters + II, and earliest limiter end - accept the latest
            //        -- This is always true though, maybe we don't need this if statement
            // Shift pops it off
            // What if limiterEndObject.partition_start_encounters is empty? Don't shift? Will this happen?
            // SORT limiterEndObject.partition_start_encounters
            limiterEndObject.partition_start_encounters.sort(sortNumber);
            let earliestEndEncounter;
            if (Object.entries(observedEncounterObj).length > 0) { // Observe, don't consume anything
                earliestEndEncounter = limiterEndObject.partition_start_encounters[0];
            }
            else {
                earliestEndEncounter = limiterEndObject.partition_start_encounters.shift();
                limiterStartObject.partition_start_encounters.shift(); // Once you consume an end, consume a start
            }
            if (limiterEndObject.hasOwnProperty("threshold_delay") && !isNaN(parseInt(limiterEndObject.threshold_delay)) && limiterEndObject.threshold_delay > 0) {
                earliestEndEncounter += parseInt(limiterEndObject.threshold_delay);
            }
            let lastStartEncounterPlusII = -1;
            if (node.hasOwnProperty("ii") && !isNaN(parseInt(node.ii)))
                lastStartEncounterPlusII = parseInt(lastStartEncounter) + parseInt(node.ii);
            currentStartEncounter = Math.max(parseInt(lastStartEncounterPlusII), parseInt(earliestEndEncounter));
            if (Object.entries(observedEncounterObj).length == 0) {
                limiterStartObject.partition_start_encounters.push(parseInt(currentStartEncounter)); // Do we need this anymore?
            }
            // Is nodeCopy.start affected?
            // This is here because if the start of the node is not limited, we don't need to move it right?
            // Update limitedStart if so
            if (limiterStartObject.partition_start == 0) {
                console.log("Start is being limited by: " + limiterStartObject.name + " to time: " + currentStartEncounter);
                // If it's already been set by another limiter, check the maximum
                // We initialize this to -1, so we can always do that
                limitedStartEnd.limitedStart = Math.max(parseInt(limitedStartEnd.limitedStart), parseInt(currentStartEncounter));
            }
        }
    }
    if (parseInt(limiterStartObject.partition_start) + parseInt(limiterStartObject.latency) == node.latency) {
        // Limiter reaches the end of the node, should look at its end time
        limitedStartEnd.limitedEnd = Math.max(parseInt(limitedStartEnd.limitedEnd), parseInt(currentStartEncounter) + parseInt(limiterStartObject.latency));
    }
}
function doAllLimiterStartsHaveRequiredInfo(node, nodeCopy) {
    // Check every limiter start
    for (let k = 0; k < node.limiter_start_objects.length; k++) {
        let limiterStartObject = node.limiter_start_objects[k];
        let limiterStartNode = node;
        let limiterEndNode = getNodeFromArray(limiterStartObject.limiter_end_node_id, loopDataNodes);
        let limiterEndObject = limiterEndNode.limiter_end_objects[limiterStartObject.limiter_end_id];
        if (limiterStartObject.check_prev_iter == true) {
            limiterStartObject = nodeCopy.limiter_start_objects_copy[limiterStartObject.id];
            limiterEndObject = nodeCopy.limiter_end_objects_copy[limiterEndObject.id];
        }
        // Check the limiter's parent threads
        if (!isRealLimiterStartEncounter(nodeCopy, limiterStartObject))
            continue;
        // If the limited region is full, then see if there are available ends to grab
        if (limiterStartObject.limited_region_num_threads == limiterStartObject.limited_region_capacity) {
            // There are available ends to grab
            if (limiterEndObject.partition_start_encounters.length > 0) {
                continue;
            }
            else {
                return false;
            }
        }
    }
    return true;
}
function initializeNestedIterDetails(node, parentNestedDetails, parentThreadNum, unspecTripCount, tripCount, isSpeculative, loopTotalLatencyTaskID, ignorePredecessor) {
    // Array of size tripCount, with objects holding each iteration's details
    // Details such as:
    //     Whether this current iteration is speculative
    //     The ID of the task that was created
    parentNestedDetails.children_info[node.id]["nested_iter_details"] = [];
    let scheduleHeaderComplete = true;
    for (let i = 0; i < tripCount; i++) {
        let nestedIterDetail = {};
        let iterationIsSpeculative = isSpeculative;
        if (i >= unspecTripCount) { // Speculative iteration
            iterationIsSpeculative = true;
        }
        nestedIterDetail["speculative"] = iterationIsSpeculative;
        // Make a task that will hold all the scheduled children in this iteration
        let iterationTotalLatencyTask = {};
        Object.keys(node).forEach(function (key) {
            iterationTotalLatencyTask[key] = node[key];
        });
        iterationTotalLatencyTask["loop_node_id"] = node.id;
        iterationTotalLatencyTask["type"] = "nested_iteration";
        iterationTotalLatencyTask["name"] = "Iter#" + i + " (" + node.name + ")";
        iterationTotalLatencyTask["start"] = -1;
        iterationTotalLatencyTask["end"] = -1;
        iterationTotalLatencyTask.id = getAvailableTaskID();
        createTask(iterationTotalLatencyTask, loopTotalLatencyTaskID);
        console.log("Created nested iter task: " + iterationTotalLatencyTask.id);
        nestedIterDetail["iteration_task_id"] = iterationTotalLatencyTask.id;
        parentNestedDetails.children_info[node.id].nested_iter_details.push(nestedIterDetail);
        // Before anything else, call header ONCE with the header object passed in
        // Thread number of parent node
        scheduleHeaderComplete = scheduleNode(node, parentThreadNum, nestedIterDetail.speculative, nestedIterDetail.iteration_task_id, true, nestedIterDetail, {}, i, ignorePredecessor);
        // For nested iterations, we want to be able to access every iteration of its direct child
        // Each child will get a hashmap to store the childrens' iteration threads
        nestedIterDetail['children_info'] = {};
        for (let i = 0; i < node['children'].length; i++) {
            nestedIterDetail['children_info'][node['children'][i]] = {};
            nestedIterDetail['children_info'][node['children'][i]]["iteration_threads"] = [];
            // When the children are scheduled, they will update this map
        }
    }
    return scheduleHeaderComplete;
}
/*
 * This function is to take a node, and schedule its 1+ iteration(s)
 *  For each node copy, you must:
 *      For every partition of the node
 *         1) Determine your start
 *            a) Node's own next available start (if it exists)
 *            b) Can/Should be overriden by the most recent iteration of the predecessor above
 *                Initialized to 0 for first iteration of first block
 *            c) Should be overriden by limiters
 *                If I am a start of a limiter, I should care how many limiter parent threads are in this region
 *                Parent node should hold this counter
 *                - And the associated limiter end encounters, sorted by earliness
 *                Check the end of the limiter end node <capacity> threads ago
 *                Pipelined inner loop - implicit limiter of capacity <interleaving>
 *                - Limiter is for parent loop, starts from <inner loop start> to <inner loop start + II>
 *                - Limiter end is <inner loop start + II>
 *                - Every time the limiter end is encountered, update the associated limiter end encounters, sorted by earliness
 *                -
 *                - EVERY pipelined loop will be segmented this way
 *                Eg. Unpipelined loops will not have limiters? II captured?
 *            d)
 *         2) Determine your end
 *         3) Determine your next BEST available start, in an ideal world - just plus II?
 *
 *   Unpipelined loop: implicit limiter? Or captured in II?
 *  Every node has a fixed latency
 *   If it has children, you deal with that separately
 *   Use II for deciding next start of yourself - if unpipelined, II = latency
 *   You can also potentially decide the start of your children or your successor
 *   Limiters/backpressure
 *   Each node should have an implicit limiter within the node, which is the latency/capacity of the node
 *   Each loop should have an implicit limiter that covers the whole loop
 *  Next start can be and should be modified by limiters right?
 *   Unpipelined loop = limiter throughout the loop, and capacity of 1
 *   eg. Header next start = start + latency
 *       --> Self defined next start
 *       When would the header start be modified? After the header recurses through children, like currently?
 *       Or at the latch? successor = header, modify successor
 *       --> Predecessor defined next start?
 *       --> Limited region defined next start? Could this be the same as predecessor defined?
 *       Unpipelined, listen to predecessor defined? - When do we listen to which
 *       Always listen to limited region?
 *       Inner loop automatically defines a limiter for outer loop - based on interleaving #
 *       End of a limiter defines the start of a limiter block's next start
 *       Backpressure - Defining later start upstream - same as a limiter!
 *       Limiter end - what am I defining the start for? The future thread that will be waiting/stalled
 *   Node has children
 */
function scheduleNode(node, parentThreadNum, isSpeculative, parentTaskID, // parentTaskID: parent ID used to call createTask with
scheduleHeader, headerNestedIterDetail, observedEncounterObj, headerIterNum, ignorePredecessor) {
    if (parentThreadNum === undefined) {
        parentThreadNum = -1;
    }
    if (isSpeculative === undefined) {
        isSpeculative = false;
    }
    if (parentTaskID === undefined) {
        parentTaskID = -1;
    }
    if (scheduleHeader === undefined) {
        scheduleHeader = false;
    }
    if (headerNestedIterDetail === undefined) {
        headerNestedIterDetail = {};
    }
    if (observedEncounterObj === undefined) {
        observedEncounterObj = {};
    }
    if (headerIterNum === undefined) {
        headerIterNum = -1;
    }
    if (ignorePredecessor === undefined) {
        ignorePredecessor = false;
    }
    console.log("Scheduling node: " + node.name + ", Parent node: " + getNodeFromArray(node.parent_id, loopDataNodes).name);
    let parentNestedDetails = getNestedDetails(node.parent_id, parentThreadNum); // Get the nodeCopy of this parent
    // Look at your parentNestedDetails object, if there is already information about your invocation from your parent thread then skip the initialization
    if (!parentNestedDetails.children_info[node.id].hasOwnProperty("invocation_details")) {
        initializeInvocationDetails(node, parentNestedDetails.children_info[node.id], scheduleHeader, parentTaskID);
    }
    let loopTotalLatencyTaskID = parentNestedDetails.children_info[node.id].invocation_details.loop_total_latency_task_id;
    let tripCount = parentNestedDetails.children_info[node.id].invocation_details.speculated_trip_count;
    if (scheduleHeader)
        tripCount = 1;
    let unspecTripCount = parentNestedDetails.children_info[node.id].invocation_details.unspeculated_trip_count;
    // Nested Loops
    if (node.hasOwnProperty('children') && node['children'].length != 0 && !scheduleHeader && node.type == "loop") {
        if (!parentNestedDetails.children_info[node.id].hasOwnProperty("nested_iter_details")) {
            initializeNestedIterDetails(node, parentNestedDetails, parentThreadNum, unspecTripCount, tripCount, isSpeculative, loopTotalLatencyTaskID, ignorePredecessor);
        }
        let nestedIterDetails = parentNestedDetails.children_info[node.id].nested_iter_details;
        // Initialize incomplete nodes to all children
        let incompleteNodes = [];
        for (let i = 0; i < node['children'].length; i++) {
            incompleteNodes.push(node['children'][i]);
        }
        // Continue trying to schedule header if the first iteration didn't succeed
        let allChildrenComplete = true;
        let scheduleComplete = true;
        incompleteNodes.unshift(node.id); // or push?
        while (incompleteNodes.length > 0) {
            let childNode = getNodeFromArray(incompleteNodes.shift(), loopDataNodes);
            // For all outer loop iterations currently active, each outer loop iteration should try to schedule
            // the next interleaved iteration - the earliest one should get their go ahead
            // If there are more than one "earliest" possible, use the priority slots - which outer loop iteration came in first
            // For every new iteration of inner loop, we have to go through every active/interleaved iteration of outer loop
            // Interleaving - return a possible start time (don't consume any limiter ends, just observe)
            // Return nothing if any limiter end hasn't been encountered yet
            if (parseInt(childNode.interleaving) > 1) {
                let priorityArray;
                let nextInLine;
                let earliestStartEncounterIndex;
                let earliestStartEncounter;
                // scheduleNode will schedule one iteration at a time
                // Will want to have a sorted array of prioritized outer loop (self) iterations that are active in the interleaved child
                if (!parentNestedDetails.children_info[node.id].hasOwnProperty("interleaving_details"))
                    parentNestedDetails.children_info[node.id]["interleaving_details"] = {};
                if (!parentNestedDetails.children_info[node.id].interleaving_details.hasOwnProperty("priority_array")) {
                    parentNestedDetails.children_info[node.id].interleaving_details["priority_array"] = [];
                    for (let i = 0; i < parseInt(childNode.interleaving); i++) {
                        if (i < tripCount)
                            parentNestedDetails.children_info[node.id].interleaving_details.priority_array.push(i);
                    }
                }
                if (!parentNestedDetails.children_info[node.id].interleaving_details.hasOwnProperty("next_in_line")) {
                    parentNestedDetails.children_info[node.id].interleaving_details["next_in_line"] = parseInt(childNode.interleaving);
                }
                if (!parentNestedDetails.children_info[node.id].interleaving_details.hasOwnProperty("earliest_start_encounter_index")) {
                    parentNestedDetails.children_info[node.id].interleaving_details["earliest_start_encounter_index"] = -1;
                }
                if (!parentNestedDetails.children_info[node.id].interleaving_details.hasOwnProperty("earliest_start_encounter")) {
                    parentNestedDetails.children_info[node.id].interleaving_details["earliest_start_encounter"] = -1;
                }
                priorityArray = parentNestedDetails.children_info[node.id].interleaving_details.priority_array;
                nextInLine = parentNestedDetails.children_info[node.id].interleaving_details.next_in_line;
                earliestStartEncounterIndex = parentNestedDetails.children_info[node.id].interleaving_details.earliest_start_encounter_index;
                earliestStartEncounter = parentNestedDetails.children_info[node.id].interleaving_details.earliest_start_encounter;
                if (childNode.hasOwnProperty("first_checked") && childNode.hasOwnProperty("check_mode") &&
                    childNode.first_checked == parentThreadNum // We are the first checked
                ) {
                    // Switch it up - if we were in check mode, now try set mode
                    childNode.check_mode = !childNode.check_mode;
                }
                if (!childNode.hasOwnProperty("check_mode"))
                    childNode["check_mode"] = true;
                if (!childNode.hasOwnProperty("first_checked"))
                    childNode["first_checked"] = parentThreadNum;
                if (priorityArray.length > 0) {
                    // 1) If we haven't observed yet, begin observation (looking at just this specific invocation)
                    if (childNode.check_mode) {
                        earliestStartEncounter = -1;
                        earliestStartEncounterIndex = -1;
                        for (let i = 0; i < priorityArray.length; i++) {
                            let outerLoopIteration = priorityArray[i];
                            let nestedIterDetail = nestedIterDetails[outerLoopIteration];
                            // scheduleNode should return the expected start for this first iteration, when being called with "interleaving: observe"
                            // It should not actually change anything 
                            let currObservedEncounterObj = {};
                            currObservedEncounterObj["encounter"] = -1;
                            scheduleNode(childNode, nestedIterDetail.thread_num, nestedIterDetail.speculative, nestedIterDetail.iteration_task_id, false, {}, currObservedEncounterObj);
                            let currObservedEncounter = currObservedEncounterObj.encounter;
                            if (parseInt(currObservedEncounter) < 0)
                                continue;
                            if (parseInt(earliestStartEncounter) >= 0) {
                                // If it's bigger ignore, if it's equal, ignore (we're going down by priority)
                                if (parseInt(currObservedEncounter) < parseInt(earliestStartEncounter)) {
                                    earliestStartEncounter = currObservedEncounter;
                                    earliestStartEncounterIndex = i;
                                }
                            }
                            else {
                                earliestStartEncounter = currObservedEncounter;
                                earliestStartEncounterIndex = i;
                            }
                        }
                        scheduleComplete = false;
                        console.log("Interleaving: Parent thread: " + parentThreadNum);
                        console.log("Interleaving: Earliest start encounter: " + earliestStartEncounter);
                        if (earliestStartEncounter > 0) {
                            if (!childNode.hasOwnProperty("global_earliest_start_encounter")) {
                                childNode["global_earliest_start_encounter"] = earliestStartEncounter;
                                console.log("Interleaving: Setting global earliest start encounter to: " + earliestStartEncounter);
                            }
                            childNode.global_earliest_start_encounter = Math.min(childNode.global_earliest_start_encounter, earliestStartEncounter);
                        }
                    }
                    else {
                        // 2) If we have already observed, decide if this is our time to set
                        if (earliestStartEncounter < 0) {
                            scheduleComplete = false;
                            parentNestedDetails.children_info[node.id].interleaving_details.next_in_line = nextInLine;
                        }
                        else if (earliestStartEncounter > childNode.global_earliest_start_encounter) {
                            scheduleComplete = false;
                        }
                        else {
                            console.log("Interleaving: Setting for parent thread: " + parentThreadNum);
                            // Now we actually set the value
                            let iterationToSet = priorityArray[earliestStartEncounterIndex];
                            let nestedIterDetail = nestedIterDetails[iterationToSet];
                            scheduleComplete = scheduleNode(childNode, nestedIterDetail.thread_num, nestedIterDetail.speculative, nestedIterDetail.iteration_task_id);
                            delete childNode.global_earliest_start_encounter;
                            delete childNode.first_checked;
                            childNode.check_mode = true;
                            // Call scheduleNode with "interleaving: set"
                            if (scheduleComplete == true) {
                                priorityArray.splice(parseInt(earliestStartEncounterIndex), 1);
                                if (parseInt(nextInLine) < parseInt(tripCount)) {
                                    priorityArray.push(nextInLine);
                                    nextInLine = parseInt(nextInLine) + 1;
                                }
                            }
                            if (priorityArray.length > 0)
                                scheduleComplete = false;
                        }
                    }
                }
                parentNestedDetails.children_info[node.id].interleaving_details.next_in_line = nextInLine;
                parentNestedDetails.children_info[node.id].interleaving_details.earliest_start_encounter_index = earliestStartEncounterIndex;
                parentNestedDetails.children_info[node.id].interleaving_details.earliest_start_encounter = earliestStartEncounter;
            }
            else {
                scheduleComplete = true;
                for (let i = 0; i < tripCount; i++) {
                    let nestedIterDetail = nestedIterDetails[i];
                    // Self is header
                    if (childNode.id == node.id)
                        scheduleComplete = scheduleNode(childNode, parentThreadNum, nestedIterDetail.speculative, nestedIterDetail.iteration_task_id, true, {}, {}, i, ignorePredecessor) && scheduleComplete;
                    else
                        scheduleComplete = scheduleNode(childNode, nestedIterDetail.thread_num, nestedIterDetail.speculative, nestedIterDetail.iteration_task_id) && scheduleComplete;
                }
            }
            let parentNode = getNodeFromArray(node.parent_id, loopDataNodes);
            if (!scheduleComplete && isComponentOrFunctionNode(parentNode))
                incompleteNodes.push(childNode.id);
            if (!scheduleComplete)
                allChildrenComplete = false;
        }
        return allChildrenComplete;
    }
    for (let i = 0; i < tripCount; i++) {
        let iterationIsSpeculative = isSpeculative;
        if (i >= unspecTripCount) { // Speculative iteration
            iterationIsSpeculative = true;
        }
        // Make a new copy of the node, or retrieve it if it's been created
        let nodeCopy = {};
        let iterThreadObj = {};
        if ((scheduleHeader == false && parseInt(parentNestedDetails.children_info[node.id].iteration_threads.length) >= parseInt(i) + 1)) {
            iterThreadObj = parentNestedDetails.children_info[node.id].iteration_threads[i];
            // If my start and end have been successfully computed, then move on
            if (iterThreadObj.done == true)
                continue;
            nodeCopy = getNodeCopyThread(node.id, iterThreadObj.thread_num);
        }
        else if (scheduleHeader == true &&
            parseInt(parentNestedDetails.children_info[node.id].iteration_threads.length) >= parseInt(parentNestedDetails.children_info[node.id].invocation_details.speculated_trip_count)) { //parentNestedDetails.children_info[node.id].invocation_details.speculated_trip_count)) {
            iterThreadObj = parentNestedDetails.children_info[node.id].iteration_threads[headerIterNum];
            // If my start and end have been successfully computed, then move on
            if (iterThreadObj.done == true)
                continue;
            nodeCopy = getNodeCopyThread(node.id, iterThreadObj.thread_num);
        }
        else {
            if (scheduleHeader)
                initializeNodeCopy(nodeCopy, node, iterationIsSpeculative, scheduleHeader, parentThreadNum, headerIterNum, parentNestedDetails.children_info[node.id].invocation_details.speculated_trip_count, headerNestedIterDetail);
            else
                initializeNodeCopy(nodeCopy, node, iterationIsSpeculative, scheduleHeader, parentThreadNum, i, tripCount, headerNestedIterDetail);
            iterThreadObj = parentNestedDetails.children_info[node.id].iteration_threads[i];
        }
        if (nodeCopy.hasOwnProperty("start") && nodeCopy.hasOwnProperty("end"))
            continue;
        let selfNextAvailableStart = -1;
        let predecessorEnd = -1;
        let limitedStartEnd = {};
        limitedStartEnd["limitedEnd"] = -1;
        limitedStartEnd["limitedStart"] = -1;
        let stallLessEnd = -1;
        if (debugMode) {
            console.log("\n\t\tMy name is: " + nodeCopy.name);
            console.log("\t\tMy thread number is: " + nodeCopy.own_thread_num);
            console.log("\t\tMy parent thread number is: " + nodeCopy.parent_thread_num);
        }
        // 1) Determine the start of this copy
        //    a) Does this node have intel about the next available start it can support?
        if (node.hasOwnProperty("next_available_start") && node.next_available_start >= 0 && node.interleaving <= 1) { // Just calculate this ourself?
            selfNextAvailableStart = node.next_available_start;
        }
        //    b) Does the predecessor of this node prevent this copy from using the availability from a)?
        let predecessorNode = getPredecessorNode(node.id, loopDataNodes);
        if (!ignorePredecessor && Object.entries(predecessorNode).length > 0) {
            // Get the most recent copy of predecessorNode
            let mostRecentPredecessorNodeCopy = {};
            if (predecessorNode.id == node.parent_id) {
                mostRecentPredecessorNodeCopy = getNodeCopyThread(predecessorNode.id, parentThreadNum);
            }
            else {
                // Go to parent thread
                // Go to its children, find the predecessor_id's last iteration, and grab it
                if (parentNestedDetails.children_info[node.predecessor_id]["iteration_threads"].length > 0 &&
                    parentNestedDetails.children_info[node.predecessor_id]["iteration_threads"].length ==
                        parentNestedDetails.children_info[node.predecessor_id].invocation_details.speculated_trip_count) { // Should probably be == to tripCount
                    let lastPredecessorIndex = parentNestedDetails.children_info[node.predecessor_id].invocation_details.unspeculated_trip_count - 1;
                    // Find the predecessor copy of the same parent thread, and same iteration number as yourself
                    let lastPredecessorThreadNum = parentNestedDetails.children_info[node.predecessor_id]["iteration_threads"][lastPredecessorIndex].thread_num;
                    // Analyze the predecessor, and get the copy of the latest element in it
                    mostRecentPredecessorNodeCopy = getLatestElementOfThread(predecessorNode.id, lastPredecessorThreadNum);
                }
            }
            if (Object.entries(mostRecentPredecessorNodeCopy).length > 0) {
                if (!mostRecentPredecessorNodeCopy.hasOwnProperty("end")) {
                    if (debugMode)
                        console.log("Predecessor isn't done yet");
                    return false; // || isNaN(mostRecentPredecessorNodeCopy.end)
                }
                // If most recent copy of predecessorNode ends later than node.next_available_start, shift nodeCopy.start
                predecessorEnd = mostRecentPredecessorNodeCopy.end;
            }
            else if (!isComponentOrFunctionNode(predecessorNode)) {
                if (debugMode)
                    console.log("Predecessor isn't done yet");
                return false;
            }
        }
        //    c) Does this node contain the start of a limited region? 
        //          Is the region full?
        //              If so, find the endpoint of the limiter (should this be stored in this node?), and check its earliest encounter
        //                  The earliest endpoint encounter
        //              If not, proceed as usual
        if (node.hasOwnProperty("limiter_start_objects")) {
            initializeLimiterObjectCopies(node, nodeCopy);
            if (!doAllLimiterStartsHaveRequiredInfo(node, nodeCopy)) {
                if (debugMode)
                    console.log("Limiter starts do not all have required info");
                return false;
            }
            for (let k = 0; k < node.limiter_start_objects.length; k++) {
                let limiterStartObject = node.limiter_start_objects[k];
                let limiterStartNode = node;
                let limiterEndNode = getNodeFromArray(limiterStartObject.limiter_end_node_id, loopDataNodes);
                let limiterEndObject = limiterEndNode.limiter_end_objects[limiterStartObject.limiter_end_id];
                if (limiterStartObject.check_prev_iter == true) {
                    limiterStartObject = nodeCopy.limiter_start_objects_copy[limiterStartObject.id];
                    let nodeCopyPrevIter = getPreviousIteration(nodeCopy); // Go to your parent node, find the thread number of your node's last iteration
                    if (Object.entries(nodeCopyPrevIter).length == 0)
                        continue;
                    else
                        limiterEndObject = nodeCopyPrevIter.limiter_end_objects_copy[limiterEndObject.id];
                }
                analyzeLimiterStartObject(node, nodeCopy, limiterStartObject, limiterEndObject, selfNextAvailableStart, predecessorEnd, observedEncounterObj, limitedStartEnd);
            }
            if (Object.entries(observedEncounterObj).length == 0)
                reanalyzeLimiterStartObject(node, nodeCopy, predecessorEnd);
        }
        if (Object.entries(observedEncounterObj).length > 0) {
            observedEncounterObj.encounter = Math.max(selfNextAvailableStart, predecessorEnd, limitedStartEnd.limitedStart);
            if (debugMode)
                console.log("Observing start: " + observedEncounterObj.encounter);
            return false;
        }
        // Determine the latest value of these possible start times
        nodeCopy.start = Math.max(selfNextAvailableStart, predecessorEnd, limitedStartEnd.limitedStart);
        // 2) Determine the end of this copy
        // Observing when each limiter end is reached for the current thread
        if (node.hasOwnProperty("limiter_end_objects")) {
            let limiter_end_objects_values = Object.keys(node.limiter_end_objects).map(function (key) {
                return node.limiter_end_objects[key];
            });
            limiter_end_objects_values.forEach(function (limiterEndObject) {
                let limiterEndNode = node;
                let limiterStartNode = getNodeFromArray(limiterEndObject.limiter_start_node_id, loopDataNodes);
                let limiterStartObject = getNodeFromArray(limiterEndObject.limiter_start_id, limiterStartNode.limiter_start_objects, true);
                let currentEncounter;
                // We ignore all other limiters for check_prev_iter
                // Is this safe? What if there is a stall happening before this point?
                if (limiterEndObject.check_prev_iter) {
                    currentEncounter = nodeCopy.start + limiterEndObject.partition_start;
                }
                else {
                    // If this is an end limiter, I need to update the encounter point
                    // Check the last start limiter before this end limiter (in the same node), then add the distance from it to the last encounter of the last start limiter
                    let lastStallPointStart = -1;
                    if (limiterEndObject.last_start_point == 0 && (!limiterEndNode.hasOwnProperty("limiter_start_objects_map_by_startpoint") || !limiterEndNode.limiter_start_objects_map_by_startpoint.hasOwnProperty(0))) {
                        lastStallPointStart = nodeCopy.start;
                    }
                    else {
                        let startObjectsArrLength = limiterEndNode.limiter_start_objects_map_by_startpoint[limiterEndObject.last_start_point].length;
                        for (let i = 0; i < startObjectsArrLength; i++) {
                            let startObject = limiterEndNode.limiter_start_objects_map_by_startpoint[limiterEndObject.last_start_point][i];
                            let lastStartEncounterIndex = parseInt(startObject.partition_start_encounters.length) - 1; // Expected to be 0, should only have one element
                            if (lastStartEncounterIndex >= 0)
                                lastStallPointStart = Math.max(parseInt(lastStallPointStart), parseInt(startObject.partition_start_encounters[lastStartEncounterIndex])); // Last/Most recent one (do we even need the ones before that)
                        }
                    }
                    if (limiterEndObject.last_start_point == 0) {
                        lastStallPointStart = Math.max(parseInt(lastStallPointStart), parseInt(nodeCopy.start));
                    }
                    let distanceFromLastStallPoint = limiterEndObject.distance_from_last_start_point;
                    currentEncounter = parseInt(lastStallPointStart) + parseInt(distanceFromLastStallPoint);
                }
                let limiterStartInstanceThreadNum = isLastInstanceOfLimiterEnd(nodeCopy, limiterEndObject); // Returns limiter parent thread number
                if (parseInt(limiterStartInstanceThreadNum) >= 0) {
                    if (limiterStartObject.check_prev_iter) {
                        nodeCopy.limiter_end_objects_copy[limiterEndObject.id].partition_start_encounters.push(parseInt(currentEncounter));
                    }
                    else {
                        limiterEndObject.partition_start_encounters.push(parseInt(currentEncounter));
                    }
                }
            });
        }
        // Stall-less end = if none of the stall points in the node had been stalled
        stallLessEnd = parseInt(nodeCopy.start) + parseInt(node.latency);
        nodeCopy.end = Math.max(limitedStartEnd.limitedEnd, stallLessEnd);
        // 3) Determine the next best available start for this node
        if (node.hasOwnProperty("ii") && !isNaN(parseInt(node.ii)))
            node.next_available_start = nodeCopy.start + node.ii;
        else
            node.next_available_start = nodeCopy.start + node.latency; // If there's no II details, assume II = latency
        nodeCopy.next_available_start = node.next_available_start;
        if (node.type == "loop" && !scheduleHeader)
            nodeCopy.id = getAvailableTaskID();
        else if (scheduleHeader == true)
            nodeCopy.id = getAvailableTaskID();
        else
            nodeCopy.id = getAvailableTaskID();
        if (node.type == "loop" && scheduleHeader)
            nodeCopy["name"] = "Header (" + nodeCopy.name + ")";
        if (node.type == "loop_latch")
            nodeCopy["name"] = "Latch (" + nodeCopy.name + ")";
        if (node.type == "loop" && !scheduleHeader) {
            if (nodeCopy.type == "speculation") {
                nodeCopy["name"] = "Speculated Iter (" + nodeCopy.name + ")";
            }
            else {
                nodeCopy["type"] = "iteration";
                nodeCopy["name"] = "Iter#" + i + " (" + nodeCopy.name + ")";
            }
        }
        else {
            nodeCopy["type"] = "regular";
        }
        if (node.type == "loop" && !scheduleHeader) {
            if (debugMode)
                console.log("\t\tLOOP, NOT SCHEDULING A HEADER");
            createTask(nodeCopy, loopTotalLatencyTaskID);
        }
        else {
            if (debugMode)
                console.log("\t\tSCHEDULING A HEADER OR OTHER");
            createTask(nodeCopy, parentTaskID);
        }
        if (debugMode) {
            console.log("\t\tMy start is: " + nodeCopy.start);
            console.log("\t\tMy end is: " + nodeCopy.end);
            console.log("\n");
        }
        if (node.type == "loop" && !scheduleHeader) {
            if (i == 0) {
                parentNestedDetails.children_info[node.id].invocation_details.loop_total_latency_task_obj.setStart(nodeCopy.start);
            }
            if (i == unspecTripCount - 1) {
                parentNestedDetails.children_info[node.id].invocation_details.loop_total_latency_task_obj.setEnd(nodeCopy.end); // Doesn't work if smaller than children end
                parentNestedDetails.children_info[node.id].invocation_details.loop_total_latency_task_obj.setGroupMinEnd(nodeCopy.end);
            }
            console.log("debEuge: total latency start: " + parentNestedDetails.children_info[node.id].invocation_details.loop_total_latency_task_obj.getStart());
            console.log("debEuge: total latency end: " + parentNestedDetails.children_info[node.id].invocation_details.loop_total_latency_task_obj.getEnd());
        }
        maxCycle = Math.max(maxCycle, nodeCopy.end);
        iterThreadObj.done = true;
        // Only schedule one iteration at a time for interleaved loops
        if (parseInt(node.interleaving) > 1 && i < (parseInt(tripCount) - 1))
            return false;
    }
    return true; // After all iterations are scheduled
}
/*
 * Initializing a trip count node, containing details about its own trip count, as well as any children
 * Node: Key = Trip Count
 *       loopID = loop ID
 *       Children = If this node has child loops, have <# of children> = <# child loops> * <Trip Count (Key)>
 *                                                           parentTCNode can be fetched using tripCountNodeMap[parentID].last
 */
function initializeTripCountTreeNode(ownLoopNode, tripCount, parentTCNode) {
    if (parentTCNode === undefined) {
        parentTCNode = {};
    }
    let tripCountNode = {};
    tripCountNode["trip_count"] = tripCount;
    tripCountNode['children'] = {};
    tripCountNode['id'] = ownLoopNode.id;
    // Checking if parentTCNode == {} or not, proceed if not
    if (Object.entries(parentTCNode).length > 0) {
        if (!parentTCNode['children'].hasOwnProperty(ownLoopNode.id))
            parentTCNode['children'][ownLoopNode.id] = [];
        parentTCNode['children'][ownLoopNode.id].push(tripCountNode);
    }
    if (!tripCountNodeMap.hasOwnProperty(ownLoopNode.id))
        tripCountNodeMap[ownLoopNode.id] = [];
    tripCountNodeMap[ownLoopNode.id].push(tripCountNode);
}
/*
 * Use trip count to determine number of children trip count nodes are necessary
*/
function fillupTripCountTreeNode(tripCountNode) {
    if (Object.entries(tripCountNode['children']) == 0)
        return;
    let tripCount = tripCountNode.trip_count;
    for (let childID in tripCountNode['children']) {
        // For every subloop, make sure there are enough trip count nodes
        if (parseInt(tripCountNode['children'][childID].length) < tripCount) {
            let savedLength = tripCountNode['children'][childID].length;
            let lastTCNode = tripCountNode['children'][childID][savedLength - 1];
            for (let i = savedLength; i < tripCount; i++) {
                tripCountNode['children'][childID].push(lastTCNode); // A bunch of references should be fine...?
            }
        }
        else if (parseInt(tripCountNode['children'][childID].length) > tripCount) {
            let savedLength = tripCountNode['children'][childID].length;
            for (let i = tripCount; i < savedLength; i++) {
                tripCountNode['children'][childID].pop(); // Remove last element
            }
        } // Do nothing if they're equal  
    }
    for (let childID in tripCountNode['children']) {
        for (let i = 0; i < tripCount; i++) {
            fillupTripCountTreeNode(tripCountNode['children'][childID][i]);
        }
    }
}
/*
 *
 */
function updateLoopNodeTripCounts(tripCountNode) {
    // Traverse the tripCountNodeMap
    // For each TCnode:
    //    Check the loop node ID, get loop node
    let loopNode = getNodeFromArray(tripCountNode.id, loopDataNodes);
    //    Push the TCnode onto the loop node's trip_count_nodes array
    if (!loopNode.hasOwnProperty("trip_count_nodes"))
        loopNode["trip_count_nodes"] = [];
    loopNode.trip_count_nodes.push(tripCountNode);
    // Recurse for every subloop and invocations of each subloop
    for (let childID in tripCountNode['children']) {
        for (let i = 0; i < tripCountNode['children'][childID].length; i++) {
            updateLoopNodeTripCounts(tripCountNode['children'][childID][i]);
        }
    }
}
/*
 * After initializeTripCountTreeNode has been called for every provided trip count
 */
function postProcessTripCountTree(outerMostLoopTCNodeArray) {
    // For every outermost loop's TCNode:
    for (let i = 0; i < outerMostLoopTCNodeArray.length; i++) {
        let outerMostTCNode = outerMostLoopTCNodeArray[i];
        // Fill up the trip count tree
        fillupTripCountTreeNode(outerMostTCNode);
        // Go through trip count tree, and populate data in loop nodes
        updateLoopNodeTripCounts(outerMostTCNode);
    }
}
/*
 * Only called on first round (before user inputted trip counts are used)
 * Input array loopNodeIDTripCountPairs is expected to be in order of loop hierarchy
 */
function initializeTripCounts(loopNodeIDTripCountPairs) {
    tripCountNodeMap = {};
    let outerMostLoopTCNodeArray = [];
    let loopNodesToAnalyze = [];
    for (let i = 0; i < loopNodeIDTripCountPairs.length; i++) {
        let loopNodeIDTripCountPair = loopNodeIDTripCountPairs[i];
        let newLoopNodeTripCountPair = {};
        newLoopNodeTripCountPair["loop_node"] = getNodeFromArray(loopNodeIDTripCountPair.loop_node_id, loopDataNodes);
        newLoopNodeTripCountPair["trip_count"] = loopNodeIDTripCountPair.trip_count;
        loopNodesToAnalyze.push(newLoopNodeTripCountPair);
    }
    if (loopNodesToAnalyze.length == 0)
        loopNodesToAnalyze = loopDataNodes;
    // For every provided trip count (initialize to 1 for each)
    for (let i = 0; i < loopNodesToAnalyze.length; i++) {
        let loopNodeObj = loopNodesToAnalyze[i];
        let loopNode = {};
        let tripCount = 1; // initialize all loops to trip count 1 if not known
        if (loopNodeObj.hasOwnProperty("loop_node") && loopNodeObj.hasOwnProperty("trip_count")) {
            loopNode = loopNodeObj.loop_node;
            tripCount = loopNodeObj.trip_count;
        }
        else {
            loopNode = loopNodeObj;
            let loopNodeTripCount = parseInt(loopNode.tc);
            if ((isNaN(loopNodeTripCount) || loopNodeTripCount <= 0) &&
                (loopNode.hasOwnProperty('children') && loopNode['children'].length > 1)) {
                let loopLatch = getNodeFromArray(loopNode['children'][loopNode['children'].length - 1], loopDataNodes);
                loopNodeTripCount = parseInt(loopLatch.tc);
                loopNode.tc = loopLatch.tc;
            }
            if (!isNaN(loopNodeTripCount) && loopNodeTripCount > 0) {
                tripCount = loopNodeTripCount;
            }
        }
        // Convert "threshold_no_delay" flag from Loop Attributes to bool, and invert
        loopNode["threshold_delay"] = loopNode.tn == "0" ? 1 : 0;
        if (loopNode.type != "loop")
            continue;
        console.log("Initializing Trip Count: " + loopNode.name + ", trip count = " + tripCount);
        if (loopNode.ll == 1) {
            // Outermost loop, no parent TC node
            initializeTripCountTreeNode(loopNode, tripCount);
            outerMostLoopTCNodeArray.push(tripCountNodeMap[loopNode.id][0]); // The TCNode that was just created
        }
        else { // parentTCNode can be fetched using tripCountNodeMap[parentID].last
            initializeTripCountTreeNode(loopNode, tripCount, tripCountNodeMap[loopNode.parent_id][tripCountNodeMap[loopNode.parent_id].length - 1]);
        }
    }
    postProcessTripCountTree(outerMostLoopTCNodeArray);
}
function populateIterations(loopNodeIDTripCountPairs, selectedLoopID) {
    if (selectedLoopID === undefined) {
        selectedLoopID = -1;
    }
    // For every provided trip count (initialize to 1 for each)
    initializeTripCounts(loopNodeIDTripCountPairs);
    preProcessNodes();
    let outerMostLoopNodeIDs = [];
    for (let i = 0; i < loopDataNodes.length; i++) {
        let loopNode = loopDataNodes[i];
        if (isComponentOrFunctionNode(loopNode)) {
            loopNode["start"] = -1;
            loopNode["end"] = -1;
            loopNode["nested_iter_detail"] = {};
            loopNode.nested_iter_detail["children_info"] = {};
            // Don't make if not selected
            if (selectedLoopID < 0)
                createTask(loopNode, 0);
            loopNode["threads"] = [];
            loopNode.threads.push(loopNode);
            if (debugMode)
                console.log("Component Node: " + loopNode.id);
            continue;
        }
        // If parent is component, initialize iteration threads
        if (loopNode.ll == 1) { // If parent is component?
            let componentNode = getNodeFromArray(loopNode.parent_id, loopDataNodes);
            if (debugMode)
                console.log("Parent ID:" + loopNode.parent_id + "  Parent type: " + componentNode.type);
            componentNode.nested_iter_detail.children_info[loopNode.id] = {};
            componentNode.nested_iter_detail.children_info[loopNode.id]["iteration_threads"] = [];
            outerMostLoopNodeIDs.push(loopNode.id);
            // If predecessor is a component or function, then initialize its next_available_start
            if (isComponentOrFunctionNode(getPredecessorNode(loopNode.id, loopDataNodes))) {
                loopNode["next_available_start"] = 0;
            }
        }
    }
    if (parseInt(selectedLoopID) > 0) {
        let loopNode = getNodeFromArray(selectedLoopID, loopDataNodes);
        if (isComponentOrFunctionNode(loopNode)) {
            createTask(loopNode, 0);
            for (let i = 0; i < loopNode['children'].length; i++) {
                let loopNodeChild = getNodeFromArray(loopNode['children'][i], loopDataNodes);
                scheduleNode(loopNodeChild, 0, false, loopNodeChild.parent_id);
            }
        }
        else {
            let parentNode = getNodeFromArray(loopNode.parent_id, loopDataNodes);
            parentNode["start"] = -1;
            parentNode["end"] = -1;
            parentNode["nested_iter_detail"] = {};
            parentNode.nested_iter_detail["children_info"] = {};
            parentNode.nested_iter_detail.children_info[loopNode.id] = {};
            parentNode.nested_iter_detail.children_info[loopNode.id]["iteration_threads"] = [];
            parentNode["threads"] = [];
            parentNode.threads.push(parentNode);
            loopNode["next_available_start"] = 0;
            scheduleNode(loopNode, 0, false, 0, false, {}, {}, -1, true);
        }
    }
    else {
        for (let i = 0; i < outerMostLoopNodeIDs.length; i++) {
            let loopNode = getNodeFromArray(outerMostLoopNodeIDs[i], loopDataNodes);
            scheduleNode(loopNode, 0, false, loopNode.parent_id);
        }
    }
    return;
}
/**
 * @function getNodeIndex find the index of a non fictitious node in scheduleData list.
 * @param {Integer} nodeID id of the node.
 * @returns the index of a real node if exist, -1 otherwise.
 */
function getNodeIndex(nodeKey, dataSet, isName) {
    if (isName === undefined) {
        isName = false;
    }
    for (let di = 0; di < dataSet.length; di++) {
        let node = dataSet[di];
        if (node.hasOwnProperty("name") && node.name.toString() === nodeKey.toString()) {
            return di;
        }
        if (node.hasOwnProperty('id') && node.id.toString() === nodeKey.toString()) {
            return di;
        }
        if (parseInt(node.id) === parseInt(nodeKey)) {
            return di;
        }
    }
    return -1;
}
