"use strict";
// disable JSHint warning: Use the function form of "use strict".
// This warning is meant to prevent problems when concatenating scripts that
// aren't strict, but we shouldn't have any of those anyway.
/* jshint -W097 */
/// Global variables
// map< file name/path, position of fileinfo in fileJSON array (which is
// the same as the tab index)>
// i.e. map< file name/path, tab index >
var PREFIX_PAD = '___';
var function_prefix = '';
var fileIndexMap = {};
var PRODUCTS = { NONE: -1,
    ALL: 0,
    OPENCL: 1,
    HLS: 2,
    SYCL: 3
};
var portable_mode = false; // False means the html can only be loaded by IDE
var show_hidden = false;
// Main menu properties
var MENU = {
    SUMMARY: { value: 1, name: 'Summary', view: 'SUMMARY' },
    VIEWERS: { value: 4, name: 'Views', submenu: ['GV', 'divider', 'LMEM', 'SCHEDULE'] },
    THROUGHPUT: { value: 2, name: 'Throughput Analysis', submenu: ['LOOP', 'LOOPVIS', 'divider', 'VERIF'] },
    RESOURCE_UTIL: { value: 3, name: 'Area Analysis', submenu: ['AREA_SYS', 'AREA_SRC', 'INCREMENTAL'] },
    ALPHA: { value: 9, name: 'Alpha Viewers', submenu: ['LOOPVIS'], hidden: true } // only unhide with compiler flag --alpha-tools
};
// Menu views properties
var VIEWS = {
    NONE: { value: 0, name: '', product: PRODUCTS.NONE },
    SUMMARY: { value: 1, name: 'Summary', product: PRODUCTS.ALL },
    //THROUGHPUT:     { value: 20, name: "Performance analysis",   product: PRODUCTS.ALL},
    //PROFILER:    { value: 21, name: "Dynamic profiler",       product: PRODUCTS.ALL},  // TODO: replace with Profiler
    VERIF: { value: 21, name: 'Verification Statistics', product: PRODUCTS.HLS },
    LOOP: { value: 22, name: 'Loop Analysis', product: PRODUCTS.ALL },
    FMAX_II: { value: 23, name: 'f<sub>MAX</sub> II Report (deprecated)', product: PRODUCTS.ALL },
    //QII_STA:     { value: 25, name: "Quartus Critical Paths",       product: PRODUCTS.ALL },
    AREA_SYS: { value: 30, name: 'Area Analysis of System', product: PRODUCTS.ALL },
    AREA_SRC: { value: 31, name: 'Area Analysis of Source (deprecated)', product: PRODUCTS.ALL },
    //QII_RES:     { value: 31, name: "Quartus Resource Utilization", product: PRODUCTS.ALL},
    INCREMENTAL: { value: 32, name: 'Incremental Compile', product: PRODUCTS.OPENCL },
    // PHY_MEM    { value: 33, name: "Physical memory viewer",   product: PRODUCTS.ALL}
    GV: { value: 41, name: 'System Viewer', product: PRODUCTS.ALL, id: 'pipeline' },
    LMEM: { value: 42, name: PREFIX_PAD + ' Memory Viewer', product: PRODUCTS.ALL, id: 'lmem' },
    //EMEM:        { value: 43, name: "External memory viewer", product: PRODUCTS.OPENCL},
    SCHEDULE: { value: 45, name: 'Schedule Viewer (Beta)', product: PRODUCTS.ALL, id: 'schedule' },
    // Insert alpha tools here
    LOOPVIS: { value: 24, name: 'Loops Viewer (Alpha)', product: PRODUCTS.ALL, id: 'loopvis' }
};
var viewHash = []; // initialized in main::initializeViews()
// Main menu properties
var CTRLS = {
    TREE: { name: '&#xe056;', id: 'collapse_tree', collapsed: false, callback: toggleTree },
    SOURCE: { name: '&#xe065;', id: 'collapse_source', collapsed: false, callback: collapseAceEditor },
    DETAILS: { name: '&#xe086;', id: 'collapse_details', collapsed: false, callback: collapseDetails } // "Show/Hide details"
};
var reportPaneWidth = 'col-sm-6';
var viewerGroupWidth = 'col-sm-10';
// vector< fileInfo objects >
var detailValues = [""];
var detailIndex = 0;
var curFile;
var previousFilehash = '#file0';
var detailOptValues = [];
var browserInfo = {};
var view = VIEWS.SUMMARY;
var product = null;
var currentPane = null;
var title = '';
var REPORT_PANE_HTML = "<div class='classWithPad' id='opt-area-panel'><div class='card' id='report-panel-body'><div class='card-header'>";
var NO_SOURCE = 'No Source Line';
var isValidFileList = false; // Also purpose to disable Editor pane and rm #collapse_source button when false
// Editor is disabled when 1) invalid File JSON like -g0 or 2) use by IDE
var isValidInfo = true;
var isValidQuartus = true;
var isValidSystemViewer = true;
var isValidDot = true;
var isValidScheduler = true;
var incrementalJSON = null;
var summaryElement;
var vBottleneckTree;
// function name: { id:<int>, pid:<int>, children:[{name:<(string)block name>,id:<int>,pid:<int>},...]}
/**
 * @function buildFPGASummaryInfo initializes the info section of the summary view first and sets the title
 */
