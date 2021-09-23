'use strict';
// disable JSHint warning: Use the function form of 'use strict'.
// This warning is meant to prevent problems when concatenating scripts that
// aren't strict, but we shouldn't have any of those anyway.
/* jshint -W097 */
var GRAPH_MESSAGE_PREFIX = "<div id='graph_message' style='height:150px;width:100%;display:table;text-align:center;'><span style='vertical-align:middle;display:table-cell;'>";
var GRAPH_MESSAGE_SUFFIX = '</span></div>';
var GRAPH_LOADING_DIV = GRAPH_MESSAGE_PREFIX + 'Loading...' + GRAPH_MESSAGE_SUFFIX;
var OPT_AS_REG_DIV = GRAPH_MESSAGE_PREFIX + 'This variable was implemented in registers.' + GRAPH_MESSAGE_SUFFIX;
var UNSYNTH_DIV = GRAPH_MESSAGE_PREFIX + 'All uses have been optimized away; this variable was not synthesized.' + GRAPH_MESSAGE_SUFFIX;
var UNTRACK_DIV = GRAPH_MESSAGE_PREFIX + 'Variable implementation type could not be determined.' + GRAPH_MESSAGE_SUFFIX;
var NO_NODES_DIV = GRAPH_MESSAGE_PREFIX + 'No nodes to render for this graph.' + GRAPH_MESSAGE_SUFFIX;
var SELECT_GRAPH_DIV = GRAPH_MESSAGE_PREFIX + 'Select a graph to display.' + GRAPH_MESSAGE_SUFFIX;
var spg = null;
// Constructor for new FPGA graph
let FPGAGraph = function (jsonData, rankdir, isBankView, jsonBottleneck) {
    this.marginOffset = 20;
    this.allNodes = jsonData ? jsonData.nodes : null;
    this.allEdges = jsonData ? jsonData.links : null;
    this.isBankView = isBankView;
    this.graphOptions = { 'nodesep': 25, 'ranksep': 50, 'edgesep': 15,
        'rankdir': rankdir, 'ranker': 'tight-tree' };
    this.lastClicked = null;
    this.alreadyMade = false;
    // Get svg width based on container width
    this.getGraphWidth = function (div_name) {
        return $(div_name) ? $(div_name)[0].getBoundingClientRect()['width'] - 2 * this.marginOffset : 1000;
    };
    // Get svg height based on container height
    this.getGraphHeight = function (div_name) {
        return $(div_name) ? $(div_name)[0].getBoundingClientRect()['height'] - 2 * this.marginOffset : 1000;
    };
    // Get the critical paths from bottleneckJSON
    // In future can expand to multiple bottlenecks/critical paths
    this.getCriticalPaths = function (jsonBottleneck) {
        if (!jsonBottleneck)
            return null;
        if (!jsonBottleneck.bottlenecks)
            return null;
        let criticalPaths = new Array();
        bottleneckJSON['bottlenecks'].forEach(function (bottleneck) {
            criticalPaths.push(bottleneck['links']);
        });
        return criticalPaths;
    };
    this.addCustomShapes = function () {
        // Add a trapezoid for rendering mux
        this.renderer.shapes().trapezoid = function (parent, bbox, node) {
            let w = bbox['width'];
            let h = bbox['height'];
            let points = [
                { 'x': 0, 'y': -h },
                { 'x': w, 'y': -h },
                { 'x': 3 * w / 4, 'y': 0 },
                { 'x': w / 4, 'y': 0 }
            ];
            let shapeSvg = parent.insert('polygon', ":first-child")
                .attr('points', points.map(function (d) { return d['x'] + "," + d['y']; })
                .join(' '))
                .attr('transform', "translate(" + (-w / 2) + "," + (h / 2) + ")");
            node.intersect = function (point) {
                return dagreD3.intersect.polygon(node, points, point);
            };
            return shapeSvg;
        };
        // Add an arrow that points in the reverse direction
        this.renderer.arrows().reversePointer = function normal(parent, id, edge, type) {
            var marker = parent.append("marker")
                .attr("id", id)
                .attr("viewBox", "0 0 10 10")
                .attr("refX", 0) // Use 0 instead of 9 for alignment
                .attr("refY", 5)
                .attr("markerUnits", "strokeWidth")
                .attr("markerWidth", 8)
                .attr("markerHeight", 6)
                .attr("orient", "auto");
            // See reverse arrow pointer https://github.com/dagrejs/dagre-d3/pull/361/files
            var path = marker.append("path")
                .attr("d", "M 10 0 L 0 5 L 10 10 z"); // draw a backward arrow
            dagreD3.util.applyStyle(path, edge[type + "Style"]);
        };
    };
    // Flatten the JSON structure to create a map of nodeID => node obj
    this.flattenNodes = function () {
        var flattenedNodes = new Map();
        // Just parse the nodelist recursively with this helper function
        function flattenNodesHelper(nodeList, parent) {
            if (!nodeList)
                return;
            nodeList.forEach(function (n) {
                n['parent'] = parent;
                flattenedNodes.set(n['id'], n);
                if (n['children']) {
                    flattenNodesHelper(n['children'], n);
                }
            });
        }
        // Call the helper function on the whole JSON
        flattenNodesHelper(this.allNodes, '');
        return flattenedNodes;
    };
    // Directly from fpgagraph.js
    this.addCopyNode = function () {
        let _this = this;
        this.flattenedNodes.forEach(function (n) {
            if (n['copies'] && n['copies']['num'] > 0 && n['type'] == 'replicate') {
                // Create the id for the copy as the concatenation of it's parent's IDs
                let copyId = parseInt('' + n['parent']['id'] + n['id'] + 1);
                let copyName = n['name'] + ' Copy';
                let copy = { 'name': copyName, 'id': copyId, 'parent': n,
                    'details': n['copies']['details'], 'type': 'copies' };
                _this.flattenedNodes.set(copyId, copy);
                n['children'].push(copy);
                // Flow for chrome, firefox, etc.
                if (!reportIsIE() && !reportIsEdge()) {
                    // Node contains an HTML table that enumerates
                    // the number of copies, adds dashed lines between
                    // the different copies in the table. If there are more
                    // than 4 copies, then only the first 3 and last are shown
                    // with a '...' row added to indicate the abstraction to the user
                    _this.spg.setNode('_' + copyId, {
                        'label': function () {
                            let table = document.createElement('table');
                            let rows = [];
                            let max_visible_copies = (n['copies']['num'] > 4) ? 3 : n['copies']['num'];
                            let hasPadding = (n['padding'] > 0) ? true : false;
                            let i, j, row;
                            // Copies and padding rows are shown as their actual
                            // proportions to depth per copy and padding per copy
                            // If the ratio of padding to depth is too small to show
                            // clear info to the user we will default to a ratio of 0.8
                            let initialRatio = (n['depth'] - n['padding']) / n['depth'];
                            let paddingRatio = (initialRatio < 0.8) ? (initialRatio) : 0.8;
                            let numIterations = (hasPadding) ? (max_visible_copies * 2) : max_visible_copies;
                            let heightPerCopy = (n['copies']['num'] > 4) ? (100 / 4.25) : (100 / n['copies']['num']);
                            for (i = 0; i < numIterations; i++) {
                                row = table.insertRow(i).insertCell(0);
                                if (!hasPadding) {
                                    row.innerHTML = "Copy " + i;
                                    row.style.height = heightPerCopy + "%";
                                }
                                else if (i % 2 === 0) {
                                    // Insert Copy row
                                    row.innerHTML = "Copy " + (i / 2);
                                    row.style.height = (heightPerCopy * paddingRatio) + "%";
                                }
                                else {
                                    // Insert Padding row
                                    row.innerHTML = "Padding " + ((i - 1) / 2);
                                    row.style.height = (heightPerCopy * (1 - paddingRatio)) + "%";
                                    row.style.backgroundColor = "lightgrey";
                                }
                                row.style.width = "100%";
                                row.style.color = "black";
                                rows.push(row);
                            }
                            if (n['copies']['num'] > 4) {
                                let numAdditionalRows = (hasPadding) ? 3 : 2;
                                for (j = 0; j < numAdditionalRows; j++, i++) {
                                    row = table.insertRow(i).insertCell(0);
                                    if (j === 0) {
                                        // row containing '...'
                                        row.innerHTML = "&middot&middot&middot";
                                        row.style.fontSize = '20px';
                                        row.style.height = (heightPerCopy / 4) + '%';
                                    }
                                    else if (j === 1) {
                                        row.style.height = (heightPerCopy * paddingRatio) + "%";
                                        row.innerHTML = "Copy " + (n['copies']['num'] - 1);
                                    }
                                    else {
                                        row.innerHTML = "Padding " + (n['copies']['num'] - 1);
                                        row.style.height = (heightPerCopy * (1 - paddingRatio)) + "%";
                                        row.style.backgroundColor = "lightgrey";
                                    }
                                    row.style.width = '100%';
                                    row.style.color = 'black';
                                    rows.push(row);
                                }
                            }
                            // Dashed lines between rows in table
                            for (j = 0; j < i - 1; j++) {
                                rows[j].style.borderBottom = 'thin dashed #5cd6d6';
                            }
                            // Total table height and width
                            table.style.height = '250px';
                            table.style.width = '125px';
                            table.style.textAlign = 'center';
                            table.style.fill = 'white';
                            return table;
                        },
                        'padding': 0,
                        'style': 'fill: #ffa300;',
                        'width': 125,
                        'height': 250
                    });
                }
                else {
                    // Internet explorer or Edge since they do not support foreignObjects
                    // which are  required to render html table for the copies node
                    // Instead a rectangle is rendered containing information about # of copies
                    _this.spg.setNode('_' + copyId, { 'label': 'Copies: ' + n['copies']['num'],
                        'clusterLabelPos': 'top', 'shape': 'rect',
                        'paddingTop': 15, 'width': 150,
                        'height': 250, 'style': 'fill: #ffa300' });
                }
                _this.spg.setParent('_' + copyId, "_" + n['id']);
            }
        });
    };
    // Get node options like color, shape based on node types & metadata
    this.getNodeOptions = function (n) {
        let _this = this;
        var stallableInstColor = '#ffa300', // oneAPI orange
        singlePumpColor = '#8cdafa', // oneAPI light blue
        glbmemColor = '#8cdafa', // oneAPI light blue
        kernelColor = '#666699', // lavenderish
        bankColor = '#00aeef', // oneAPI bright blue
        replColor = '#f3d54e', // oneAPI yellow
        portColor = '#0071c5', // oneAPI blue
        clusterEntryColor = '#c4d600', // oneAPI green
        clusterExitColor = '#ffa300', // oneAPI orange
        defaultColor = '#ffffff'; // white
        let nodeOptions = { 'label': n['name'], 'shape': 'ellipse' };
        switch (n['type']) {
            case 'port':
                nodeOptions['shape'] = 'diamond';
                nodeOptions['style'] = 'fill: ' + portColor + ';';
                nodeOptions['labelStyle'] = 'fill: ' + defaultColor + ';';
                break;
            case 'arb':
                // Trapezoid only supports top to bottom rendering. Next step:
                // add horizontal trapezoid next for left to right direction.
                if (this.graphOptions['rankdir'] === 'TB') {
                    nodeOptions['shape'] = 'trapezoid';
                }
                nodeOptions['style'] = 'fill: ' + stallableInstColor + ';';
                break;
            case 'memsys':
                nodeOptions['shape'] = 'rect';
                nodeOptions['style'] = 'fill: ' + singlePumpColor + ';';
                break;
            case 'romsys':
                nodeOptions['style'] = 'fill: ' + singlePumpColor + ';';
                break;
            case 'bank':
                nodeOptions['style'] = 'fill: ' + bankColor + ';';
                break;
            case 'replicate':
                nodeOptions['style'] = 'fill: ' + replColor + ';';
                break;
            case 'kernel':
                nodeOptions['style'] = 'stroke: ' + kernelColor + ';';
                break;
            case 'pipe':
                nodeOptions['shape'] = 'rect';
                break;
            case 'block':
                nodeOptions['shape'] = 'rect';
                break;
            default:
                // Special color cases
                nodeOptions['style'] = 'fill: ' + defaultColor + ';';
                if (n['details']) {
                    // Check if LSU is connected to global memory
                    // Global LSU are colour as blue to indicate it is expected to stall
                    let glbmem = false;
                    if (n['name'] === 'Load' || n['name'] === 'Store' ||
                        n['subtype'] === 'load/store') {
                        // block.json have Global Memory in details
                        if (n['details'][0]['Global Memory'] && n['details'][0]['Global Memory'] == 'Yes') {
                            glbmem = true;
                        }
                        else {
                            // mav.json requires checking the connection
                            for (let ei = 0; ei < this.allEdges.length; ei++) {
                                let e = this.allEdges[ei];
                                if ((e['from'] === n['id'] &&
                                    this.flattenedNodes.get(e['to'])['parent']['name'] === 'Global Memory') ||
                                    (e['to'] === n['id'] &&
                                        this.flattenedNodes.get(e['from'])['parent']['name'] === 'Global Memory')) {
                                    glbmem = true;
                                    break;
                                }
                            }
                        }
                    }
                    if (glbmem) {
                        nodeOptions['style'] = 'fill: ' + glbmemColor + ';';
                    }
                    else if (n['details'][0]['Stall-free'] && n['details'][0]['Stall-free'] == 'No') {
                        nodeOptions['style'] = 'fill: ' + stallableInstColor + ';';
                    }
                }
                break;
        }
        if (n['subtype']) {
            switch (n['subtype']) {
                case 'select':
                    nodeOptions['shape'] = 'trapezoid';
                    break;
                case 'branch':
                    nodeOptions['shape'] = 'diamond';
                    break;
                case 'entry':
                    nodeOptions['style'] = 'fill: ' + clusterEntryColor + ';';
                    break;
                case 'exit':
                    nodeOptions['style'] = 'fill: ' + clusterExitColor + ';';
                    break;
            }
        }
        if (n['children']) {
            nodeOptions['shape'] = 'rect';
            nodeOptions['clusterLabelPos'] = 'top';
        }
        return nodeOptions;
    };
    // Get options for edge formatting & style
    this.getEdgeOptions = function (e) {
        let edgeOptions = { 'curve': d3.curveBasis };
        if (this.criticalPaths) {
            this.criticalPaths.forEach(function (p) {
                p.forEach(function (ce) {
                    if (ce['to'] == e['to'] && ce['from'] == e['from']) {
                        edgeOptions['style'] = 'stroke: #ed1c24; opacity: 1;';
                        edgeOptions['arrowheadClass'] = 'criticalPath';
                    }
                });
            });
        }
        // Reverse the arrow pointer
        if (e['reverse']) {
            if (!edgeOptions['style']) {
                edgeOptions['style'] = 'stroke: #005a9d; opacity: 1;';
                edgeOptions['arrowheadClass'] = 'feedbackPath';
            }
            edgeOptions['arrowhead'] = 'reversePointer';
            edgeOptions['backward'] = 1;
        }
        return edgeOptions;
    };
    // Create all the nodes and add to graph
    this.createNodes = function () {
        let _this = this;
        this.flattenedNodes.forEach(function (n) {
            if (n['type'] == 'copies')
                return;
            _this.spg.setNode('_' + n['id'], _this.getNodeOptions(n));
            if (n['parent'] && _this.flattenedNodes.has(n['parent']['id'])) {
                _this.spg.setParent('_' + n['id'], "_" + n['parent']['id']);
            }
        });
        if (this.isBankView)
            this.addCopyNode();
    };
    // Create all the edges and add to graph
    this.createEdges = function () {
        let _this = this;
        this.allEdges.forEach(function (e) {
            if (!_this.flattenedNodes.get(e['to']) || !_this.flattenedNodes.get(e['from']))
                return;
            // Special cases where edge must be reversed
            if ((_this.flattenedNodes.get(e['from'])['type'] == 'port' && _this.flattenedNodes.get(e['to'])['type'] == "arb") ||
                (_this.flattenedNodes.get(e['from'])['type'] == 'port' && _this.flattenedNodes.get(e['to'])['type'] == "inst") ||
                (_this.flattenedNodes.get(e['from'])['type'] == 'arb' && _this.flattenedNodes.get(e['to'])['type'] == "inst")) {
                _this.spg.setEdge('_' + e['to'], "_" + e['from'], _this.getEdgeOptions(e));
            }
            // Reverse the arrow pointing direction, flip the to and from to allow physical
            // place to have right data flow
            else if (e['reverse']) {
                _this.spg.setEdge('_' + e['to'], '_' + e['from'], _this.getEdgeOptions(e));
            }
            // Normal case, edge is same direction as in JSON
            else {
                _this.spg.setEdge('_' + e['from'], "_" + e['to'], _this.getEdgeOptions(e));
            }
        });
    };
    // Entry point for FPGAGraph, creates new graph and inserts into html
    this.createSVG = function (div_name) {
        if (typeof dagreD3 != "undefined") {
            this.spg = new dagreD3.graphlib.Graph({ 'compound': true }).setGraph(this.graphOptions);
            this.renderer = new dagreD3.render();
        }
        // Function calls to set up graph
        this.createNodes();
        this.createEdges();
        // Insert loading message with #nodes & #edges
        let loading_message = 'Loading graph with:\n' + this.spg['_nodeCount'] + " nodes and " + this.spg._edgeCount + " edges";
        $(div_name).html(GRAPH_MESSAGE_PREFIX + loading_message + GRAPH_MESSAGE_SUFFIX);
        // Create the svg division in html
        this.width = this.getGraphWidth(div_name);
        this.height = this.getGraphHeight(div_name);
        d3.select(div_name).append('svg')
            .attr('id', 'graph')
            .attr('width', this.width)
            .attr('height', this.height);
        d3.select('svg').append("g");
        // Render graph and insert into svg division
        this.addCustomShapes();
        this.renderer(d3.select('svg g'), this.spg);
        d3.select('#graph_message').remove();
        // Post rendering, add tooltips, align port, add details and resize graph
        this.alignPortNodes();
        if (this.isBankView)
            this.resizeNodesForCopy();
        // In the wrapper test, we don't care about details/resizing graph
        if (!this.wrapper_test) {
            this.addMouseoverEvents();
            this.resizeGraph(div_name);
        }
    };
    // Resize the graph based on new card-body size
    this.resizeGraph = function (div_name) {
        this.width = this.getGraphWidth(div_name);
        this.height = this.getGraphHeight(div_name);
        let graph = d3.select(div_name).select('svg');
        graph.attr('width', this.width);
        graph.attr('height', this.height);
    };
    this.resizeNodesForCopy = function () {
        let graph = d3.select('svg g');
        let _this = this;
        let minYCoord = -1;
        let maxYCoord = 0;
        graph.selectAll('g.node').filter(function (nodeId) {
            return _this.flattenedNodes.get(parseInt(nodeId.replace('_', '')))['type'] == 'copies';
        }).each(function (c) {
            let copyId = parseInt(c.replace('_', ''));
            let copyNode = _this.flattenedNodes.get(copyId);
            let copyHeight = parseInt(d3.select(this).select('rect').attr('height'));
            let stringCoords = d3.select(this).attr('transform');
            let copyCoords = stringCoords.substring(stringCoords.indexOf('(') + 1, stringCoords.indexOf(')'));
            if (reportIsIE())
                copyCoords = copyCoords.split(' ').map(Number);
            else
                copyCoords = copyCoords.split(',').map(Number);
            if (copyCoords[1] > maxYCoord)
                maxYCoord = copyCoords[1];
            if (copyCoords[1] < minYCoord || minYCoord == -1)
                minYCoord = copyCoords[1];
            graph.selectAll('g.cluster').filter(function (clusterId) {
                return parseInt(clusterId.replace('_', '')) == copyNode['parent']['id'];
            }).each(function () {
                d3.select(this).select('rect').attr('height', copyHeight + 30);
            });
            graph.selectAll('g.cluster').filter(function (clusterId) {
                return parseInt(clusterId.replace('_', '')) == copyNode['parent']['parent']['id'];
            }).each(function () {
                d3.select(this).select('rect').attr('height', copyHeight + 60 + (maxYCoord - minYCoord));
            });
        });
    };
    // Function for local memory viewer to align the port nodes on cluster edge
    this.alignPortNodes = function () {
        // Helper function to move graph node in svg
        function setCoordinates(node, x, y) {
            node.attr('transform', 'translate(' + x + ',' + y + ')');
        }
        let _this = this;
        let graph = d3.select('svg g');
        graph.selectAll('g.node').filter(function (nodeId) {
            return _this.flattenedNodes.get(parseInt(nodeId.replace('_', '')))['type'] == 'port';
        }).each(function (p) {
            let stringCoords = d3.select(this).attr('transform');
            let portCoords = stringCoords.substring(stringCoords.indexOf('(') + 1, stringCoords.indexOf(')'));
            if (reportIsIE())
                portCoords = portCoords.split(' ').map(Number);
            else
                portCoords = portCoords.split(',').map(Number);
            let toMove = new Array();
            let currentNode = _this.flattenedNodes.get(parseInt(p.replace('_', '')))['parent'];
            let replId = currentNode.id;
            let clusterWidth = 0;
            let copyId = 0;
            let replYCoords = new Array(2);
            if (_this.isBankView) {
                currentNode['children'].filter(function (n) {
                    return n['type'] == 'copies';
                }).forEach(function (n) {
                    toMove.push(n['id']);
                    copyId = n['id'];
                });
            }
            toMove.push(currentNode['id']);
            while (currentNode['parent']) {
                toMove.push(currentNode['parent']['id']);
                currentNode = currentNode['parent'];
            }
            // Find the parent of the port and get it's width.
            graph.selectAll('g.cluster')
                .filter(function (nodeId) {
                return parseInt(nodeId.replace('_', '')) == replId;
            }).each(function () {
                if (reportIsIE())
                    replYCoords[0] = d3.select(this).attr('transform').split(' ');
                else
                    replYCoords[0] = d3.select(this).attr('transform').split(',');
                replYCoords[0] = parseFloat(replYCoords[0][replYCoords[0]['length'] - 1]);
                replYCoords[1] = parseFloat(d3.select(this).select('rect').attr('y'));
                clusterWidth = d3.select(this).select('rect').attr("width");
            });
            // Go to each parent of the port and move it over
            graph.selectAll('g.cluster, g.node')
                .filter(function (nodeId) {
                return toMove.indexOf(parseInt(nodeId.replace('_', ''))) != -1;
            }).each(function (nodeId) {
                // Get the current coordinates of the port
                let stringCoords = d3.select(this).attr('transform');
                let currentCoords = stringCoords.substring(stringCoords.indexOf('(') + 1, stringCoords.indexOf(')'));
                if (reportIsIE())
                    currentCoords = currentCoords.split(' ').map(Number);
                else
                    currentCoords = currentCoords.split(',').map(Number);
                // Move the port with helper function, only if not already moved
                if (currentCoords[0] == portCoords[0]) {
                    setCoordinates(d3.select(this), currentCoords[0] + clusterWidth / 2, currentCoords[1]);
                    if (_this.isBankView && parseInt(nodeId.replace('_', '')) == copyId) {
                        setCoordinates(d3.select(this), currentCoords[0] + clusterWidth / 2, replYCoords[0]);
                        d3.select(this).select('rect').attr('y', replYCoords[1] + 15);
                        if (!reportIsIE() && !reportIsEdge()) {
                            let xCoord = d3.select(this).select('rect').attr("x");
                            let copyWidth = parseFloat(d3.select(this).select('rect').attr('width'));
                            let copyHeight = parseFloat(d3.select(this).select('rect').attr('height'));
                            setCoordinates(d3.select(this).select('g.label g'), xCoord, replYCoords[1] + 15);
                            d3.select(this).select('g.label g foreignObject').attr('width', copyWidth);
                            d3.select(this).select('g.label g foreignObject').attr('height', copyHeight);
                        }
                    }
                }
            });
        });
    };
    // Adds all the tooltips to graph nodes
    // TO DO: // Add getTooltip and getEdgeTooltip
    // This is not currently implemented as getTooltip and getEdgeTooltip
    // need to be written
    this.addTooltips = function () {
        let _this = this;
        let graph = d3.select('svg g');
        graph.selectAll('g.node rect, g.cluster rect, g.node ellipse, g.node polygon')
            .each(function (n) {
            $(this).attr('title', _this.getTooltip(n));
            $(this).attr('data-html', "true");
            $(this).attr('data-placement', "right");
            $(this).tooltip({
                'content': function () { return $(this).attr('title'); },
                'position': { 'my': 'left bottom', 'at': 'center top-2' }
            });
        });
        graph.selectAll('g.edgePath path')
            .each(function (e) {
            $(this).attr('title', _this.getEdgeTooltip(e));
            $(this).attr('data-html', 'true');
            $(this).attr('data-placement', 'right');
            $(this).tooltip({
                'content': function () { return $(this).attr('title'); },
                'position': { 'my': 'left bottom', 'at': 'center top-2' }
            });
        });
    };
    this.removeHighlighting = function () {
        let _this = this;
        let graph = d3.select('svg g');
        graph.selectAll('g.node rect, g.cluster rect, g.node ellipse, g.node polygon, g.node .label')
            .each(function (nodeId) {
            let node = _this.flattenedNodes.get(parseInt(nodeId.replace('_', '')));
            let fill = _this.getNodeOptions(node)['style'];
            d3.select(this).style('fill', fill)
                .style('stroke', '#333333')
                .style('stroke-width', '1.5px');
        });
        graph.selectAll('g.edgePath').each(function (edgeElem) {
            let style = null;
            _this.allEdges.forEach(function (e) {
                if (e['from'] == parseInt(edgeElem['v'].replace('_', ''))
                    && e['to'] == parseInt(edgeElem['w'].replace('_', ''))) {
                    style = _this.getEdgeOptions(e)['style'] ? _this.getEdgeOptions(e)['style'] : style;
                }
            });
            d3.select(this).selectAll('path').attr('style', style);
        });
    };
    // Highlight selected node and the edges attached to it
    this.highlightNodes = function (nodeElem) {
        let graph = d3.select('svg g');
        let toHighlight = graph.selectAll('g.edgePath').filter(function (e) {
            return (e['v'] == nodeElem || e['w'] == nodeElem);
        });
        toHighlight.selectAll('path')
            .attr('style', 'stroke: #1d99c1; opacity: 0.5; fill: none; stroke-width: 3;');
        toHighlight.selectAll('marker path')
            .attr('style', 'fill: #1d99c1; opacity: 0.5; stroke-width: 0;');
        graph.selectAll('g.node rect, g.cluster rect, g.node ellipse, g.node polygon, g.node .label')
            .filter(function (nodeId) {
            return nodeId == nodeElem;
        }).each(function () {
            d3.select(this).style('stroke', '#1d99c1')
                .style('stroke-width', '3px');
        });
    };
    // Highlight selected edge and the nodes attached to it
    this.highlightEdges = function (edgeElem) {
        let graph = d3.select('svg g');
        graph.selectAll('g.node rect, g.cluster rect, g.node ellipse, g.node polygon, g.node .label')
            .filter(function (nodeId) {
            return edgeElem['v'] == nodeId || edgeElem['w'] == nodeId;
        }).each(function () {
            d3.select(this).style('stroke', '#1d99c1')
                .style('stroke-width', '3px');
        });
        let toHighlight = graph.selectAll('g.edgePath').filter(function (edgeId) {
            return edgeId == edgeElem;
        });
        toHighlight.selectAll('path')
            .attr('style', 'stroke: #1d99c1; opacity: 0.5; fill: none; stroke-width: 3;');
        toHighlight.selectAll('marker path')
            .attr('style', 'fill: #1d99c1; opacity: 0.5; stroke-width: 0;');
    };
    // Highlight the correct editor line depending on which node was clicked
    this.setEditorForNode = function (nodeElem) {
        let node = this.flattenedNodes.get(parseInt(nodeElem.replace('_', '')));
        if (node && node['debug'] && node['debug']['length'] > 0 && node['debug'][0]['length'] > 0)
            syncEditorPaneToLine(node['debug'][0][0]['line'], getFilename(node['debug'][0][0]['filename']));
        else
            editorNoHighlightActiveLine();
    };
    // Changes the details pane to show the details for node nodeElem
    this.addNodeDetail = function (nodeElem) {
        let node = this.flattenedNodes.get(parseInt(nodeElem.replace('_', '')));
        let details = (node && node['details']) ? node['details'] : null;
        changeDetailsPane(details, node['name']);
    };
    // Changes the details pane to show the details for edge edgeElem
    this.addEdgeDetail = function (edgeElem) {
        let from = parseInt(edgeElem.v.replace('_', ''));
        let to = parseInt(edgeElem.w.replace('_', ''));
        let edge = '';
        for (let e in this.allEdges) {
            if (e['to'] == to && e['from'] == from) {
                edge = e;
            }
        }
        let details = (edge && edge['details']) ? edge['details'] : null;
        changeDetailsPane(details, this.flattenedNodes.get(from)['name'] + ' to ' + this.flattenedNodes.get(to)['name']);
    };
    // Add details to the detail pane for each node/edge
    this.addMouseoverEvents = function () {
        let _this = this;
        let graph = d3.select('svg g');
        graph.selectAll('g.node rect, g.cluster rect, g.node ellipse, g.node polygon, g.node .label')
            .on('click', function (nodeElem) {
            _this.removeHighlighting(_this.lastClicked);
            _this.lastClicked = nodeElem;
            _this.addNodeDetail(nodeElem);
            _this.setEditorForNode(nodeElem);
            _this.highlightNodes(nodeElem);
        })
            .on('mouseover', function (nodeElem) {
            if (_this.lastClicked == nodeElem || !_this.lastClicked) {
                _this.addNodeDetail(nodeElem);
                _this.highlightNodes(nodeElem);
            }
        })
            .on('mouseout', function () {
            if (!_this.lastClicked) {
                clearDivContent();
                _this.removeHighlighting();
            }
        });
        graph.selectAll('g.edgePath path')
            .on('click', function (edgeElem) {
            _this.removeHighlighting(_this.lastClicked);
            _this.lastClicked = edgeElem;
            _this.addEdgeDetail(edgeElem);
            _this.highlightEdges(edgeElem);
        })
            .on('mouseover', function (edgeElem) {
            if (_this.lastClicked == edgeElem || !_this.lastClicked) {
                _this.addEdgeDetail(edgeElem);
                _this.highlightEdges(edgeElem);
            }
        })
            .on('mouseout', function () {
            if (!_this.lastClicked) {
                clearDivContent();
                _this.removeHighlighting();
            }
        });
    };
    // FPGAGraph::main() - start the graph
    this.flattenedNodes = this.flattenNodes();
    this.criticalPaths = this.getCriticalPaths(jsonBottleneck);
};
/**
 * @class FPGAGVGraph is the entry Point for graph viewer (aka system viewer).
 * @param {object} pNode is a single node selected by user from the navigation tree.
 */
