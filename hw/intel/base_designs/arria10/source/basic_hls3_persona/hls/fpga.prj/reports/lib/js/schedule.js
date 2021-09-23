"use strict";
// Global variable:
// Commonly used by HLD report
var scheduleViewerColorTypeDictBeta = {
    'kernel': 'ggroupblack',
    'bb': 'gtaskblue',
    'cluster': 'gtaskgreen',
    'inst': 'gtaskyellow',
    'speculation': 'gtaskred',
    'iteration': 'gtaskpurple'
};
var vScheduleGantt; // gantt chart
var vScheduleFuncData; // selected function data
// ************* schdule viewer (beta) ***************************
/**
 * @function changeBarDetailsBeta callback to change details
 * @param {JSGantt.TaskItem} taskItem for changing the information in the details
 */
function changeBarDetailsBeta(taskItem) {
    if (taskItem instanceof JSGantt.TaskItem) {
        // We have to check innerHTML, as empty notes by default from jsgantt
        // is <span class="gTaskNotes"></span>
        var details = taskItem.getNotes().innerHTML;
        if (details) {
            document.getElementById("details").innerHTML = details;
        }
        else {
            clearDivContent();
        }
    }
}
function createItemFromNode(node, parentId, g) {
    // Create new bar
    let nodeColor = (scheduleViewerColorTypeDictBeta.hasOwnProperty(node.type)) ? scheduleViewerColorTypeDictBeta[node.type] : "ggroupblack";
    let nodeDebug = (hasDebug(node)) ? createDebugLocation(getFirstDebug(node)).outerHTML : " - ";
    let pGroup = "", pOpen = 1;
    let nodeStart;
    let nodeEnd;
    let details = getDetails(node);
    let nodeDetails = "";
    if (details)
        nodeDetails = getHTMLDetailsFromJSON(details, node['name']);
    // Some basic error checking and hack for now
    if (node.hasOwnProperty("start") && node.hasOwnProperty("end")) {
        if (isNaN(node.start) || isNaN(node.end)) {
            console.log("Error! Data error: start cycle or latency is not a number: " + node.name);
            return; // don't add to avoid crashing
        }
        nodeStart = parseInt(node.start);
        nodeEnd = parseInt(node.end);
        if (!node.hasOwnProperty("children")) { // Only check for start and end when it is lowest hierarchy
            if (nodeStart < -1 || nodeEnd < -1) { //accept start and end =-1 (for top most parent)
                console.log("Error! Data error: negative start cycle or latency: " + node.name);
                return; // don't add to avoid crashing
            }
            if (nodeStart === nodeEnd && nodeStart != -1) {
                // Temporary workaround by setting the latency to 1/2 clock cycle
                nodeEnd = nodeStart + 1;
            }
        }
    }
    else {
        console.log("Warning! Node has no start and end " + node.name);
        return; // don't add
    }
    pGroup = (node.hasOwnProperty("children") ? 1 : 0); // Update pGroup=1 (collapsible) if node is a parent
    let vDepend = (node.hasOwnProperty('depend')) ? node.depend : '';
    // Parameters                    (  pID,    pName,      pStart,    pEnd,     pStyle,   pLink  pMile, pRes,       pComp,  pGroup,   pParent,  pOpen, pDepend, pCaption,  pNotes,   pGantt))
    g.AddTaskItem(new JSGantt.TaskItem(node.id, node.name, nodeStart, nodeEnd, nodeColor, '', 0, nodeDebug, 0, pGroup, parentId, pOpen, vDepend, '', nodeDetails, g));
}
function flattenObjBeta(node, nodeIDSrcDict, parentId, g) {
    if (nodeIDSrcDict.hasOwnProperty(node['id'])) {
        node['depend'] = nodeIDSrcDict[node['id']];
    }
    createItemFromNode(node, parentId, g);
    // recursively call it's children
    if (node.hasOwnProperty("children")) {
        node['children'].forEach(function (childObj) {
            flattenObjBeta(childObj, nodeIDSrcDict, node.id, g); //node.id is parent ID of the child
        });
    }
}
function createNodeLinkDict(scheduleLinks) {
    let nodeIDSrcDict = {}; // key=ID, value=sources (comma separated it)
    scheduleLinks.forEach(function (e) {
        if (e.hasOwnProperty('from') && e.hasOwnProperty('to')) {
            let nodeID = e['to'];
            if (!nodeIDSrcDict.hasOwnProperty(nodeID)) {
                nodeIDSrcDict[nodeID] = e['from'];
            }
            else {
                nodeIDSrcDict[nodeID] += ',' + e['from'];
            }
        }
    });
    return nodeIDSrcDict;
}
function flattenScheduleJSONBeta(scheduleDataJSON, funcNode, g) {
    //create the function bar item
    let schFuncNode = { "name": funcNode[0].name,
        "id": funcNode[0].id,
        "start": -1,
        "end": -1,
        "type": funcNode[0].type,
        "children": 1
    };
    createItemFromNode(schFuncNode, 0, g); // insert to the top most of the list, parentId =0
    // parse the links create map for ease of look up
    let nodeIDSrcDict;
    if (scheduleDataJSON.hasOwnProperty('links') && Array.isArray(scheduleDataJSON['links'])) {
        nodeIDSrcDict = createNodeLinkDict(scheduleDataJSON['links']);
    }
    scheduleDataJSON['nodes'].forEach(function (node) {
        flattenObjBeta(node, nodeIDSrcDict, schFuncNode.id, g);
    });
}
/**
 * @function renderSchedule clears everything that was there and restart the whole graph
 *
 * @param {Object} scheduleDataJSON is a list of children nodes for a given C++ function level
 * @param {Integer} chartID the ID selected from tree.
 */