function buildFPGASummaryInfo() {
    // call this at the beginning before the whole document is loaded to save time
    isValidInfo = (typeof infoJSON != "undefined") && (infoJSON = tryParseJSON(infoJSON)) !== null && !$.isEmptyObject(infoJSON);
    // Error out and documnet to user to recompile
    if (!isValidInfo || !infoJSON.hasOwnProperty('compileInfo') || !infoJSON['compileInfo'].hasOwnProperty('nodes') ||
        !Array.isArray(infoJSON['compileInfo']['nodes']) || infoJSON['compileInfo']['nodes'].length == 0 || !infoJSON['compileInfo']['nodes'][0].hasOwnProperty('product')) {
        VIEWS.SUMMARY.valid = true;
        VIEWS.SUMMARY.source = '&nbspReport is invalid!';
        var report = REPORT_PANE_HTML;
        report += VIEWS.SUMMARY.name + "</div><div class='card-body report-body' onscroll='adjustToWindowEvent()'>";
        report += "<div id='area-table-content'></div>";
        $("#report-pane")[0].insertAdjacentHTML("beforeend", "<div id=\"report-pane-view" + VIEWS.SUMMARY.value + "\" class=\"report-pane-view-style\"></div>");
        report += "</div></div></div>";
        $('#report-pane-view' + VIEWS.SUMMARY.value).html(report);
        $('#report-pane-view' + VIEWS.SUMMARY.value + ' #area-table-content').html(VIEWS.SUMMARY.source);
        return;
    }
    ;
    let infoData = infoJSON['compileInfo']['nodes'][0];
    setTitle(); // Set page title
    product = PRODUCTS[infoData['product']]; // fall back in case compiler did not ouptut it
    function_prefix = (product == PRODUCTS.HLS) ? 'Function' : // HLS
        'Kernel'; // OpenCL or SYCL
    // Populate the info first into a card
    summaryElement = document.createElement('div');
    summaryElement.id = "accordion";
    summaryElement.setAttribute('role', 'tablist');
    var compileInfo = new FPGACompileInfo(summaryElement, product);
    compileInfo.draw(true);
    let summaryTree = new FPGASummaryTree(document.getElementById('tree-list'));
    summaryTree.appendChild(compileInfo.getName(), compileInfo.getID());
    VIEWS.SUMMARY['tree'] = summaryTree; // add a new object to the SUMMARY VIEW
    // Sets the title of the html and returns the product value
    function setTitle() {
        title = infoData['name'];
        $('#titleText').html('Report: ' + title);
    }
}
function buildFPGAReportMainMenu() {
    if (!product)
        return false;
    // validate JSON data
    validateJSONData();
    function validateJSONData() {
        let isValidSummary = true;
        let isValidWarnings = true;
        // check if all information is valid
        isValidSummary = (typeof summaryJSON != 'undefined') && (summaryJSON = tryParseJSON(summaryJSON)) !== null;
        isValidWarnings = (typeof warningsJSON != 'undefined') && (warningsJSON = tryParseJSON(warningsJSON)) !== null && !$.isEmptyObject(warningsJSON);
        isValidQuartus = (typeof quartusJSON != 'undefined') && (quartusJSON = tryParseJSON(quartusJSON)) !== null;
        VIEWS.SUMMARY.valid = (isValidSummary && isValidWarnings);
        if (portable_mode) {
            isValidFileList = (typeof fileJSON != 'undefined') && (fileJSON = tryParseJSON(fileJSON)) !== null && !$.isEmptyObject(fileJSON);
        }
        // Throughput Analysis
        // ThroughputSummary = throughputJSON
        VIEWS.LOOP.valid = (typeof loopsJSON != 'undefined') && (loopsJSON = tryParseJSON(loopsJSON)) !== null && !$.isEmptyObject(loopsJSON);
        VIEWS.VERIF.valid = (typeof verifJSON != 'undefined') && (verifJSON = tryParseJSON(verifJSON)) !== null && !$.isEmptyObject(verifJSON);
        // QuartusCriticalPath = QuartusSTAJSON
        // Area Analysis
        VIEWS.AREA_SYS.valid = (typeof areaJSON != 'undefined') && (areaJSON = tryParseJSON(areaJSON)) !== null && !$.isEmptyObject(areaJSON);
        // Deal with JSON files for incremental compilation flow.  There may be two different
        // incremental JSON files, depending on whether this is an incremental setup
        // compile (incremental_initialJSON), or an incremental change
        // (incremental_changeJSON).  We deal with both of them the same throughout
        // the rest of the reports, so just merge them into 'incrementalJSON'.
        var isValidIncrementalInitial = (typeof incremental_initialJSON != 'undefined') && (incremental_initialJSON = tryParseJSON(incremental_initialJSON)) !== null && !$.isEmptyObject(incremental_initialJSON);
        var isValidIncrementalChange = (typeof incremental_changeJSON != 'undefined') && (incremental_changeJSON = tryParseJSON(incremental_changeJSON)) !== null && !$.isEmptyObject(incremental_changeJSON);
        VIEWS.INCREMENTAL.valid = isValidIncrementalInitial || isValidIncrementalChange;
        incrementalJSON = isValidIncrementalInitial ? incremental_initialJSON : isValidIncrementalChange ? incremental_changeJSON : null;
        // Viewers
        checkHierarchyTreeData();
        isValidSystemViewer = (typeof mavJSON != 'undefined') && (mavJSON = tryParseJSON(mavJSON)) !== null && !$.isEmptyObject(mavJSON);
        let isValidSoTViewer = (typeof systemJSON != 'undefined') && (systemJSON = tryParseJSON(systemJSON)) !== null && !$.isEmptyObject(systemJSON);
        // FunctionViewer    = FuncJSON
        VIEWS.LMEM.valid = (typeof new_lmvJSON != 'undefined') && (new_lmvJSON = tryParseJSON(new_lmvJSON)) !== null && !$.isEmptyObject(new_lmvJSON);
        let isValidBlockViewer = (typeof blockJSON != 'undefined') && (blockJSON = tryParseJSON(blockJSON)) !== null && !$.isEmptyObject(blockJSON);
        let isValidClusterViewer = (typeof pipelineJSON != 'undefined') && (pipelineJSON = tryParseJSON(pipelineJSON)) !== null && !$.isEmptyObject(pipelineJSON);
        VIEWS.GV.valid = (isValidHierarchyTree() || isValidSystemViewer || isValidSoTViewer || isValidBlockViewer || isValidClusterViewer);
        VIEWS.SCHEDULE.valid = (typeof scheduleJSON != 'undefined') && (scheduleJSON = tryParseJSON(scheduleJSON)) !== null && !$.isEmptyObject(scheduleJSON);
        // Alpha level viewers
        VIEWS.LOOPVIS.valid = (typeof loop_attrJSON != 'undefined') && (loop_attrJSON = tryParseJSON(loop_attrJSON)) !== null && !$.isEmptyObject(loop_attrJSON) &&
            (typeof bottleneckJSON != 'undefined') && (bottleneckJSON = tryParseJSON(bottleneckJSON)) !== null && !$.isEmptyObject(bottleneckJSON) &&
            (typeof blockJSON != 'undefined') && (blockJSON = tryParseJSON(blockJSON)) !== null && !$.isEmptyObject(blockJSON);
        VIEWS.AREA_SRC.valid = (typeof area_srcJSON != 'undefined') && (area_srcJSON = tryParseJSON(area_srcJSON)) !== null && !$.isEmptyObject(area_srcJSON);
    }
    // Add the view number
    Object.keys(VIEWS).forEach(function (v) {
        var index = VIEWS[v];
        if (index.hash === undefined)
            index.hash = '#view' + index.value;
    });
    // configure the menu
    if (typeof alpha_viewer != 'undefined' && alpha_viewer)
        show_hidden = true;
    // remove unused/invalid views and disable views that doesn't have data yet
    disableInvalidViews();
    generateTablesHTML();
    // This is to be obseleted as we can render the table on demand
    // parse the valid JSONs that's rendering into HTML tables.
    function generateTablesHTML() {
        // Populate all the table data: area, summary, loops, fmax/II, verification
        // Sets a valid flag in the VIEW
        if (VIEWS.hasOwnProperty("AREA_SYS") && VIEWS.AREA_SYS.valid) {
            VIEWS.AREA_SYS.source = parseAreaData(areaJSON);
        }
        if (VIEWS.hasOwnProperty("AREA_SRC") && VIEWS.AREA_SRC.valid) {
            VIEWS.AREA_SRC.source = parseAreaData(area_srcJSON);
        }
        // Two cases: compile (full or -rtl) or Quartus only
        if (VIEWS.hasOwnProperty("SUMMARY")) {
            let quartusClockSummary = null;
            let systemResUtilSumamry = null; // OpenCL and SYCL only because they have BSP
            let quartusResUtilSummary = null;
            let resourceUtilSummary = null;
            let functionSummary = null;
            let kernelSummary = null;
            let warningSummary = null;
            if (VIEWS.SUMMARY.valid)
                warningSummary = new FPGAWarningSummary(summaryElement);
            if (isValidQuartus && VIEWS.SUMMARY.valid) {
                // Display full summary
                quartusClockSummary = new FPGAClockFreqSummary(summaryElement, product);
                if (product === PRODUCTS.HLS) {
                    functionSummary = new FPGAFunctionSummary(summaryElement);
                }
                else { // OpenCL or SYCL
                    kernelSummary = new FPGAKernelSummary(summaryElement);
                    systemResUtilSumamry = new FPGAOpenCLResourceSummary(summaryElement, product);
                }
                quartusResUtilSummary = new FPGAQuartusResourceSummary(summaryElement, product);
                resourceUtilSummary = new FPGAResourceEstSummary(summaryElement, product);
            }
            else if (isValidQuartus) {
                // Quartus data and Summary have to be valid at a minimum, but data can be empty
                quartusClockSummary = new FPGAClockFreqSummary(summaryElement, product);
                quartusResUtilSummary = new FPGAQuartusResourceSummary(summaryElement, product);
            }
            // Create table of content for summary
            let summaryTree = VIEWS.SUMMARY['tree'];
            if (functionSummary !== null) {
                functionSummary.draw(true);
                summaryTree.appendChild(functionSummary.getName(), functionSummary.getID());
            }
            if (kernelSummary !== null) {
                kernelSummary.draw(true);
                summaryTree.appendChild(kernelSummary.getName(), kernelSummary.getID());
            }
            if (quartusClockSummary !== null) {
                quartusClockSummary.draw(false);
                summaryTree.appendChild(quartusClockSummary.getName(), quartusClockSummary.getID());
            }
            if (systemResUtilSumamry !== null) {
                systemResUtilSumamry.draw(false);
                summaryTree.appendChild(systemResUtilSumamry.getName(), systemResUtilSumamry.getID());
            }
            if (quartusResUtilSummary !== null) {
                quartusResUtilSummary.draw(false);
                summaryTree.appendChild(quartusResUtilSummary.getName(), quartusResUtilSummary.getID());
            }
            if (resourceUtilSummary !== null) {
                resourceUtilSummary.draw(false);
                summaryTree.appendChild(resourceUtilSummary.getName(), resourceUtilSummary.getID());
            }
            if (warningSummary !== null) {
                warningSummary.draw(false);
                summaryTree.appendChild(warningSummary.getName(), warningSummary.getID());
            }
            VIEWS.SUMMARY.source = summaryElement.outerHTML;
        }
        if (VIEWS.hasOwnProperty('VERIF') && VIEWS.VERIF.valid) {
            VIEWS.VERIF.source = parseVerifData(verifJSON);
        }
        if ((VIEWS.hasOwnProperty('INCREMENTAL') && VIEWS.INCREMENTAL.valid)) {
            VIEWS.INCREMENTAL.source = parseIncrementalData(incrementalJSON);
        }
    }
    // control menu for collipasing source and details, navigation bar, and views
    initializeControlMenu();
    initializeNavBar();
    if (isValidFileList) {
        // Add file tabs to the Editor pane dropdown
        addFileTabs(fileJSON);
    }
    else {
        if (!CTRLS.SOURCE.collapsed)
            toggleAceEditor();
    }
    adjustToWindowEvent();
    return true;
    //----------- VIEWS FUNCTION ------------//
    // create the collapsible hamburger menu
    // controls are specified in CTRL dictionary
    function initializeControlMenu() {
        Object.keys(CTRLS).forEach(function (c) {
            // don't create controls for source in menu if no file list
            if (c === 'SOURCE' && !isValidFileList)
                return;
            let vTmpDiv = newFPGAElement(document.getElementById('collapse-ctrl'), 'button', 'btn btn-secondary-outline', CTRLS[c].id, '');
            vTmpDiv.setAttribute('type', 'button');
            vTmpDiv.href = '#';
            vTmpDiv.style.backgroundColor = 'white';
            // tooltip
            vTmpDiv.setAttribute('data-toggle', 'tooltip');
            vTmpDiv.setAttribute('data-html', 'true');
            vTmpDiv.setAttribute('data-placement', 'bottom');
            let toolTipHtml = lookUpTerminology(c, false);
            if (toolTipHtml !== '') {
                vTmpDiv.title = toolTipHtml;
            }
            if (CTRLS[c].hasOwnProperty('callback'))
                vTmpDiv.addEventListener('click', CTRLS[c].callback);
            vTmpDiv = newFPGAElement(vTmpDiv, 'span', 'body glyphicon', CTRLS[c].id + 'Text', CTRLS[c].name);
            vTmpDiv.style.color = '#007bff';
            // Also add to close button in card
            if (c === 'SOURCE')
                document.getElementById('close-source').addEventListener('click', CTRLS[c].callback);
            else if (c === 'DETAILS')
                document.getElementById('close-details').addEventListener('click', CTRLS[c].callback);
        });
    }
    // Populate main-menu html element with MENU and VIEWS data structure
    // The MENU name becomes navigation bar. The view name becomes drop down item when exist
    function initializeNavBar() {
        // create a div for each view, and set it to "hidden"; also create
        // a menu entry for each view
        Object.keys(MENU).forEach(function (m) {
            var views = MENU[m];
            if (views.hidden !== undefined && !show_hidden)
                return;
            if (views.view !== undefined) {
                // no submenu, the menu is the view
                let v = MENU[m].view;
                // TODO: Factor these out to initializeViews to allow unittest initializeNavBar
                let index = VIEWS[v];
                viewHash[index.hash] = v;
                addReportColumn(index);
                let navButton = document.createElement('a');
                navButton.setAttribute('role', 'button');
                navButton.innerHTML = index.name;
                navButton.setAttribute('data-toggle', 'tooltip');
                navButton.setAttribute('data-html', 'true');
                navButton.setAttribute('data-placement', 'right');
                if (index.valid) {
                    navButton.className = 'btn btn-outline-primary';
                    navButton.href = index.hash;
                }
                else {
                    navButton.className = 'btn btn-outline-primary disable';
                }
                // Add tooltip if exist
                let toolTipHtml = lookUpTerminology(v, !index.valid);
                if (toolTipHtml !== '') {
                    navButton.title = toolTipHtml;
                }
                $('#main-menu').append(navButton);
            }
            else {
                // has submenu, add the menu as dropdown
                let navDropDownGroup = document.createElement('div');
                navDropDownGroup.className = 'dropdown';
                let navButton = document.createElement('button');
                navButton.className = 'btn btn-outline-primary dropdown-toggle';
                navButton.type = 'button';
                navButton.setAttribute('data-toggle', 'dropdown');
                navButton.innerHTML = views.name;
                navDropDownGroup.appendChild(navButton);
                let navDropDown = document.createElement('div');
                navDropDown.className = 'dropdown-menu';
                Object.keys(views.submenu).forEach(function (vkey) {
                    let v = views.submenu[vkey];
                    if (v === 'divider') {
                        let separatorElement = document.createElement('div');
                        separatorElement.className = 'dropdown-divider';
                        navDropDown.appendChild(separatorElement);
                    }
                    else if (VIEWS[v] !== undefined) {
                        // Don't add removed views
                        let index = VIEWS[v];
                        if (index.name === undefined || index.name === '') {
                            console.warn('Error! VIEW ' + v + ' has no name.');
                            return;
                        }
                        viewHash[index.hash] = v;
                        if (index.valid) {
                            addReportColumn(index);
                        } // Temporary workaround for incremental since it parses JSON in addReportColumn
                        let dropDownItem = document.createElement('a');
                        dropDownItem.id = v;
                        dropDownItem.innerHTML = index.name;
                        dropDownItem.setAttribute('data-toggle', 'tooltip');
                        dropDownItem.setAttribute('data-html', 'true');
                        dropDownItem.setAttribute('data-placement', 'right');
                        if (index.valid) {
                            dropDownItem.className = 'dropdown-item';
                            dropDownItem.href = index.hash;
                        }
                        else {
                            dropDownItem.className = 'dropdown-item disabled';
                            dropDownItem.href = '#';
                        }
                        let toolTipHtml = lookUpTerminology(v, !index.valid);
                        if (toolTipHtml !== "") {
                            dropDownItem.title = toolTipHtml;
                        }
                        navDropDown.appendChild(dropDownItem);
                    }
                });
                navDropDownGroup.appendChild(navDropDown);
                $('#main-menu').append(navDropDownGroup);
            }
        });
        // display the current view
        currentPane = '#report-pane-view' + view.value;
        $(currentPane).toggle();
    }
    // Remove invalid views from the VIEWS object for the given product
    // Disable views are invalid if the JSON is missing or invalid, and add prefix to view name
    // In the event that we cannot determine the product, then we only show the minimum set of data defined by "PRODUCTS.ALL"
    function disableInvalidViews() {
        Object.keys(VIEWS).forEach(function (v) {
            var sel_view = VIEWS[v];
            if (sel_view.product != PRODUCTS.ALL && (product === undefined || sel_view.product != product)) {
                // view doesn't belong to this product
                delete VIEWS[v];
                return;
            }
            if (!sel_view.valid) {
                // view is disabled because JSON is invalid
                return;
            }
            // add clickDown and source fields for parsing the JSON data later
            sel_view.clickDown = null;
            sel_view.source = null;
            // Prepend 'Kernel' or 'Component' for different views depending on product
            sel_view.name = sel_view.name.replace(PREFIX_PAD, function_prefix);
        });
    }
    // add data to the report pane
    function addReportColumn(reportEnum) {
        var report = REPORT_PANE_HTML;
        if (reportEnum != VIEWS.GV && reportEnum != VIEWS.LMEM && reportEnum != VIEWS.SCHEDULE && reportEnum != VIEWS.LOOPVIS) {
            // Temporary workaround until tables are refactored
            $("#report-pane")[0].insertAdjacentHTML("beforeend", "<div id=\"report-pane-view" + reportEnum.value + "\" class=\"report-pane-view-style\"></div>");
            $('#report-pane-view' + reportEnum.value).toggle();
        }
        // bottleneck tree is global to every view
        if (vBottleneckTree === undefined) {
            vBottleneckTree = new FPGABottleneckTree(document.getElementById('outline-list'));
        }
        let reportPane, reportBody, reportView;
        switch (reportEnum) {
            case VIEWS.SUMMARY:
                report += reportEnum.name + "</div><div class='card-body report-body' id='report-summary' onscroll='adjustToWindowEvent()'>";
                report += "<div id='area-table-content'></div>";
                break;
            case VIEWS.LOOP:
                var vLoopTree = new FPGALoopTree(document.getElementById('tree-list')); // Draw until in the loops view
                reportEnum['tree'] = vLoopTree;
                return;
            case VIEWS.VERIF:
                report += reportEnum.name + "</div><div class='card-body report-body' onscroll='adjustToWindowEvent()'>";
                report += "<table class='table table-hover areatable' id='area-table-content'></table>";
                break;
            case VIEWS.AREA_SYS:
                reportEnum['tree'] = new FPGAAreaTree(document.getElementById('tree-list')); // Draw until in the loops view
            case VIEWS.AREA_SRC:
                report += "<table style='width:100%' class='areatable'><tr><td class='panel-heading-text'>";
                report += "<span style='font-size:1rem;'>" + reportEnum.name + "</span>";
                report += "<br>(area utilization values are estimated)<br>Notation <i>file:X</i> > <i>file:Y</i> indicates a function call on line X was inlined using code on line Y.";
                if (VIEWS.AREA_SYS.valid && VIEWS.hasOwnProperty("INCREMENTAL") && VIEWS.INCREMENTAL.valid) {
                    report += '<br><strong>Note: Area report accuracy may be reduced when performing an incremental compile.</strong>';
                }
                if (VIEWS.AREA_SYS.valid && !areaJSON.debug_enabled) {
                    report += '<br><strong>Recompile without <tt>-g0</tt> for detailed area breakdown by source line.</strong>';
                }
                report += '</td><td>';
                report += "<span style='font-size:1rem;float:right'>";
                report += "<button id='collapseAll' type='button' class='text-left exp-col-btn'><span class='body glyphicon'>&#xe160;</span>&nbsp;Collapse All&nbsp;</button>";
                report += "<button id='expandAll' type='button' class='text-left exp-col-btn'><span class='body glyphicon'>&#xe158;</span>&nbsp;Expand All&nbsp;</button>";
                report += '</span>';
                report += '</td></tr></table>';
                report += "</div><div class='card-body report-body' id='report-area' onscroll='adjustToWindowEvent()'>";
                report += "<table class='table table-hover areatable' id='area-table-content'></table>";
                break;
            case VIEWS.INCREMENTAL:
                if (incrementalJSON.hasOwnProperty('name')) { // This needs to be refactor. Should not be parsing JSON here
                    report += incrementalJSON.name;
                }
                else {
                    report += reportEnum.name;
                }
                if (incrementalJSON.hasOwnProperty('details')) {
                    report += '<hr/>';
                    incrementalJSON.details.forEach(function (d) {
                        report += '<li>' + d.text + '</li>';
                    });
                }
                report += '</div>';
                report += "<div class='card-body report-body' onscroll='adjustToWindowEvent()'>";
                report += "<table class='table table-hover areatable' id='area-table-content'></table>";
                break;
            case VIEWS.LMEM:
                reportView = document.createElement('div');
                reportView.id = 'report-pane-view' + reportEnum.value;
                reportView.className = 'report-pane-view-style';
                reportBody = addViewerPanel(reportEnum, 'layers-lmem', 'LMEMG');
                reportView.appendChild(reportBody);
                reportPane = document.getElementById('report-pane');
                reportPane.appendChild(reportView);
                $('#report-pane-view' + reportEnum.value).toggle();
                return;
            case VIEWS.GV:
                reportView = document.createElement('div');
                reportView.id = 'report-pane-view' + reportEnum.value;
                reportView.className = 'report-pane-view-style';
                reportBody = addViewerPanel(reportEnum, 'layers', 'GVG');
                reportView.appendChild(reportBody);
                reportPane = document.getElementById('report-pane');
                reportPane.appendChild(reportView);
                $('#report-pane-view' + reportEnum.value).toggle();
                return;
            case VIEWS.SCHEDULE:
                reportView = document.createElement('div');
                reportView.id = 'report-pane-view' + reportEnum.value;
                reportView.className = 'report-pane-view-style';
                reportBody = addViewerPanel(reportEnum, 'layers', 'SVCBeta');
                reportView.appendChild(reportBody);
                reportPane = document.getElementById('report-pane');
                reportPane.appendChild(reportView);
                $('#report-pane-view' + reportEnum.value).toggle();
                return;
            case VIEWS.LOOPVIS:
                reportView = document.createElement('div');
                reportView.id = 'report-pane-view' + reportEnum.value;
                reportView.className = 'report-pane-view-style';
                reportBody = addViewerPanel(reportEnum, 'layers', 'LVAlpha');
                reportView.appendChild(reportBody);
                reportPane = document.getElementById('report-pane');
                reportPane.appendChild(reportView);
                $('#report-pane-view' + reportEnum.value).toggle();
                return;
        }
        report += '</div></div></div>';
        $('#report-pane-view' + reportEnum.value).html(report);
        $('#report-pane-view' + reportEnum.value + ' #area-table-content').html(reportEnum.source);
    }
}
///// Global functions
// Add the passed-in HDL filename to the source code pane, and display it,
// creating a new ACE editor object if necessary.
function addHdlFileToEditor(file) {
    var rawFile = new XMLHttpRequest();
    rawFile.open("GET", file, false);
    rawFile.onreadystatechange = function () {
        if (rawFile.readyState === 4) {
            if (rawFile.status === 200 || rawFile.status === 0) {
                var allText = rawFile.responseText;
                // Create the editor if it doesn't exist
                if (dot_editor === null) {
                    var count = $('#editor-pane-nav li').length;
                    $("#editor-pane-nav").append("<li><a data-target='#file" + count + "'>HDL</a><p></p></li>");
                    fileIndexMap.HDL = count;
                    var editor_div = "<div class='tab-pane' id='file" + count + "' style='height:500px;'>";
                    editor_div += "<div class='well' id='dot_editor_well'></div></div>";
                    $('#editor-pane .tab-content').append(editor_div);
                    dot_editor = ace.edit($('#dot_editor_well')[0]);
                    dot_editor.setTheme('../ace/theme/xcode');
                    dot_editor.setFontSize(12);
                    dot_editor.getSession().setUseWrapMode(true);
                    dot_editor.getSession().setNewLineMode('unix');
                    fileJSON.push({ 'editor': dot_editor, 'absName': 'HDL', 'name': 'HDL', 'path': 'HDL', 'content': allText });
                }
                // Set the file content
                if (file.endsWith('.vhd')) {
                    dot_editor.getSession().setMode('../ace/mode/vhdl');
                }
                else {
                    dot_editor.getSession().setMode('../ace/mode/verilog');
                }
                dot_editor.setValue(allText.replace(/(\r\n)/gm, '\n'));
                dot_editor.setReadOnly(true);
                syncEditorPaneToLine(1, 'HDL');
            }
            else {
                alert('Something went wrong trying to get HDL file', file);
            }
        }
    };
    rawFile.send(null);
}
function zoomed() {
    var graph = d3.select('#svg_container svg g');
    graph.attr('transform', 'translate(' + d3.event.translate + ')scale(' + d3.event.scale + ')');
}
function adjustToWindowEvent() {
    setReportPaneHeight();
    stickTableHeader();
    if (!CTRLS.SOURCE.collapsed)
        adjustEditorButtons();
    var svg = $('#svg_container svg');
    if (svg.length > 0) {
        svg[0].style.width = $('#svg_container').width();
        svg[0].style.height = $('#svg_container').height();
    }
}
function resizeEditor() {
    if (CTRLS.SOURCE.collapsed)
        return;
    var editor;
    for (var i = 0; i < fileJSON.length; i++) {
        if (fileJSON[i].name == curFile || fileJSON[i].path == curFile) {
            editor = fileJSON[i].editor;
            break;
        }
    }
    if (editor)
        editor.resize();
}
function refreshAreaVisibility() {
    $(currentPane + ' #area-table-content tr').each(function () {
        if ($(this).attr('data-level') == '0' && $(this).is(':hidden')) {
            $(this).toggle();
        }
    });
}
function updateURLHash() {
    if (history.pushState) {
        history.pushState(null, null, view.hash);
    }
    else {
        location.hash(view.hash);
    }
}
function goToView(viewId, update) {
    var newView = VIEWS[viewId];
    let hasTree = false;
    if (!newView) {
        updateURLHash();
        return;
    }
    if (view != newView) {
        $(currentPane).toggle();
        document.getElementById('tree-list').innerHTML = '';
        view = newView;
        currentPane = '#report-pane-view' + view.value;
        $(currentPane).toggle();
        if (view.clickDown !== null && view.clickDown.getAttribute('index')) {
            changeDivContent(view.clickDown.getAttribute('index'));
        }
        else {
            changeDivContent(0);
        }
    }
    if (update) {
        updateURLHash();
    }
    // clear details pane before switching between views
    clearDivContent();
    top_node_id = -1;
    showTree();
    let systemTree;
    let systemNodeName = (product === PRODUCTS.HLS) ? 'System' : 'Kernel system';
    let addGlobalMemoryNode = (product === PRODUCTS.HLS) ? false : true;
    switch (view) {
        case VIEWS.SUMMARY:
        case VIEWS.AREA_SYS:
            view['tree'].draw();
            vBottleneckTree.draw('');
            break;
        case VIEWS.LOOP:
            view['tree'].draw();
            if (!vLoopInfoTable) {
                // initialize for the first time
                vLoopInfoTable = new FPGALoop(document.getElementById('report-pane-view' + view.value));
                vBottleneckTree.draw({ 'message': 'Click on loop list to see bottleneck information' });
            }
            else {
                vBottleneckTree.draw(vLoopInfoTable.getTreeData());
            }
            // remap the the callback because the tree was deleted
            view['tree'].tree.clickCallback = function (pNodeName) {
                vLoopInfoTable.draw(pNodeName);
                vBottleneckTree.draw(pNodeName, false); // false = no checkbox
            };
            break;
        case VIEWS.LOOPVIS:
            vBottleneckTree.draw('');
            createTreeCard(document.getElementById('tree-list'), getTreeIDName(view.id), view.name.replace('Viewer', 'List'), false);
            let hasLoopTree = addHierarchyTree(view);
            if (hasLoopTree)
                renderLoopVis([], -1);
            else
                $('#' + getViewerConst().gid).html('&nbspSystem is empty.');
            break;
        case VIEWS.LMEM:
            vBottleneckTree.draw('');
            createTreeCard(document.getElementById('tree-list'), getTreeIDName(view.id), view.name.replace('Viewer', 'List'), true);
            if (VIEWS.LMEM.valid) {
                var hasLMem = addHierarchyTree(VIEWS.LMEM);
                if (hasLMem)
                    $('#LMEMG').html('<br>&nbspClick on a memory variable to render it!');
                else
                    $('#LMEMG').html('&nbspThere is no ' + function_prefix + ' memory variable in the design file!');
            }
            else
                $('#LMEMG').html('&nbsp ' + view.name + ' data is invalid!');
            break;
        case VIEWS.GV:
            systemTree = new FPGASystemViewerTree(document.getElementById('tree-list'), title, systemNodeName);
            systemTree.draw(false, addGlobalMemoryNode); // recursive to add all hierarhcy
            systemTree.tree.clickCallback = systemTree.renderSystemGraph;
            vBottleneckTree.draw('');
            break;
        case VIEWS.SCHEDULE:
            systemTree = new FPGASystemViewerTree(document.getElementById('tree-list'), title, systemNodeName);
            systemTree.draw(true, addGlobalMemoryNode); // Function only
            systemTree.tree.clickCallback = systemTree.renderScheduleChart;
            vBottleneckTree.draw({ 'message': 'Click on a ' + function_prefix + ' to see bottleneck information' });
            break;
        case VIEWS.VERIF:
        case VIEWS.AREA_SRC:
            hideTree();
            break;
    }
    refreshAreaVisibility();
    adjustToWindowEvent();
}
function unsetClick() {
    if (view.clickDown !== null) {
        view.clickDown.classList.remove('nohover');
        view.clickDown.classList.remove('selected-item-highlight');
        view.clickDown = null;
        changeDivContent(0);
    }
}
// Go to the requested view when the URL hash is changed
$(window).on('hashchange', function () {
    var hash_view = window.location.hash.split("/")[0];
    goToView(viewHash[hash_view]);
});
/*****************************************/
/* Main Template initialization */
/*****************************************/
$(document).ready(function () {
    identifyBrowser();
    var isBrowser = browserInfo.isOpera || browserInfo.isSafari || browserInfo.isFirefox || browserInfo.isChrome; // remove the condition for browserInfo.isIE as MS VS uses IE APIs.
    if (!portable_mode && isBrowser) { // and using a browser
        if (!CTRLS.SOURCE.collapsed)
            toggleAceEditor();
        if (!CTRLS.DETAILS.collapsed)
            toggleDetails();
        if (!CTRLS.TREE.collapsed)
            toggleTree();
        displayBrowserNotSupportedWarning();
        return;
    }
    if (browserInfo.isOpera || browserInfo.isSafari) {
        // TODO: annotate this message to the top of the report for final beta release
        alert('Browser not supported');
    }
    if (!buildFPGAReportMainMenu())
        return;
    $('label.tree-toggle').click(function () {
        $(this).parent().children('ul.tree').toggle(200);
    });
    if (window.location.hash === '') {
        updateURLHash();
    }
    var hash_view = window.location.hash.split('/')[0];
    goToView(viewHash[hash_view]);
    $(window).resize(function () {
        adjustToWindowEvent();
        resizeEditor();
    });
    function getChildren($row) {
        var children = [], level = $row.attr('data-level');
        var isExpanding;
        var maxExpandedLevel = Number(level) + 1;
        // Check if expanding or collapsing
        if ($row.next().is(':hidden')) {
            isExpanding = true;
        }
        else {
            isExpanding = false;
        }
        while ($row.next().attr('data-level') > level) {
            // Always expand or collapse immediate child
            if ($row.next().attr('data-level') - 1 == level) {
                children.push($row.next());
                $row.next().attr('data-ar-vis', $row.next().attr('data-ar-vis') == 1 ? 0 : 1);
            }
            else {
                // expand if previously was expanded and parent has been expanded - maxExpandedLevel is used to tell if a child's immediate parent has been expanded
                if ($row.next().attr('data-ar-vis') == 1 && isExpanding && $row.next().attr('data-level') <= (maxExpandedLevel + 1)) {
                    children.push($row.next());
                    maxExpandedLevel = Math.max(maxExpandedLevel, $row.next().attr('data-level'));
                    // collapse if visible and element is some descendant of row which has been clicked
                }
                else if (!isExpanding && $row.next().is(":visible")) {
                    children.push($row.next());
                }
            }
            $row = $row.next();
        }
        return children;
    }
    // Expand or collapse when parent table row clicked
    $('#report-pane').on('click', '.parent', function () {
        var children = getChildren($(this));
        $.each(children, function () {
            $(this).toggle();
        });
        toggleChevon($(this).find('.ar-toggle')[0], 'none');
        stickTableHeader();
    });
    $('#report-pane').on('click', 'tr', function (d) {
        // do not change clicked state if we click an anchor (ie expand/collapse chevron)
        if (d.target.tagName.toLowerCase() === 'a')
            return;
        // traverse up the DOMtree until we get to the table row
        for (d = d.target; d && d !== document; d = d.parentNode) {
            if (d.tagName.toLowerCase() === 'tr')
                break;
        }
        // check to see if row is 'clickable'
        if (!$(this).attr('clickable'))
            return;
        if (view.clickDown == d) {
            // deselect row
            unsetClick();
        }
        else {
            // else select new row
            if (view.clickDown) {
                // deselect previous row
                unsetClick();
            }
            if ($(this).attr('index')) {
                // update "details" pane
                changeDivContent($(this).attr('index'));
            }
            view.clickDown = d;
            d.classList.add('nohover');
            d.classList.add('selected-item-highlight');
        }
    });
    // Display details on mouseover
    $('#report-pane').on('mouseover', 'tr', function () {
        if (view.clickDown === null && $(this).attr('index') && CTRLS.DETAILS.collapsed === false) {
            changeDivContent($(this).attr('index'));
        }
    });
    $('.dropdown_nav').on('click', function () {
        // Clicking a .dropdown_nav item changes the page hash.
        // If the onHashChange event is supported in the browser, we will change views
        // using the corresponding event handler. Otherwise, do it explicitly here.
        if (!('onhashchange' in window)) {
            var viewId = $(this).attr("viewId");
            goToView(viewId);
        }
    });
    // Editor navigation dropdown event
    $('#editor-nav-button').change(function () {
        let newFileIndex = $(this).val();
        $(previousFilehash).removeClass('active');
        $(newFileIndex).addClass('active');
        previousFilehash = newFileIndex;
    });
    // Tool tip for menu
    $(function () {
        $('[data-toggle="tooltip"]').tooltip({
            trigger: 'hover'
        });
    });
    // Expand all the rows in area table
    $('#report-pane').on('click', '#expandAll', function () {
        // Get all the rows in the table which can expand/collapse
        var parents = $(currentPane + ' .parent');
        $.each(parents, function () {
            // Toggle all the children of that parent row
            var children = getChildren($(this));
            $.each(children, function () {
                // Set the data-ar-vis to be one so that it will expand afterwards
                $(this).attr('data-ar-vis', 1);
                // Only toggle if row is hidden and need to expand, or visible and need to collapse
                if ($(this).is(':hidden'))
                    $(this).toggle();
            });
            // Make all the arrow icons pointing down
            var iconsToToggle = $(this).find('.ar-toggle');
            $.each(iconsToToggle, function () { toggleChevon($(this)[0], 'down'); });
        });
        stickTableHeader();
    });
    // Collapse all the rows in area table
    $('#report-pane').on('click', '#collapseAll', function () {
        // Get all the rows in the table which can expand/collapse
        var parents = $(currentPane + ' .parent').toArray().reverse();
        $.each(parents, function () {
            // Toggle all the children of that parent row
            var children = getChildren($(this));
            $.each(children, function () {
                // Set the data-ar-vis to be zero so that the row states resets
                $(this).attr('data-ar-vis', 0);
                // Only toggle if row is hidden and need to expand, or visible and need to collapse
                if (!$(this).is(':hidden'))
                    $(this).toggle();
            });
            // Make all the arrow icons pointing down
            var iconsToToggle = $(this).find('.ar-toggle');
            $.each(iconsToToggle, function () { toggleChevon($(this)[0], 'right'); });
        });
        stickTableHeader();
    });
    // DOT viewer controls
    $('#report-pane').on('click', '#dot_up_hierarchy', function () {
        var hash = window.location.hash.split('/');
        hash.pop();
        if (hash.length > 1)
            goToDot(hash.join('/'));
    });
    $('#report-pane').on('click', '#dot_top_hierarchy', function () {
        goToDot('#dot/' + dot_top);
    });
    $('#report-pane').on('click', '#dot_edges_toggle', function (d) {
        if ($(this).is(':checked')) {
            $('#svg_container').find('g.edge').toggle();
        }
        else {
            $('#svg_container').find('g.edge').toggle();
        }
    });
});
// Function given by IDE
// populates browserInfo and determine which browser is being used to open report.html
function identifyBrowser() {
    //find browser version:
    browserInfo.isOpera = !!window.opera || navigator.userAgent.indexOf(' OPR/') >= 0; // Opera 8.0+ (UA detection to detect Blink/v8-powered Opera)
    browserInfo.isFirefox = typeof InstallTrigger !== 'undefined'; // Firefox 1.0+
    browserInfo.isSafari = Object.prototype.toString.call(window.HTMLElement).indexOf('Constructor') > 0; // At least Safari 3+: "[object HTMLElementConstructor]"
    browserInfo.isChrome = !!window.chrome && !browserInfo.isOpera; // Chrome 1+
    browserInfo.isIE = /*@cc_on!@*/ false || !!document.documentMode; // At least IE6
}
// Function given by IDE
// Issue a warning in the report div saying the report can only be open by IDE
function displayBrowserNotSupportedWarning() {
    // create a warning box:
    var warningWrapper = $('#report-pane');
    // warningWrapper.className = 'warningWrapper';
    var warningContainer = document.createElement('div');
    warningContainer.className = 'warningContainer';
    $(warningWrapper).append(warningContainer);
    var title = document.createElement('h2');
    title.innerHTML = 'WARNING!';
    $(warningContainer).append(title);
    var message = document.createElement('div');
    message.style.textAlign = 'left';
    message.style.marginLeft = '20px';
    message.style.marginRight = '20px';
    var span1 = document.createElement('span');
    span1.innerHTML = 'Your browser is not supported to view the report<br/>' +
        'Please use Intel oneAPI IDE.<br/><br/>';
    message.appendChild(span1);
    $(warningContainer).append(message);
    $(warningWrapper).hide().fadeIn(1000);
}
function toggleDetails() {
    $('#detail-pane').toggle();
    CTRLS.DETAILS.collapsed = !CTRLS.DETAILS.collapsed;
    if (CTRLS.DETAILS.collapsed) {
        // when details is collapsed, clear it
        clearDivContent();
    }
    else if (view.clickDown) {
        // when details is un-collapsed, update contents, if valid
        changeDivContent(view.clickDown.getAttribute('index'));
    }
    adjustToWindowEvent();
    resizeEditor();
}
// Use to toggle source - use by collaspe source button
function collapseDetails() {
    toggleDetails();
    let vIcon = document.getElementById(CTRLS.DETAILS.id + 'Text');
    vIcon.style.color = (CTRLS.DETAILS.collapsed) ? 'lightgray' : '#007bff';
}
function toggleAceEditor() {
    $('#editor-pane').toggle();
    CTRLS.SOURCE.collapsed = !CTRLS.SOURCE.collapsed;
    adjustReportPaneWidth();
    adjustToWindowEvent();
    resizeEditor();
}
// Use to toggle Editor - use by collaspe source button
function collapseAceEditor() {
    toggleAceEditor();
    let vIcon = document.getElementById(CTRLS.SOURCE.id + 'Text');
    vIcon.style.color = (CTRLS.SOURCE.collapsed) ? 'lightgray' : '#007bff';
}
function showTree() {
    if (!CTRLS.TREE.collapsed) {
        return;
    }
    else {
        toggleTree();
    }
}
function hideTree() {
    if (CTRLS.TREE.collapsed) {
        return;
    }
    else {
        toggleTree();
    }
}
// Use to toggle tree
function toggleTree() {
    $('#side-bar').toggle();
    CTRLS.TREE.collapsed = !CTRLS.TREE.collapsed;
    adjustReportPaneWidth();
    adjustToWindowEvent();
    resizeEditor();
    let vIcon = document.getElementById(CTRLS.TREE.id + 'Text');
    vIcon.style.color = (CTRLS.TREE.collapsed) ? 'lightgray' : '#007bff';
}
// Expand or reduce the width of report pane depending on tree or editor collapsed
function adjustReportPaneWidth() {
    // col width = 2, 5, 5
    let vNextWidth;
    // editor pane
    if (CTRLS.SOURCE.collapsed)
        vNextWidth = 'col-sm-12';
    else
        vNextWidth = 'col-sm-6';
    let reportPane = document.getElementById('report-pane');
    reportPane.className = reportPane.className.replace(reportPaneWidth, vNextWidth);
    reportPaneWidth = vNextWidth;
    // Side-bar
    if (CTRLS.TREE.collapsed)
        vNextWidth = 'col-sm-12';
    else
        vNextWidth = 'col-sm-10';
    reportPane = document.getElementById('viewer-group');
    reportPane.className = reportPane.className.replace(viewerGroupWidth, vNextWidth);
    viewerGroupWidth = vNextWidth;
}
// Forces header of area report to remain at the top of the area table during scrolling
// (the header is the row with the column titles - ALUTs, FFs, etc.)
function stickTableHeader() {
    if (view !== VIEWS.AREA_SYS && view !== VIEWS.AREA_SRC && view !== VIEWS.LOOP && view !== VIEWS.VERIF && view !== VIEWS.INCREMENTAL)
        return;
    var reportBody = $(currentPane + ' #report-area')[0];
    if (!reportBody)
        return;
    var areaTable = $(currentPane + ' #area-table-content')[0];
    if (!areaTable)
        return;
    var panel = reportBody.getBoundingClientRect();
    var table = areaTable.getBoundingClientRect();
    var rowWidth = 0.0;
    var tableWidth = table.width;
    var systemRow;
    var tableHeader = $(currentPane + ' #table-header').filter(function () {
        if ($(this).is(":visible"))
            return true;
        return false;
    });
    systemRow = $(currentPane + ' #first-row')
        .filter(function () {
        if ($(this).is(':visible'))
            return true;
        return false;
    });
    tableHeader.css('position', 'absolute')
        .css('top', (panel.top - table.top))
        .css('left', 0);
    tableHeader.find('th').each(function (i) {
        var itemWidth = (systemRow.find('td').eq(i))[0].getBoundingClientRect().width;
        if (i === 0) {
            // This column contains the expand/collapse all button. Check if need to resize button
            if (itemWidth < $('#collapseAll').outerWidth() || itemWidth < 116) {
                $('#collapseAll').outerWidth(itemWidth);
                $('#expandAll').outerWidth(itemWidth);
            }
            else {
                $('#collapseAll').outerWidth(116);
                $('#expandAll').outerWidth(116);
            }
        }
        rowWidth += itemWidth;
        $(this).css('min-width', itemWidth);
    });
    // Set the Spacer row height equal to current tableHeader height
    systemRow.css('height', tableHeader.outerHeight());
    // if we just hid the selected row, unselect it and clear details pane
    if (view.clickDown && view.clickDown.offsetParent === null) {
        unsetClick();
    }
}
function setReportPaneHeight() {
    var viewPortHeight = $(window).height() - 1;
    var navBarHeight = $('#header-bar').height();
    var detailHeight = (CTRLS.DETAILS.collapsed) ? 17 : $('#detail-pane').height() + 27;
    // update the report and editor height
    $('#report-pane, #editor-pane').css('height', parseInt(viewPortHeight - navBarHeight - detailHeight));
    // Set the size of the outline-list to be equal to the details pane
    if (!CTRLS.DETAILS.collapsed) {
        $('#outline-list').css('height', parseInt($("#detail-pane").innerHeight()));
    }
    var outlineHeight = $('#outline-list').height();
    // Compensate by the same 27 pixels as when setting for the report pane
    $('#tree-list').css('height', parseInt(viewPortHeight - navBarHeight - outlineHeight - 27));
    let panelHeight = $('#report-pane').height();
    var editorHeadingHeight = $('#editor-nav-btn-group').outerHeight();
    // Use class here since all editor w/ file will have this class
    $('.tab-pane').css('height', panelHeight - editorHeadingHeight);
}
/**
 * @function addViewerPanel create report pane for viewer data to populate later.
 *
 * @param {Object} view an element in VIEWS object.
 * @param {String} layerId id to be created for the graph.
 * @param {String} panelId id of the report body defined in VIEWER_CONST.
 * @returns {HTML div element} to be append to the report body div.
 */