let FPGAGVGraph = function (pNode) {
    this.rankdir = 'TB'; // renders top to bottom
    // === System viewer filter kernel functions === //
    this.getLowestChildrenIDList = function (pNode) {
        if (pNode.hasOwnProperty('children') && pNode['children'].length) {
            let vChildrenList = [];
            for (let ci = 0; ci < pNode['children'].length; ci++) {
                vChildrenList = vChildrenList.concat(this.getLowestChildrenIDList(pNode['children'][ci]));
            }
            return vChildrenList;
        }
        return [pNode['id']];
    };
    this.isNodeContainInstID = function (pID, pNode) {
        if (pNode.hasOwnProperty('children') && pNode['children'].length) {
            for (let ci = 0; ci < pNode['children'].length; ci++) {
                if (this.isNodeContainInstID(pID, pNode['children'][ci]))
                    return true;
            }
        }
        return (pNode['id'] === pID);
    };
    // Temporary function to filter out nodes in graphJSON
    this.filterFunction = function (pNodeName, graphJSON) {
        let vFound = false;
        let vFunction;
        for (let ni = 0; ni < graphJSON['nodes'].length; ni++) {
            vFunction = graphJSON['nodes'][ni];
            if (vFunction['name'] === pNodeName) {
                vFound = true;
                break;
            }
        }
        // Early exit when node not found or no children
        if (!vFound) {
            return undefined;
        }
        if (!vFunction.hasOwnProperty('children')) {
            return [];
        }
        // Connected nodes such as arguments, streams/pipe, and global memory
        let vInstIDList = this.getLowestChildrenIDList(vFunction);
        // Filter the links to these lowest level instructions
        let vLinks = [];
        if (graphJSON.hasOwnProperty('links')) {
            for (let li = 0; li < graphJSON['links'].length; li++) {
                let vEdge = graphJSON['links'][li];
                if (vInstIDList.indexOf(vEdge['from']) >= 0 || vInstIDList.indexOf(vEdge['to']) >= 0) {
                    vLinks.push(vEdge);
                }
            }
        }
        // Get all ID's that are external to the function
        let vExternalNodesIDList = [];
        for (let li = 0; li < vLinks.length; li++) {
            let vEdge = vLinks[li];
            if (vInstIDList.indexOf(vEdge['from']) < 0) {
                vExternalNodesIDList.push(vEdge['from']);
            }
            else if (vInstIDList.indexOf(vEdge['to']) < 0) {
                vExternalNodesIDList.push(vEdge['to']);
            }
        }
        // Dissolved the function hierarchy and add external connected nodes
        let vFilterNodes = [];
        vFilterNodes = vFilterNodes.concat(vFunction['children']);
        if (vExternalNodesIDList.length) {
            for (let ni = 0; ni < graphJSON['nodes'].length; ni++) {
                let vNode = graphJSON['nodes'][ni];
                if (vNode['name'] === pNodeName) {
                    continue;
                } // ignore itself
                for (let ei = 0; ei < vExternalNodesIDList.length; ei++) {
                    if (this.isNodeContainInstID(vExternalNodesIDList[ei], vNode)) {
                        vFilterNodes.push(vNode);
                    }
                }
            }
        }
        return { 'nodes': vFilterNodes, 'links': vLinks };
    };
    // === Global Memory Viewer add bandwidth functions === //
    // Add attribute and value to detail object
    this.addDetailData = function (pAttr, pValue, pNode) {
        if (!pNode.hasOwnProperty('details')) {
            pNode['details'] = [];
            let vDetailObj = {};
            vDetailObj['type'] = 'table';
            vDetailObj[pAttr] = pValue;
            pNode['details'].push(vDetailObj);
            return;
        }
        // Insert the value
        pNode['details'][0][pAttr] = pValue;
    };
    // Get Quartus clock fmax if exist, undefined otherwise.
    this.getQuartusClkFmax = function () {
        let vClkID = 'quartusFitClockSummary';
        if (!$.isEmptyObject(quartusJSON) && quartusJSON.hasOwnProperty(vClkID) &&
            quartusJSON[vClkID].hasOwnProperty('nodes') &&
            Array.isArray(quartusJSON[vClkID]['nodes']) &&
            quartusJSON[vClkID]['nodes'].length !== 0) {
            let quartusClkData = quartusJSON[vClkID];
            // Get the kernel clock. The name kernel clock is only applicable for OpenCL
            // or SYCL. This is okay because Global Memory Viewer is not avaliable for HLS.
            for (let ni = 0; ni < quartusClkData['nodes'].length; ni++) {
                let quartusClkNode = quartusClkData['nodes'][ni];
                return parseFloat(quartusClkNode['kernel clock']);
            }
        }
        return undefined;
    };
    // Set fmax. Use Quartus compile fmax if exist. Otherwise, it will use the 
    // minimum between target fmax or schedule fmax. When it is an estimate,
    // fmax_estimate is set to true.
    this.setFmax = function () {
        // Get the fmax for the first time
        if (!this.fmax) {
            this.fmax_estimate = false;
            this.fmax = this.getQuartusClkFmax();
            if (!this.fmax || isNaN(this.fmax)) {
                // use target fmax for estimation
                this.fmax = getTargetFrequencyValue();
                let firstLowerFmaxScheduleBlock = getMininumScheduleClockFreq();
                if (firstLowerFmaxScheduleBlock !== null) {
                    this.fmax = firstLowerFmaxScheduleBlock['fmax'];
                    ;
                }
                this.fmax_estimate = true;
            }
        }
    };
    // Calculate LSU throughput and add to LSU node. Load and Store have the same formula
    // Throughput is units of bytes per second = minimum (KWIDTH, MWIDTH)/8*Fmax.
    // Returns true if a calculation was performed. False otherwise.
    this.calculateLSUThroughput = function (pLSUNode) {
        if (pLSUNode.hasOwnProperty('throughput')) {
            return false;
        } // previously calculated
        if (pLSUNode.hasOwnProperty('kwidth') && pLSUNode.hasOwnProperty('mwidth') && this.fmax) {
            let vKWidth = parseFloat(pLSUNode['kwidth']); // Kernel side width
            let vMWidth = parseFloat(pLSUNode['mwidth']); // Memory side width
            let vWidth = (vKWidth < vMWidth) ? vKWidth : vMWidth; // min width
            pLSUNode['throughput'] = vWidth / 8.0 * this.fmax;
            return true;
        }
        return false;
    };
    // Calculate and add throughput to LSU's and returns 2 lists: throughput value for all loads
    // and stores.
    // The reason why this is calculated in the front-end is because fmax only exist after
    // Quartus compiles.
    this.addThrougputToLSU = function (pNodelist) {
        let vThroughput = {};
        vThroughput['load'] = {};
        vThroughput['store'] = {};
        for (let ni = 0; ni < pNodelist.length; ni++) {
            let vNode = pNodelist[ni];
            let vParent = vNode.parent ? vNode.parent : -1;
            if (vNode['name'] === 'LD' || vNode['name'] === 'ST') {
                if (this.calculateLSUThroughput(vNode)) { // calculate for the first time
                    // Calculate it for the first time and add to details
                    let vThroughput = vNode['throughput'].toString() + ' MB/s';
                    // Add description how the calculation is generated, important to convey which
                    // clock frequency is used.
                    let vText = 'Equals to minimum (kwidth, mwidth) / 8 X ';
                    if (this.fmax_estimate) {
                        vText += 'Compiler Target Frequency';
                    }
                    else {
                        vText += 'Quartus Fitter Clock Frequency';
                    }
                    let vKWidth = parseFloat(vNode['kwidth']); // Kernel side width
                    let vMWidth = parseFloat(vNode['mwidth']); // Memory side width
                    let vWidth = (vKWidth < vMWidth) ? vKWidth : vMWidth; // min width
                    vText += ' = ' + vWidth.toString() + ' / 8 X ' + this.fmax.toString() + ' MB/s';
                    this.addDetailData('Throughput ' + createHelpTooltip(vText).outerHTML, vThroughput, vNode);
                }
                if (vNode['name'] === 'LD') {
                    if (!vThroughput['load'][vParent])
                        vThroughput['load'][vParent] = [];
                    vThroughput['load'][vParent].push(vNode['throughput']);
                }
                else {
                    if (!vThroughput['store'][vParent])
                        vThroughput['store'][vParent] = [];
                    vThroughput['store'][vParent].push(vNode['throughput']);
                }
            }
            else if (vNode.hasOwnProperty('children')) {
                let vTP = this.addThrougputToLSU(vNode['children']);
                // Children of type LD & ST won't have a "parent" field and thus 'vParent' will be -1 
                if (Object.keys(vTP['load']).length !== 0) {
                    if (!vThroughput['load'][vParent])
                        vThroughput['load'][vParent] = [];
                    if (vTP['load'][-1])
                        vThroughput['load'][vParent] = vThroughput['load'][vParent].concat(vTP['load'][-1]);
                }
                if (Object.keys(vTP['store']).length !== 0) {
                    if (!vThroughput['store'][vParent])
                        vThroughput['store'][vParent] = [];
                    if (vTP['store'][-1])
                        vThroughput['store'][vParent] = vThroughput['store'][vParent].concat(vTP['store'][-1]);
                }
            }
        }
        return vThroughput;
    };
    // Returns true if interleave is disable and memory have more than one channel
    this.isBandwidthSplitbyChannel = function (pMCNode) {
        let vMem_num_channel = parseInt(pMCNode['num_channels']);
        let vMem_interleave_enabled = (pMCNode['interleave']) ? true : false;
        if (vMem_num_channel > 1 && !vMem_interleave_enabled) {
            return true;
        }
        return false;
    };
    // Calculate controller bandwidth: Read = sum(Throughput: LD), Write = sum(Throughput: ST)
    // Returns true if a calculation was performed. False otherwise.
    this.calculateMemCntlBandwidth = function (pMCNode, pLoadTPList, pStoreTPList) {
        // Early exit if it's previously computed or throughput list is empty
        if (pMCNode.hasOwnProperty('read_bw') && pMCNode.hasOwnProperty('write_bw')) {
            return false;
        }
        if ((pLoadTPList === undefined || pLoadTPList.length === 0) &&
            (pStoreTPList === undefined || pStoreTPList.length === 0)) {
            return false;
        }
        if (pMCNode.hasOwnProperty('bw') && pMCNode.hasOwnProperty('interleave') &&
            pMCNode.hasOwnProperty('num_channels')) {
            let vBSP_total_bandwidth = parseFloat(pMCNode['bw']);
            let vMem_bandwidth = vBSP_total_bandwidth;
            // Divide the bandwidth by number of channels if interleave is disable and
            // memory have more than one channel
            if (this.isBandwidthSplitbyChannel(pMCNode)) {
                let vMem_num_channel = parseFloat(pMCNode['num_channels']);
                vMem_bandwidth = vBSP_total_bandwidth / vMem_num_channel;
            }
            pMCNode['mem_bw'] = vMem_bandwidth;
            // Sum of all load and store as total read and write throughput
            let vReadBW = 0;
            let vWriteBW = 0;
            function sum(a, b) { return a + b; }
            if (typeof pLoadTPList !== 'undefined' && pLoadTPList.length > 0)
                vReadBW = pLoadTPList.reduce(sum);
            if (typeof pStoreTPList !== 'undefined' && pStoreTPList.length > 0)
                vWriteBW = pStoreTPList.reduce(sum);
            if (vReadBW > 0)
                pMCNode['load_tp'] = vReadBW;
            if (vWriteBW > 0)
                pMCNode['store_tp'] = vWriteBW;
            // Compare the LSU bandwidth and memory, then use the minimum
            if (vReadBW > 0)
                pMCNode['read_bw'] = (vReadBW < vMem_bandwidth) ? vReadBW : vMem_bandwidth;
            if (vWriteBW > 0)
                pMCNode['write_bw'] = (vWriteBW < vMem_bandwidth) ? vWriteBW : vMem_bandwidth;
            return true;
        }
        return false;
    };
    // Returns a string for mouseover tooltip help text that explains how throughput
    // is calculated.
    this.getTotalThroughputHelpText = function (pTPList) {
        let vTooltipText = 'Equals to ' + pTPList[0].toString();
        for (let i = 1; i < pTPList.length; i++) {
            vTooltipText += ' + ' + pTPList[i].toString();
            // Truncate the formula when there are more 3 LSU's in the equation
            if (i == 2 && pTPList.length > 3) {
                vTooltipText += ' + ...';
                break;
            }
        }
        vTooltipText += ' MB/s';
        return vTooltipText;
    };
    // Returns a string for mouseover tooltip help text that explains how bandwidth is
    // computed. Set pReadNotWrite to true for Read, false for Write bandwidth.
    this.getBandwidthHelpText = function (pMCNode, pReadNotWrite) {
        let vText = (pReadNotWrite) ? 'Load' : 'Store';
        let vThroughput = (pReadNotWrite) ? pMCNode['load_tp'] : pMCNode['store_tp'];
        let vTooltipText = 'Equals to minimum (Bandwidth';
        if (this.isBandwidthSplitbyChannel(pMCNode)) {
            vTooltipText += ' / Number of channels';
        }
        vTooltipText += ', sum of ' + vText + ' throughput) = minimum (';
        vTooltipText += pMCNode['mem_bw'] + ', ' + vThroughput + ')';
        return vTooltipText;
    };
    this.addBandWidthToMemoryController = function (pNodelist, pLoadTPList, pStoreTPList) {
        for (let ni = 0; ni < pNodelist.length; ni++) {
            let vNode = pNodelist[ni];
            if (vNode['name'] === 'Memory Controller') {
                let vParent = vNode['parent'] ? vNode['parent'] : -1;
                let curr_pLoadTPList = pLoadTPList[vParent];
                let curr_pStoreTPList = pStoreTPList[vParent];
                if (this.calculateMemCntlBandwidth(vNode, curr_pLoadTPList, curr_pStoreTPList)) {
                    let vTooltipText = '';
                    if (typeof vNode['load_tp'] !== 'undefined') {
                        // Total load throughput
                        vTooltipText = this.getTotalThroughputHelpText(curr_pLoadTPList);
                        let vSumLoadTP = vNode['load_tp'].toString() + ' MB/s';
                        this.addDetailData('Sum of Load Throughput ' + createHelpTooltip(vTooltipText).outerHTML, vSumLoadTP, vNode);
                        // Read bandwidth
                        vTooltipText = this.getBandwidthHelpText(vNode, true);
                        let vReadBW = vNode['read_bw'].toString() + ' MB/s';
                        this.addDetailData('Read Bandwidth ' + createHelpTooltip(vTooltipText).outerHTML, vReadBW, vNode);
                    }
                    if (typeof vNode['store_tp'] !== 'undefined') {
                        // Total store throughput
                        vTooltipText = this.getTotalThroughputHelpText(curr_pStoreTPList);
                        let vSumStoreTP = vNode['store_tp'].toString() + ' MB/s';
                        this.addDetailData('Sum of Store Throughput ' + createHelpTooltip(vTooltipText).outerHTML, vSumStoreTP, vNode);
                        // Write bandwidth
                        vTooltipText = this.getBandwidthHelpText(vNode, false);
                        let vWriteBW = vNode['write_bw'].toString() + ' MB/s';
                        this.addDetailData('Write Bandwidth ' + createHelpTooltip(vTooltipText).outerHTML, vWriteBW, vNode);
                    }
                }
            }
        }
    };
    this.addBandwidthToGlobalMemoryViewer = function () {
        if (!this.source.hasOwnProperty('nodes')) {
            return;
        }
        this.setFmax();
        let vTP = this.addThrougputToLSU(this.source['nodes']);
        this.addBandWidthToMemoryController(this.source['nodes'], vTP['load'], vTP['store']);
    };
    this.source;
    if (pNode.type === 'memory') {
        // If node is the Global Memory parent node, show all global memories
        if (pNode.name === 'Global memory' && gmvJSON) {
            // Create a fresh copy of gmvJSON and set as source
            this.source = JSON.parse(JSON.stringify(gmvJSON));
            this.addBandwidthToGlobalMemoryViewer();
        }
        else {
            this.source = undefined;
        }
    }
    else if (pNode.type === 'memsys') {
        let memsys_id_list = gmvJSON['nodes'].filter(function (curr_memsys) {
            return curr_memsys.name === pNode.name;
        });
        let memsys_id = -1;
        if (memsys_id_list.length > 0)
            memsys_id = memsys_id_list[0].id;
        let nodes_list = gmvJSON['nodes'].filter(function (curr_memsys) {
            return curr_memsys.name === pNode.name || parseInt(curr_memsys.parent) === memsys_id;
        });
        // Copy gmvJSON and replace 'nodes' with only the nodes for the current
        // selected global memory
        let new_gmvJSON = JSON.parse(JSON.stringify(gmvJSON));
        delete new_gmvJSON['nodes'];
        new_gmvJSON['nodes'] = JSON.parse(JSON.stringify(nodes_list));
        this.source = new_gmvJSON;
        this.addBandwidthToGlobalMemoryViewer();
    }
    else if (pNode.type === 'cluster') {
        this.source = pipelineJSON[pNode.id];
    }
    else if (pNode.type === 'bb') {
        this.source = blockJSON[pNode.id];
    }
    else if (pNode.type === "system") {
        // SYCL/OpenCL: Kernel viewer uses old infrastructure --> mavJSON
        this.source = (product === PRODUCTS.HLS) ? systemJSON : mavJSON;
    }
    else { // Component, Function, or Kernel
        // This hierarchy uses old infrastructure --> mavJSON
        // Filter out the only a single function as temporary workaround
        this.source = this.filterFunction(pNode.name, mavJSON);
    }
    // Simple error check
    if (this.source === undefined) {
        this.source = { 'message': 'No graph available' };
    }
    /**
     * @function draw takes the source variable and feed into dagre-d3 rendering engine. It
     * populates the final SVG in the div specified.
     * It will early exit and message to user nothing to render when source is undefined, or
     * source['nodes'] is undefined or an empty array.
     * @param {string} pDiv is the name of the element begin with '#'.
     */
    this.draw = function (pDiv) {
        clearGraphDiv();
        clearDivContent();
        // Sanity check graphJSON
        if (this.source === undefined || this.source.nodes === undefined || this.source['nodes']['length'] === 0) {
            if (this.source['message']) {
                renderNoGraphForType(pDiv, '', 'message', '', this.source['message']);
            }
            else {
                renderNoGraphForType(pDiv, '', 'no_nodes', '');
            }
            $('.card-header #layers*').html('');
            return;
        }
        // Create FPGAGraph and render it
        let gv_graph = new FPGAGraph(this.source, this.rankdir, false, bottleneckJSON);
        gv_graph.createSVG(pDiv);
        // Add pan zoom after rendering
        svgPanZoom('#graph', { 'controlIconsEnabled': true,
            'zoomScaleSensitivity': 0.4,
            'maxZoom': 50 });
        refreshAreaVisibility();
        adjustToWindowEvent();
    };
};
/**
 * @class FPGALMVGraph is the entry point for LMV Graph. When user selects the local memory
 * It shows the user all the instruction and nodes connected to it.
 * @param {string} func_name is the name of the function which contains the local memory
 * @param {string} lmem_name is the name of the local memory
 * @param {string} bank_name is defined when user selects a specific bank under a local
 * memory. This is undefined when user selects the top local memory.
 * @param {string} bank_list is defined when user selects local memory, ignore bank_list
 * parameter when user selects a specific bank under local memory tree. There are 3 cases, user
 * selects all the banks, no banks, or a parital number of banks. In the case of no banks is
 * is selected, it only renders the top level node with local memory information.
 */