function renderScheduleBeta(scheduleDataJSON, chartID) {
    // error and update check
    if (chartID !== undefined && top_node_id === chartID)
        return; // do nothing if user clicks the same ID
    top_node_id = chartID;
    // Clear details pane before rendering
    clearDivContent();
    let CID = getViewerConst().gid;
    let graphDiv = document.getElementById(CID);
    if (scheduleDataJSON === undefined || scheduleDataJSON.nodes === undefined || scheduleDataJSON['nodes']['length'] === 0) {
        if (scheduleDataJSON['message']) {
            renderNoGraphForType(graphDiv, '', 'message', '', scheduleDataJSON['message']);
        }
        else {
            renderNoGraphForType(graphDiv, '', 'no_nodes', '');
        }
        $('.card-header #layers*').html('');
        return;
    }
    // Format the data for the first time
    let max_cycle = 0;
    let min_cycle = 0;
    vScheduleGantt = new JSGantt.GanttChart(graphDiv, 1);
    var centerPaneWidth = (CID != null && $('#' + CID).width() > 200 ? $('#' + CID).width() : 200); // This is just an error handling, take width=200 if it's smaller than 200px
    // Render schedule viewer beta
    if (vScheduleGantt.getDivId() != null) {
        vScheduleGantt.setNotesCallback(changeBarDetailsBeta); // Set up callback for show details when bar is clicked
        vScheduleGantt.setShowRes(0);
        vScheduleGantt.setShowDebugLoc(1);
        vScheduleGantt.setShowDur(0);
        vScheduleGantt.setShowComp(0);
        vScheduleGantt.setShowStartDate(0);
        vScheduleGantt.setShowEndDate(0);
        vScheduleGantt.setShowStartCycle(0);
        vScheduleGantt.setShowEndCycle(0);
        vScheduleGantt.setCaptionType('Complete'); // Set to Show Caption (None,Caption,Resource,Duration,Complete)
        vScheduleGantt.setQuarterColWidth(36);
        vScheduleGantt.setShowTaskInfoLink(1); // Show link in tool tip (0/1)
        vScheduleGantt.setShowEndWeekDate(0); // Show/Hide the date for the last day of the week in header for daily view (1/0)
        vScheduleGantt.setUseSingleCell(10000); // Set the threshold at which we will only use one cell per table row (0 disables).  Helps with rendering performance for large charts.
        vScheduleGantt.setUseZoom(1);
        vScheduleGantt.setTotalHeight("100%");
        vScheduleGantt.setUseSort(0);
        vScheduleGantt.setLastHeadingRow(0); // Flag to show/hide the minor heading at the last row
        var funcNode = $.grep(treeJSON.nodes, function (a) { return a.id == chartID; });
        flattenScheduleJSONBeta(scheduleDataJSON, funcNode, vScheduleGantt);
        scheduleDataJSON['nodes'].filter(function (node) {
            return node.type.indexOf("bb") > -1;
        }).forEach(function (node) {
            if (parseInt(node.end) > max_cycle) {
                max_cycle = parseInt(node.end);
            }
        });
        // Save the selected Function for bottleneck visualization later
        vScheduleFuncData = scheduleDataJSON;
        // Calculate total latency size base on min_cycle and max_cycle
        var latencySize = (max_cycle > min_cycle ? max_cycle - min_cycle : 0);
        if (latencySize <= 0) {
            $('#' + CID).html("Screen size too small to load data.");
            return;
        }
        else {
            vScheduleGantt.setFormatArr.apply(vScheduleGantt, createGanttZoomList(latencySize, vScheduleGantt.getCycleColWidth(), centerPaneWidth));
            vScheduleGantt.setFormat(vScheduleGantt.getFormatArr()[vScheduleGantt.getFormatArr().length - 1]); //use the last element in zoomLevelAry to zoom in full
        }
        vScheduleGantt.Draw();
        showTruncatedTooltip();
    }
    else {
        console.log("Warning! Fail initialize Gantt Chart.");
    }
    return;
}
function createGanttZoomList(latency, cycleColWidth, divWidth) {
    var zoomLevelList = new Array();
    var curZoom = 1;
    zoomLevelList.push(curZoom);
    var rightSpace = (divWidth / 2); // taking 50% of the parent's width (as minus the left panel, as well as paddings)
    var numOfCols = parseInt(rightSpace / cycleColWidth) - 1; // divide by clock cycle width, 1 clockCycleCol=18px
    if (latency > numOfCols) {
        var numOfLatencyPerCol = parseInt(latency / numOfCols);
        while (curZoom * 2 < numOfLatencyPerCol) {
            curZoom *= 2;
            zoomLevelList.push(curZoom);
        }
        zoomLevelList.push(numOfLatencyPerCol); // for zoom-in-full, so that it could be nicely fit in right panel/space
    }
    return zoomLevelList;
}
function showTruncatedTooltip() {
    $(document).on('mouseover', ".truncatedtooltip", function () {
        var $this = $(this);
        $this.tooltip({
            title: $this.text(),
            placement: "top"
        });
        $this.tooltip('show');
    });
}
function removeBottleneck(pSelBottleneck) {
    let vStartCycle = pSelBottleneck['start'];
    let vEndCycle = pSelBottleneck['end'];
    vScheduleGantt.removeVerticalLine(vStartCycle);
    vScheduleGantt.removeVerticalLine(vEndCycle);
}
function addBottleneck(pBottleneck) {
    // Add veritial line if the schedule viewer contains the bottleneck
    // Error check: nothing is selected
    if (!vScheduleFuncData)
        return;
    // The format of the bottleneck is a list of nodes. Element 0 is the start and last 
    // element is the end. The start and end is relative to the block. The schedule
    // viewer uses timescale at the function scope.
    // Use the parent of start and end node to the scheduled cycle.
    // TODO: Fix block ID in schedule viewer so it's identical to bottleneck instead of using name
    // for comparison.
    let vBottleneckNodes = pBottleneck['nodes'];
    let vStartNode = vBottleneckNodes[0];
    let vStartLoopName = vStartNode['parent']; // Loop header block name
    let vStartLoopRe = new RegExp(vStartLoopName);
    let vEndNode = vBottleneckNodes[vBottleneckNodes.length - 1];
    let vEndLoopName = vEndNode['parent']; // Loop latch block name
    let vEndLoopRe = new RegExp(vEndLoopName);
    let vLimiter = (pBottleneck['type'] === 'Occupancy limiter') ? true : false;
    let vStartCycle, vEndCycle;
    vStartCycle = vEndCycle = -1;
    let vNodeList = vScheduleFuncData['nodes'];
    for (let ni = 0; ni < vNodeList.length; ni++) {
        // find the start and end cycle for the bottleneck
        if (vNodeList[ni]['name'].match(vStartLoopRe)) {
            vStartCycle = parseInt(vNodeList[ni]['start']) + Math.floor(parseFloat(vStartNode['start']));
        }
        if (vNodeList[ni]['name'].match(vEndLoopRe)) {
            vEndCycle = parseInt(vNodeList[ni]['start']) + Math.floor(parseFloat(vEndNode['end']));
            // TODO: we are missing one clock cycle for fMAX/II limiter
            vEndCycle = (vLimiter) ? vEndCycle : vEndCycle + 1;
        }
        if (vStartCycle >= 0 && vEndCycle > 0)
            break;
    }
    // do nothing if this not the right function
    if (vStartCycle < 0 || vEndCycle < 0)
        return;
    let vScheduleLimiter = {
        'start': vStartCycle,
        'end': vEndCycle
    };
    // Always add the bottleneck with a pair of vertical lines
    vScheduleGantt.addVerticalLine(vStartCycle);
    vScheduleGantt.addVerticalLine(vEndCycle);
    return vScheduleLimiter;
}
function redrawSchedule() {
    // clear everything and redraw all the node with edges
    vScheduleGantt.Draw();
    vScheduleGantt.updateVerticalLines();
}
function showTruncatedToolTip() {
    $(document).on('mouseover', ".truncatedtooltip", function () {
        var $this = $(this);
        if (this.offsetWidth < this.scrollWidth) {
            $this.tooltip({
                title: $this.text(),
                placement: "top"
            });
            $this.tooltip('show');
        }
    });
}