function addViewerPanel(view, layerId, panelId) {
    let headerName = view.name;
    let paneHeading = document.createElement('div');
    paneHeading.className = 'card-header';
    paneHeading.innerHTML = headerName;
    let entitySpan = document.createElement('span');
    entitySpan.className = 'currentEntity';
    paneHeading.appendChild(entitySpan);
    let buttonSpan = document.createElement('span');
    buttonSpan.setAttribute('style', 'float:right');
    let buttonDiv = document.createElement('div');
    buttonDiv.id = layerId;
    buttonSpan.appendChild(buttonDiv);
    paneHeading.appendChild(buttonSpan);
    let reportBody = document.createElement('div');
    reportBody.id = 'report-panel-body';
    reportBody.className = 'card';
    reportBody.appendChild(paneHeading);
    let viewBody = document.createElement('div');
    viewBody.id = panelId;
    viewBody.className = 'card-body'; //  fade in active";
    reportBody.appendChild(viewBody);
    let idName = view.id;
    let reportBodyContainer = document.createElement('div');
    reportBodyContainer.id = idName;
    reportBodyContainer.className = 'classWithPad';
    reportBodyContainer.appendChild(reportBody);
    return reportBodyContainer;
}
/**
 * @function setViewerPanelHeight changes the report body panel height during resizing.
 *
 * @param {*} reportBodyDiv
 * @param {*} reportPaneHeight
 */