let FPGALMVGraph = function (func_name, lmem_name, bank_name, bank_list) {
    this.source = new_lmvJSON;
    this.funcName = func_name;
    this.topNodeName = lmem_name;
    this.bankNodeName = bank_name;
    this.bankList = bank_list;
    this.rankdir = 'LR'; // renders left to right
    // Basic error check
    if (!this.source.hasOwnProperty('nodes') || !this.source.hasOwnProperty('links')) {
        return;
    }
    // Get the function node
    this.getFunctionNode = function () {
        for (let fi = 0; fi < vFunctionList.length; fi++) {
            let vFuncNode = vFunctionList[fi];
            // Want function with same name or has children
            if (vFuncNode['name'] === this.funcName &&
                vFuncNode.hasOwnProperty('children')) {
                return vFuncNode;
            }
        }
        return undefined;
    };
    // Get the given memory system node that matches the local memory name within the 
    // node. Returns undefined if not found. The list is local memory type children list.
    // When the user selected a single bank, then it returns bank hierarchy as top.
    this.getMemorySystemNode = function (pLocalMemoryNodeList) {
        for (let mi = 0; mi < pLocalMemoryNodeList.length; mi++) {
            let vMemSysNode = pLocalMemoryNodeList[mi];
            if (vMemSysNode['name'] === this.topNodeName) {
                // When the user selects a bank, find the bank user selected
                if (this.bankNodeName) {
                    for (let bi = 0; bi < vMemSysNode['children'].length; bi++) {
                        let vBankNode = vMemSysNode['children'][bi];
                        if (vBankNode['name'] === this.bankNodeName) {
                            return vBankNode;
                        }
                    }
                }
                else {
                    // User selected memory. There are 3 cases: all banks, no bank, 
                    // or a subset of bank selected
                    if (this.bankList.length == vMemSysNode['children'].length) {
                        return vMemSysNode;
                    }
                    else {
                        let vPartialMemSysNode = {};
                        // Deep copy the current node
                        Object.keys(vMemSysNode).forEach(function (attr) {
                            if (attr === 'children') {
                                return;
                            }
                            vPartialMemSysNode[attr] = vMemSysNode[attr];
                        });
                        // Nothing is selected
                        if (this.bankList.length === 0) {
                            return vPartialMemSysNode;
                        }
                        // Copy paritial bank
                        vPartialMemSysNode['children'] = [];
                        for (let bi = 0; bi < vMemSysNode['children'].length; bi++) {
                            let vBankNode = vMemSysNode['children'][bi];
                            if (this.bankList.indexOf(vBankNode['name']) >= 0) {
                                vPartialMemSysNode['children'].push(vBankNode);
                            }
                        }
                        return vPartialMemSysNode;
                    }
                }
            }
        }
        return undefined;
    };
    // Returns a list of the IDs in the memory system node. BF travsal to add all the
    // ID's.
    this.getMemSystemIDs = function (pMemSysNode) {
        let vMemSysIDList = [];
        let vNextVisit = [];
        vNextVisit.push(pMemSysNode);
        while (vNextVisit.length) {
            let vMemNode = vNextVisit.shift();
            if (vMemSysIDList.indexOf(vMemNode['id']) >= 0) {
                continue;
            }
            vMemSysIDList.push(vMemNode['id']);
            // Add all it's children
            if (vMemNode.hasOwnProperty('children')) {
                vMemNode['children'].forEach(function (n) {
                    vNextVisit.push(n);
                });
            }
        }
        return vMemSysIDList;
    };
    // Returns a subtree that contains all the instructions that connects the memory
    // system and the edges associated with the memory, i.e. LSU's, arbitration and
    // share nodes.
    this.buildMemSysSubtree = function (pMemSysNode, pNodeList) {
        let vSubTreeNodeList = [];
        let vSubTreeEdgeList = [];
        // Find all the edges that connects to that memsys hierarchy. Start by getting all
        // the ID's that belongs to the memory system.
        let vSrcNodeIDList = this.getMemSystemIDs(pMemSysNode);
        let vEdgeList = this.source['links'];
        let vConnectedInstIDList = [];
        vConnectedInstIDList = vConnectedInstIDList.concat(vSrcNodeIDList);
        // Traverse the netlist to find all connected nodes, including arb, share, load and
        // store and respective edges
        // The traversal have a two loops. The outer loop keeps track of where the current
        // source and previously visited. The inner loop iterates through all the edges to
        // find any previous unvisited destinations. Any unvisited destinations and edges 
        // associated to this destionation will be added.
        while (vSrcNodeIDList.length) {
            let vDestNodeIDList = [];
            vEdgeList.forEach(function (e) {
                let vDestNodeID;
                if (vSrcNodeIDList.indexOf(e['from']) >= 0) {
                    vDestNodeID = e['to'];
                }
                else if (vSrcNodeIDList.indexOf(e['to']) >= 0) {
                    vDestNodeID = e['from'];
                }
                // Add edges that is connected and have not been visited previously
                if (vDestNodeID && vConnectedInstIDList.indexOf(vDestNodeID) < 0) {
                    vDestNodeIDList.push(vDestNodeID);
                    vSubTreeEdgeList.push(e);
                }
            });
            // Update the source with newly added destination. And update previously visited
            vSrcNodeIDList = vDestNodeIDList;
            vConnectedInstIDList = vConnectedInstIDList.concat(vDestNodeIDList);
        }
        // Add instructions that's connected to that local memory
        for (let ni = 0; ni < pNodeList.length; ni++) {
            let vInstNode = pNodeList[ni];
            if (vConnectedInstIDList.indexOf(vInstNode['id']) >= 0) {
                vSubTreeNodeList.push(vInstNode);
            }
        }
        vSubTreeNodeList.push(pMemSysNode);
        return { 'nodes': vSubTreeNodeList, 'links': vSubTreeEdgeList };
    };
    // Gets the appropriate subtree and edges from JSON for Kernel and bank view
    // 1) Get the parent function and local memory system user have selected
    let vFunctionList = this.source['nodes'];
    let vFuncNode = this.getFunctionNode();
    if (!vFuncNode) {
        return;
    } // Function not found
    let vMemNode;
    // Get the correct memory system in the local memory node
    for (let ni = 0; ni < vFuncNode['children'].length; ni++) {
        let vNode = vFuncNode['children'][ni];
        if (vNode['type'] === 'memtype' && vNode.hasOwnProperty('children')) {
            vMemNode = this.getMemorySystemNode(vNode['children']);
        }
        if (vMemNode) {
            break;
        }
    }
    if (!vMemNode) {
        return;
    } // Local memory not found
    // 2) Get all the edges and instructions that connects to that memsys hierarchy
    this.subtreeJSON = this.buildMemSysSubtree(vMemNode, vFuncNode['children']);
    this.draw = function (pDiv) {
        clearGraphDiv();
        clearDivContent();
        // Create FPGAGraph and render it
        let lmem_graph = new FPGAGraph(this.subtreeJSON, this.rankdir, (this.bankNodeName ? true : false), null);
        lmem_graph.createSVG('#' + pDiv);
        // Add pan zoom after rendering
        svgPanZoom('#graph', { 'controlIconsEnabled': true,
            'zoomScaleSensitivity': 0.4,
            'maxZoom': 50 });
        refreshAreaVisibility();
        adjustToWindowEvent();
    };
};
/* Display message indicating why there is no graph rendered for the selected
 * entity.
 */
function renderNoGraphForType(graph, title, type, details, message) {
    let contentText;
    switch (type) {
        case 'reg':
            contentText = OPT_AS_REG_DIV;
            break;
        case 'unsynth':
            contentText = UNSYNTH_DIV;
            break;
        case 'untrack':
            contentText = UNTRACK_DIV;
            break;
        case 'no_nodes':
            contentText = NO_NODES_DIV;
            break;
        case 'choose_graph':
            contentText = SELECT_GRAPH_DIV;
            break;
        case 'message':
            contentText = GRAPH_MESSAGE_PREFIX + message + GRAPH_MESSAGE_SUFFIX;
            break;
        default:
            contentText = '';
    }
    $(graph).html(contentText);
    changeDetailsPane(details, title);
}
if (typeof exports == "object" && typeof module != "undefined") {
    module.exports = {
        'FPGAGraph': FPGAGraph,
        'FPGAGVGraph': FPGAGVGraph,
        'FPGALMVGraph': FPGALMVGraph
    };
}