function setViewerPanelHeight(reportBodyDiv, reportPaneHeight) {
    let viewerValues = getViewerConst();
    if (viewerValues !== undefined) {
        // Only make adjustment if view is from system viewer and memory viewer
        let HeaderList = reportBodyDiv.find('.card-header');
        if (HeaderList.length === 0) {
            console.warn('Warning! Viewer report body has no header.');
        }
        let viewerHeaderHeight = HeaderList.eq(0).height();
        let newHeightValue = reportPaneHeight - viewerHeaderHeight - 48;
        let elemId = viewerValues.elemId;
        $(GID).css('height', newHeightValue);
        $('#' + elemId).css('height', newHeightValue);
        $('#' + elemId).css('width', $('#report-pane').innerWidth());
    }
}
/**
 *
 * @param {Object} details returns by getDetails()
 * @param {String} title shown in details card title
 */
function changeDetailsPane(details, title) {
    if (!details)
        return;
    let formattedDetails = getHTMLDetailsFromJSON(details, title);
    if (!formattedDetails)
        return;
    document.getElementById('details').innerHTML = formattedDetails;
}
function changeDivContent(idx, details) {
    if (view == VIEWS.LMEM || view == VIEWS.GV || view == VIEWS.SUMMARY || view == VIEWS.LOOP || view == VIEWS.SCHEDULE) {
        if (!details)
            return;
        document.getElementById('details').innerHTML = details;
    }
    else { // TO BE OBSELETED
        document.getElementById('details').innerHTML = detailValues[idx];
    }
}
function clearDivContent() {
    document.getElementById('details').innerHTML = '';
}
function syncEditorPaneToLine(line, filename) {
    if (portable_mode) {
        gotoFileACEEditorLine(filename, line); // ACE Editor
    }
    else {
        // IDE use
        if (typeof goToFile !== 'undefined') {
            goToFile(filename, line); //For ecplise
        }
        else if (typeof window !== 'undefined' && window.external !== 'undefined') {
            window.external.goToFile(filename, line); // For Visual studio
        }
        else {
            alert('Not found goToFile function');
        }
    }
}
function editorNoHighlightActiveLine(event) {
    if (portable_mode) {
        // Get current editor, and disable line highlighting and cursor.
        removeACEEditorHighlight();
    }
}
function syncEditorPaneToLineNoPropagagte(event, line, filename) {
    event.stopPropagation();
    syncEditorPaneToLine(line, filename);
}
function getFilename(path) {
    if (!isValidFileList)
        return path;
    var name = path;
    for (var i = 0; i < fileJSON.length; i++) {
        if (path.indexOf(fileJSON[i].path) != -1) {
            return fileJSON[i].path;
        }
        else if (path.indexOf(fileJSON[i].name) != -1) {
            name = fileJSON[i].name;
            break;
        }
    }
    return name;
}
