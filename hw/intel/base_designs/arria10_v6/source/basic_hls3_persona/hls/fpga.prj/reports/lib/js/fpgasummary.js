"use strict";
// Helper function
// Get user applied clock flag at compile time
function getCompileClockParameter() {
    if (infoJSON['compileInfo']['nodes'][0].hasOwnProperty('command')) {
        let myClockExp = /--clock\s+(\S+)/;
        let match = myClockExp.exec(infoJSON['compileInfo']['nodes'][0]['command']);
        if (match)
            return match[1];
    }
    return null;
}
// returns null if no blocks are schedule less than target
function getMininumScheduleClockFreq() {
    let minClockFreq = null;
    let minBlockName = '';
    let targetClockFreq = null;
    for (let fi = 0; fi < loop_attrJSON['nodes'].length; fi++) {
        let funcObj = loop_attrJSON['nodes'][fi];
        targetClockFreq = funcObj['fmax'];
        if (!funcObj.hasOwnProperty('children'))
            continue;
        for (let ci = 0; ci < funcObj['children'].length; ci++) {
            let blockObj = funcObj['children'][ci];
            if (blockObj['af'] < targetClockFreq) {
                minClockFreq = blockObj['af'];
                minBlockName = blockObj['name'];
            }
        }
        // just return the first one
        // found a block schedule fmax did not meet target fmax
        if (minClockFreq !== null)
            return { 'block': minBlockName, 'fmax': minClockFreq };
    }
    return null;
}
function getAttributeDefaultClockFreq() {
    // find the first fmax with clock parameter set to "no"
    // if (!loop_attrJSON.hasOwnProperty('nodes')) return null;  // error handling
    for (let fi = 0; fi < loop_attrJSON['nodes'].length; fi++) {
        let funcObj = loop_attrJSON['nodes'][fi];
        if (funcObj['clk'] == 'No') {
            return funcObj['fmax'];
        }
    }
    return null; // Can't default fmax
}
// Returns the value of fmax if user applied. Returns null when user did not specified.
// Returns -1 if the values are multiple values.
function getAttributeClockParameter() {
    let userApplied = false; // start with no
    let attributeClockValue = null;
    // if (!loop_attrJSON.hasOwnProperty('nodes')) return null;  // error handling
    for (let fi = 0; fi < loop_attrJSON['nodes'].length; fi++) {
        let funcObj = loop_attrJSON['nodes'][fi];
        if (attributeClockValue === null) {
            // set it for the first time
            attributeClockValue = funcObj['fmax'];
        }
        else if (attributeClockValue !== funcObj['fmax']) {
            return -1;
        }
        if (funcObj['clk'] == 'Yes') {
            userApplied = true;
        }
    }
    if (userApplied)
        return attributeClockValue; // user applied and all the same value
    return null;
}
function getTargetFrequencyValue() {
    let compileClockValue = getCompileClockParameter();
    // return "Various" check loop attritubes to see if per component is used
    let attributeClockValue = getAttributeClockParameter();
    if (attributeClockValue === null)
        return getAttributeDefaultClockFreq(); // nothing specified
    if (attributeClockValue === -1)
        return 'Various'; // too many different attributes in the source
    if (compileClockValue === null)
        return attributeClockValue; // single attribute, no compiler flag
    if (compileClockValue !== attributeClockValue)
        return 'Various'; // compile flag !== attribute
    return attributeClockValue; // Only by compiler flag
}
function getTargetFrequencyDetails() {
    let htmlText = '\"Target frequency';
    let compileClockValue = getCompileClockParameter();
    let attributeClockValue = getAttributeClockParameter();
    if (compileClockValue === null && attributeClockValue === null) {
        htmlText += ' not specified. Use default.\"';
    }
    else if (attributeClockValue === null) {
        htmlText += ' of ';
        htmlText += compileClockValue;
        htmlText += ' MHz from user applied.\"';
    }
    else if (attributeClockValue === -1) {
        htmlText += ' varies at the at function level.\"';
    }
    else if (compileClockValue === null) {
        htmlText += ' of ';
        htmlText += attributeClockValue;
        htmlText += ' MHz from user applied.\"';
    }
    else if (compileClockValue !== attributeClockValue) {
        htmlText += ' varies between compile flag and function level.\"';
    }
    else {
        htmlText += ' of ';
        htmlText += attributeClockValue;
        htmlText += ' MHz from user applied.\"';
    }
    return htmlText;
}
function getFunctionFmaxValue(pFuncName) {
    let funcFmax = null;
    Object.keys(loop_attrJSON['nodes']).filter(function (funcObj) {
        return (funcObj['name'] === pFuncName && funcObj['clk'] == 'Yes');
    }).forEach(function (funcObj) {
        funcFmax = funcObj['fmax'];
        return;
    });
    return funcFmax;
}
// Summary for compile info project name, target family, time stamp and etc.
var FPGACompileInfo = function (pDiv, pProduct) {
    this.vDiv = pDiv;
    this.vProduct = pProduct;
    this.vID = 'compileInfo'; // headingOne
    this.vBodyRef = this.vID + 'Body'; // href=#collapseOne
    this.vName = 'Compile Info';
    this.vTable = null;
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    this.draw = function (pShow) {
        this.vTable = new FPGADataTable(this.vID + 'Table');
        this.vTable.setShowName(1);
        this.vTable.setShowLoc(0);
        this.vTable.setShowCaption(0);
        this.vTable.setShowHeader(0);
        this.vTable.setTranpose(1);
        this.vTable.setNameWidth('40%');
        this.vTable.setDataWidth('60%');
        this.vTable.setClass('table info-table fpgasummary-table'); // No hover highlight
        // AOC or HLS
        if (this.vProduct === PRODUCTS.HLS) {
            this.vTable.setColumnList('Project Name', 'Target Family, Device', 'i++ Version', 'Quartus Version', 'Command', 'Reports Generated At');
            this.vTable.setAttributeMap({ 'Project Name': 'name', 'Target Family, Device': 'family', 'i++ Version': 'version',
                'Quartus Version': 'quartus', 'Command': 'command', 'Reports Generated At': 'time' });
        }
        else if (this.vProduct === PRODUCTS.AOC) { // OpenCL include board as part of Target family
            this.vTable.setColumnList('Project Name', 'Target Family, Device, Board', 'AOC Version', 'Quartus Version', 'Command', 'Reports Generated At');
            this.vTable.setAttributeMap({ 'Project Name': 'name', 'Target Family, Device, Board': 'family', 'AOC Version': 'version',
                'Quartus Version': 'quartus', 'Command': 'command', 'Reports Generated At': 'time' });
        }
        else { // SYCL compile does not include command
            this.vTable.setColumnList('Project Name', 'Target Family, Device, Board', 'SYCL Version', 'Quartus Version', 'Reports Generated At');
            this.vTable.setAttributeMap({ 'Project Name': 'name', 'Target Family, Device, Board': 'family', 'SYCL Version': 'version',
                'Quartus Version': 'quartus', 'Reports Generated At': 'time' });
        }
        // Add data and create the card
        this.vTable.addRow(new FPGADataRow(1, '', null, infoJSON[this.vID]['nodes'][0], '', 0, 0, '', ''));
        createAccordionCard(this.vDiv, this.vID, this.vName, 'fpgasummary-card', this.vTable.draw(), pShow);
    };
};
// Creates a table for function user-defined function name map and hyper-optimized handshaking if applicable
var FPGAFunctionSummary = function (pDiv) {
    this.vDiv = pDiv;
    this.vID = 'functionNameMapping'; // headingOne 
    this.vBodyRef = this.vID + 'Body'; // href=#collapseOne
    this.vPerfID = 'performanceSummary';
    this.vName = 'Functions';
    this.vTable = null;
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    this.draw = function (pShow) {
        var _this = this;
        // Completely disable like warning when it's empty or does not exist
        var hasMapSummary = (!$.isEmptyObject(summaryJSON) && summaryJSON.hasOwnProperty(this.vID) && summaryJSON[this.vID].hasOwnProperty('children') &&
            Array.isArray(summaryJSON[this.vID]['children'])) ? true : false;
        var hasPerformanceSummary = (!$.isEmptyObject(summaryJSON) && summaryJSON.hasOwnProperty(this.vPerfID) && summaryJSON[this.vPerfID].hasOwnProperty('children') &&
            Array.isArray(summaryJSON[this.vPerfID]['children'])) ? true : false;
        if (hasMapSummary || hasPerformanceSummary) { // Have at least one thing
            this.vTable = new FPGADataTable(this.vID + 'Table');
            this.vTable.setShowLoc(1);
            this.vTable.setClass('table table-hover table-bordered fpgasummary-table'); // No strip
            let mapSummary = null;
            let perfSummary = null;
            if (hasMapSummary)
                mapSummary = summaryJSON[this.vID];
            if (hasPerformanceSummary)
                perfSummary = summaryJSON[this.vPerfID];
            if (mapSummary && perfSummary) {
                this.vTable.setColumnList('User-Defined Function Name', 'Target Frequency (MHz)', 'Hyper-Optimized Handshaking');
                this.vTable.setAttributeMap({ 'User-Defined Function Name': 'functionName',
                    'Target Frequency (MHz)': 'targetFreq',
                    'Hyper-Optimized Handshaking': 'Hyper-Optimized Handshaking' });
            }
            else if (mapSummary) { // This can happen for non hyperflex architecture
                this.vTable.setColumnList('User-Defined Function Name', 'Target Frequency (MHz)');
                this.vTable.setAttributeMap({ 'User-Defined Function Name': 'functionName',
                    'Target Frequency (MHz)': 'targetFreq' });
            }
            else { // In case this exist, but I don't think this ever happens
                console.log("Warning! The data is incomplete.");
            }
            if (mapSummary) {
                mapSummary['children'].forEach(function (child) {
                    let columns = {};
                    columns['functionName'] = child['name'];
                    let shortName = child['data'][0];
                    if (perfSummary !== null) {
                        perfSummary['children'].forEach(function (row) {
                            // Add performanc data if exist
                            if (shortName === row['name']) {
                                for (let c = 1; c < perfSummary['columns'].length; c++) {
                                    columns[perfSummary['columns'][c]] = row['data'][c - 1];
                                }
                            }
                        });
                    }
                    let attributeClockValue = "Not specified";
                    if (loop_attrJSON.hasOwnProperty('nodes')) {
                        for (let fi = 0; fi < loop_attrJSON['nodes'].length; fi++) {
                            let funcObj = loop_attrJSON['nodes'][fi];
                            if (shortName === funcObj['name'] && funcObj['clk'] === 'Yes') {
                                attributeClockValue = funcObj['fmax'];
                            }
                        }
                    }
                    columns['targetFreq'] = attributeClockValue;
                    let debugLoc = (child.hasOwnProperty('debug') && child['debug'][0][0]['line']) ? child['debug'] : null;
                    // add details
                    let noteCall = 'clearDivContent()';
                    if ((child.hasOwnProperty('details'))) {
                        let noteHTML = child['details'][0]['text'];
                        noteCall = 'changeDivContent(0,\"' + noteHTML + '\")';
                    }
                    // TODO: get the ID from compiler, I don't want to parse another JSON which could result in more dependency
                    _this.vTable.addRow(new FPGADataRow(1011, child['name'], debugLoc, columns, '', 0, 0, '', noteCall));
                });
                createAccordionCard(this.vDiv, this.vID, this.vName, 'fpgasummary-card', this.vTable.draw(), pShow);
            }
            // create empty card
        }
    };
};
// Creates a table for OpenCL kernel performance: Kernel Type, Autorun, Workgroup Size, # Compute Units
var FPGAKernelSummary = function (pDiv) {
    this.vDiv = pDiv;
    this.vID = 'performanceSummary'; // headingOne
    this.vBodyRef = this.vID + 'Body'; // href=#collapseOne
    this.vName = 'Kernels Summary';
    this.vTable = null;
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    this.draw = function (pShow) {
        // Handle empty kernel cl file
        if (summaryJSON.hasOwnProperty(this.vID) && summaryJSON[this.vID].hasOwnProperty('children') &&
            Array.isArray(summaryJSON[this.vID]['children']) && summaryJSON[this.vID]['children'].length) {
            var _this = this;
            let tmpSummary = summaryJSON[this.vID];
            this.vTable = new FPGADataTable(this.vID + 'Table');
            this.vTable.setShowName(1);
            this.vTable.setShowLoc(1);
            this.vTable.setShowCaption(0);
            this.vTable.setTranpose(0);
            this.vTable.setClass('table table-hover table-bordered fpgasummary-table'); // No strip
            let vTmpColumns = ['Kernel Type', 'Autorun', 'Workgroup Size', '# Compute Units', 'Target Frequency (MHz)'];
            let vTmpAttrMap = { 'Kernel Type': 'Kernel Type',
                'Autorun': 'Autorun',
                'Workgroup Size': 'Workgroup Size',
                '# Compute Units': '# Compute Units',
                'Target Frequency (MHz)': 'targetFreq' };
            if (tmpSummary['columns'].indexOf('Hyper-Optimized Handshaking') !== -1) {
                vTmpColumns.push('Hyper-Optimized Handshaking');
                vTmpAttrMap['Hyper-Optimized Handshaking'] = 'Hyper-Optimized Handshaking';
            }
            this.vTable.setColumnList.apply(this.vTable, vTmpColumns);
            this.vTable.setAttributeMap(vTmpAttrMap);
            tmpSummary['children'].forEach(function (row) {
                let columns = {};
                for (let c = 1; c < tmpSummary['columns'].length; c++) {
                    columns[tmpSummary['columns'][c]] = row['data'][c - 1];
                }
                // Get target fmax for function
                let attributeClockValue = getFunctionFmaxValue(row['name']);
                columns['targetFreq'] = (attributeClockValue === null) ? "Not specified" : attributeClockValue;
                // TODO: add details
                let noteCall = '';
                if ((row.hasOwnProperty('details'))) {
                    noteCall = 'changeDivContent(0,\"';
                    let len = row['details'].length;
                    for (let i = 0; i < len; i++) {
                        noteCall = noteCall + row['details'][i]['text'] + '<br>';
                    }
                    noteCall = noteCall + '\")';
                }
                // TODO: get the ID from compiler, I don't want to parse another JSON which could result in more dependency
                _this.vTable.addRow(new FPGADataRow(1011, row['name'], row['debug'], columns, '', 0, 0, '', noteCall, ''));
            });
            createAccordionCard(this.vDiv, this.vID, this.vName, 'fpgasummary-card', this.vTable.draw(), pShow);
            return;
        }
        createEmptyCard(this.vDiv, this.vID, this.vName + ': No Kernel', 'fpgasummary-card');
    };
};
// Summary for Quartus clock frequency, targeted Fmax, and minimum compiler scheduled fmax.
var FPGAClockFreqSummary = function (pDiv, pProduct) {
    this.vDiv = pDiv;
    this.vProduct = pProduct; // display name depends on HLS, OpenCL or SYCL
    this.vID = 'quartusFitClockSummary'; // headingOne
    this.vBodyRef = this.vID + 'Body'; // href=#collapseOne
    this.vInfoID = 'compileInfo';
    this.vName = 'Clock Frequency Summary';
    this.vTable = null;
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    this.draw = function (pShow) {
        var _this = this;
        // Rendering option
        this.vTable = new FPGADataTable(this.vID + 'Table');
        this.vTable.setTranpose(1);
        this.vTable.setEventRow(0); // disable row click
        this.vTable.setNameWidth('20%');
        this.vTable.setClass('table table-bordered fpgasummary-table fpgatable-hover-cells'); // No strip and per cell hover since it's transposed
        let clockAttrName = 'clock';
        // Error checking for empty Quartus, i.e. aocr to aocx flow
        if (!$.isEmptyObject(quartusJSON) && quartusJSON.hasOwnProperty(this.vID) && quartusJSON[this.vID].hasOwnProperty('nodes') &&
            Array.isArray(quartusJSON[this.vID]['nodes']) && quartusJSON[this.vID]['nodes'].length !== 0) {
            // Special customization for less confusing GUI
            let quartusClkData = quartusJSON[this.vID];
            // Set Display column and attribute mapping
            if (this.vProduct === PRODUCTS.HLS) {
                clockAttrName = 'clock';
                let clock2xAttrName = '2x clock';
                let vShow2xClock = (quartusClkData['nodes'][0].hasOwnProperty(clock2xAttrName)) ? true : false;
                if (vShow2xClock) {
                    this.vTable.setColumnList('Clock 1x', 'Clock 2x');
                    this.vTable.setAttributeMap({ 'Clock 1x': clockAttrName,
                        'Clock 2x': clock2xAttrName });
                }
                else {
                    this.vTable.setColumnList('Clock 1x');
                    this.vTable.setAttributeMap({ 'Clock 1x': clockAttrName });
                }
            }
            else { // OpenCL or SYCL
                clockAttrName = 'kernel clock';
                let clock2xAttrName = 'clock2x';
                let vShow2xClock = (quartusClkData['nodes'][0].hasOwnProperty(clock2xAttrName)) ? true : false;
                if (vShow2xClock) {
                    this.vTable.setColumnList('Kernel clock', 'Clock 2x');
                    this.vTable.setAttributeMap({ 'Kernel clock': clockAttrName,
                        'Clock 2x': clock2xAttrName
                    });
                }
                else {
                    this.vTable.setColumnList('Kernel clock');
                    this.vTable.setAttributeMap({ 'Kernel clock': clockAttrName });
                }
            }
            this.vTable.setEventColumns([clockAttrName]); // Map tooltip to clock value
            // Add data
            quartusClkData['nodes'].forEach(function (node) {
                let isValueTBD = false;
                let columns = {};
                for (var attr in node) {
                    if (attr === 'name' || attr === 'type' || attr === 'id')
                        continue;
                    columns[attr] = node[attr];
                    if (node[attr] === 'TBD')
                        isValueTBD = true;
                }
                // Using an obsoleted function because details format is still old. See fpgadatatable::_newCell for further
                // explanation on the workaround
                let noteCall = 'clearDivContent()';
                if (node.hasOwnProperty('details')) {
                    let noteHTML = node['details'][0]['text']; // Backward compitable to support Text
                    noteCall = 'changeDivContent(0,\"' + noteHTML + '\")';
                }
                let tooltip = '';
                if (isValueTBD) {
                    let word = (_this.vProduct === PRODUCTS.SYCL) ? 'QUARTUS_SYCL' : 'QUARTUS';
                    tooltip = lookUpTerminology(word);
                }
                // no parent, no group
                _this.vTable.addRow(new FPGADataRow(node['id'], node['name'], null, columns, '', 0, 0, '', noteCall, tooltip));
            });
        }
        else { // Error handling the case Quartus data is empty, still need to add the column and n/a
            if (this.vProduct === PRODUCTS.HLS) {
                clockAttrName = 'clock';
                this.vTable.setColumnList('Clock 1x');
                this.vTable.setAttributeMap({ 'Clock 1x': clockAttrName });
            }
            else {
                clockAttrName = 'kernel clock';
                this.vTable.setColumnList('Kernel clock');
                this.vTable.setAttributeMap({ 'Kernel clock': clockAttrName });
            }
            let columns = {};
            columns[clockAttrName] = 'n/a';
            let tooltip = '';
            let noteCall = 'clearDivContent()';
            _this.vTable.addRow(new FPGADataRow(1000, 'Quartus Fitter: Clock Frequency (MHz)', null, columns, '', 0, 0, '', noteCall, tooltip));
        }
        // TODO: output target Fmax from compiler summary as part of performanceSummary
        if (loop_attrJSON.hasOwnProperty('nodes')) {
            // Note: we are not parsing from command line for -clock because this won't work aocr to aocx flow
            let targetClock = getTargetFrequencyValue();
            let tooltip = '';
            let noteCall = 'changeDivContent(0,' + getTargetFrequencyDetails() + ')';
            let columns = {};
            columns[clockAttrName] = targetClock;
            _this.vTable.addRow(new FPGADataRow(2, 'Compile Target Frequency (MHz)', null, columns, '', 0, 0, '', noteCall, tooltip));
            // TODO: output target Fmax from compiler summary as part of performanceSummary
            // workaround: parse loop attribute find minimum achieved_fmax for each block
            let firstLowerFmaxScheduleBlock = getMininumScheduleClockFreq();
            let minClock = targetClock;
            let highlight = '';
            if (firstLowerFmaxScheduleBlock !== null) {
                minClock = firstLowerFmaxScheduleBlock['fmax'];
                let minBlockName = firstLowerFmaxScheduleBlock['block'];
                noteCall = 'changeDivContent(0,"See ' + minBlockName + ' in Loop Analysis for details.")';
                tooltip = 'fMAX reduced in block: ' + minBlockName + '. Click to see details.';
                highlight = 'fpgaredword';
            }
            columns = {};
            columns[clockAttrName] = minClock;
            _this.vTable.addRow(new FPGADataRow(3, 'Compile Estimated Frequency (MHz)', null, columns, highlight, 0, 0, '', noteCall, tooltip));
        }
        else {
            // Summary is empty because aocr to aocx in a different computer
            let columns = {};
            columns[clockAttrName] = 'n/a';
            let tooltip = '';
            let noteCall = 'clearDivContent()';
            _this.vTable.addRow(new FPGADataRow(2, 'Compile Target Frequency (MHz)', null, columns, '', 0, 0, '', noteCall, tooltip));
            _this.vTable.addRow(new FPGADataRow(3, 'Compile Estimated Frequency (MHz)', null, columns, '', 0, 0, '', noteCall, tooltip));
        }
        createAccordionCard(this.vDiv, this.vID, this.vName, 'fpgasummary-card', this.vTable.draw(), pShow);
    };
};
// Summary for resource for Quartus Fitter and device resource count
var FPGAQuartusResourceSummary = function (pDiv, pProduct) {
    this.vDiv = pDiv;
    this.vProduct = pProduct;
    this.vID = 'quartusFitResourceUsageSummary'; // headingOne
    this.vBodyRef = this.vID + 'Body'; // href=#collapseOne
    this.vEstimateID = 'estimatedResources';
    if (this.vProduct === PRODUCTS.HLS)
        this.vName = 'Quartus Estimated Resource Utilization Summary'; // Quartus is only estimate for HLS because there's no system
    else
        this.vName = 'Quartus Fitter Resource Utilization Summary';
    this.vTable = null;
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    // rows:
    //   Full design (all C's) | Compiler estimated resources |
    // cols:
    //   ALM, -ALUT, -REG, -MLAB, RAM, DSP
    this.draw = function (pShow) {
        var _this = this;
        this.vTable = new FPGADataTable(this.vID + 'Table');
        this.vTable.setShowName(1);
        this.vTable.setShowLoc(1);
        this.vTable.setShowCaption(0);
        this.vTable.setTranpose(0);
        this.vTable.setClass('table table-hover table-bordered fpgasummary-table'); // No strip
        this.vTable.setColumnList('ALM', 'ALUT', 'REG', 'MLAB', 'RAM', 'DSP');
        this.vTable.setAttributeMap({ 'ALM': 'alm', 'ALUT': 'alut', 'REG': 'reg', 'MLAB': 'mlab', 'RAM': 'ram', 'DSP': 'dsp' });
        // Quartus
        if ($.isEmptyObject(quartusJSON) || !quartusJSON.hasOwnProperty(this.vID) || !quartusJSON[this.vID].hasOwnProperty('nodes') ||
            !Array.isArray(quartusJSON[this.vID]['nodes']) || quartusJSON[this.vID]['nodes'].length === 0) {
            let columns = { 'alm': 'n/a', 'reg': 'n/a', 'ram': 'n/a', 'dsp': 'n/a' };
            this.vTable.addRow(new FPGADataRow(1000, 'Quartus Fitter resource utilization', null, columns, '', 0, 0, '', '', ''));
        }
        else {
            let quartusResUseData = quartusJSON[this.vID];
            // sort the name based by alphabetical order and leave system (aka id=1000) last
            let systemResUseRow = null;
            quartusResUseData['nodes'].sort(function (a, b) {
                if (a['name'] == b['name']) {
                    return 0;
                }
                else {
                    return a['name'] < b['name'] ? -1 : 1;
                }
            }).forEach(function (node) {
                if (node['id'] === '1001')
                    return; // don't add entire opencl system
                let isValueTBD = false;
                let columns = {};
                for (var attr in node) {
                    if (attr === 'name' || attr === 'type' || attr === 'id')
                        continue;
                    columns[attr] = node[attr];
                    if (node[attr] === 'TBD')
                        isValueTBD = true;
                }
                let tooltip = '';
                if (isValueTBD) {
                    tooltip = lookUpTerminology('QUARTUS');
                }
                let noteCall = 'clearDivContent()';
                if ((node.hasOwnProperty('details'))) {
                    let noteHTML = node['details'][0]['text'];
                    noteCall = 'changeDivContent(0,\"' + noteHTML + '\")';
                }
                if (node['id'] === '1000')
                    systemResUseRow = new FPGADataRow(node['id'], node['name'], null, columns, 'fpgagrayrow', 0, 0, '', noteCall, tooltip);
                else
                    _this.vTable.addRow(new FPGADataRow(node['id'], node['name'], null, columns, '', 0, 0, '', noteCall, tooltip));
            });
            _this.vTable.addRow(systemResUseRow);
            // Device total from summary
            if ($.isEmptyObject(summaryJSON) || !summaryJSON.hasOwnProperty(this.vEstimateID) || !summaryJSON[this.vEstimateID].hasOwnProperty('children') ||
                !Array.isArray(summaryJSON[this.vEstimateID]['children']) || summaryJSON[this.vEstimateID]['children'].length === 0) {
                console.log("Warning: Erraneous estimated resource summary data.");
                let columns = { 'alm': 'n/a', 'reg': 'n/a', 'ram': 'n/a', 'dsp': 'n/a' };
                this.vTable.addRow(new FPGADataRow(4, 'Device', null, columns, 'fpgasilverrow', 0, 0, '', '', ''));
            }
            else {
                let sumResUseData = summaryJSON[this.vEstimateID];
                sumResUseData['children'].filter(function (row) {
                    return (row['name'] === 'Available');
                }).forEach(function (row) {
                    let columns = {
                        'alm': parseInt(row['data'][0]) / 2,
                        'reg': row['data'][1],
                        'ram': row['data'][2],
                        'dsp': row['data'][3]
                    };
                    let tooltip = ''; // TODO: point to target device datasheet
                    _this.vTable.addRow(new FPGADataRow(4, 'Device', null, columns, 'fpgasilverrow', 0, 0, '', '', tooltip));
                });
            }
            createAccordionCard(this.vDiv, this.vID, this.vName, 'fpgasummary-card', this.vTable.draw(), pShow);
        }
    };
};
// Summary for resource for top level nodes: device resource count, static partition , Quartus Fitter 
// usage and estimated kernel system.
var FPGAOpenCLResourceSummary = function (pDiv, pProduct) {
    this.vDiv = pDiv;
    this.vProduct = pProduct;
    this.vID = 'systemResourceUsageSummary'; // headingOne
    this.vBodyRef = this.vID + 'Body'; // href=#collapseOne
    this.vQuartusID = 'quartusFitResourceUsageSummary';
    this.vEstimateID = 'estimatedResources';
    this.vName = 'System Resource Utilization Summary';
    this.vTable = null;
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    // rows:
    //   DM  | System | Static region | Full design (all K's) | Compiler estimated resources |
    // cols:
    //   ALM, -ALUT, -REG, -MLAB, RAM, DSP
    this.draw = function (pShow) {
        var _this = this;
        this.vTable = new FPGADataTable(this.vID + 'Table');
        this.vTable.setTranpose(1);
        this.vTable.setEventRow(0); // disable row click
        this.vTable.setNameWidth('15%');
        this.vTable.setDataWidth('12%');
        this.vTable.setClass('table table-bordered fpgasummary-table  fpgatable-hover-cells'); // No strip
        this.vTable.setColumnList('ALM', '&nbsp;- ALUT', '&nbsp;- REG', '&nbsp;- MLAB', 'RAM', 'DSP');
        this.vTable.setAttributeMap({ 'ALM': 'alm', '&nbsp;- ALUT': 'alut', '&nbsp;- REG': 'reg', '&nbsp;- MLAB': 'mlab', 'RAM': 'ram', 'DSP': 'dsp' });
        let deviceRow;
        let staticPartitionRow; // OpenCL only
        let systemRow;
        let aclSystemRow; // OpenCL only. This is the entire system which includes BSP
        let estSystemRow;
        // Error checking
        if ($.isEmptyObject(summaryJSON) || !summaryJSON.hasOwnProperty(this.vEstimateID) || !summaryJSON[this.vEstimateID].hasOwnProperty('children') ||
            !Array.isArray(summaryJSON[this.vEstimateID]['children']) || summaryJSON[this.vEstimateID]['children'].length === 0) {
            console.log("Warning: Erraneous estimated resource summary data.");
            let columns = { 'alm': 'n/a', 'reg': 'n/a', 'ram': 'n/a', 'dsp': 'n/a' };
            deviceRow = new FPGADataRow(4, 'Device', null, columns, 'fpgasilverrow', 0, 0, '', '', '');
            estSystemRow = new FPGADataRow(1000, 'Compile estimated: Full design (all components)', null, columns, '', 0, 0, '', '', '');
        }
        else {
            let sumResUseData = summaryJSON[this.vEstimateID];
            // OpenCL: Add Device, Static region (BSP), and estimated kernel system
            let estSysSubTotal = { 'alut': 0, 'reg': 0, 'mlab': 0, 'ram': 0, 'dsp': 0 };
            sumResUseData['children'].forEach(function (row) {
                if (row['name'] === 'Available') {
                    let columns = {
                        'alm': parseInt(row['data'][0]) / 2,
                        'reg': row['data'][1],
                        'ram': row['data'][2],
                        'dsp': row['data'][3]
                    };
                    let tooltip = ''; // TODO: point to target device datasheet
                    deviceRow = new FPGADataRow(4, 'Device', null, columns, 'fpgasilverrow', 0, 0, '', '', tooltip);
                }
                else if (row['name'] === 'Board Interface') {
                    let columns = {
                        'alm': parseInt(row['data'][0]) / 2,
                        'reg': row['data'][1],
                        'ram': row['data'][2],
                        'dsp': row['data'][3]
                    };
                    let tooltip = ''; // TODO: point to help to explain board interface
                    staticPartitionRow = new FPGADataRow(1002, 'Static partition', null, columns, 'fpgasilverrow', 0, 0, '', '', tooltip);
                }
                else if (row['name'] !== 'Kernel Subtotal' && row['name'] !== 'Total') {
                    // TODO: Fix this in the summary to output proper "Total" by summing Global Interconnect, System description ROM,
                    // and all kernels
                    estSysSubTotal['alut'] += row['data'][0];
                    estSysSubTotal['reg'] += row['data'][1];
                    estSysSubTotal['ram'] += row['data'][2];
                    estSysSubTotal['dsp'] += row['data'][3];
                    estSysSubTotal['mlab'] += row['data'][4];
                }
            });
            estSystemRow = new FPGADataRow(1000, 'Estimated: Kernel system', null, estSysSubTotal, '', 0, 0, '', '');
        }
        if ($.isEmptyObject(quartusJSON) || !quartusJSON.hasOwnProperty(this.vQuartusID) || !quartusJSON[this.vQuartusID].hasOwnProperty('nodes') ||
            !Array.isArray(quartusJSON[this.vQuartusID]['nodes']) || quartusJSON[this.vQuartusID]['nodes'].length === 0) {
            console.log("Warning: Erraneous Quartus Fitter resource summary data.");
            let columns = { 'alm': 'n/a', 'reg': 'n/a', 'ram': 'n/a', 'dsp': 'n/a' };
            let name = 'Quartus Fitter: Kernel System';
            systemRow = new FPGADataRow(1000, name, null, columns, '', 0, 0, '', '', '');
            name = 'Quartus Fitter: Total Used (Entire System)';
            aclSystemRow = new FPGADataRow(1001, name, null, columns, '', 0, 0, '', '', '');
        }
        else {
            // Special customization for less confusing GUI
            let quartusResUseData = quartusJSON[this.vQuartusID];
            // Add only top level data
            quartusResUseData['nodes'].filter(function (node) {
                return (node['type'].indexOf('system') !== -1);
            }).forEach(function (node) {
                let isValueTBD = false;
                let columns = {};
                for (var attr in node) {
                    if (attr === 'name' || attr === 'type' || attr === 'id')
                        continue;
                    columns[attr] = node[attr];
                    if (node[attr] === 'TBD')
                        isValueTBD = true;
                }
                let note = (node.hasOwnProperty('details')) ? node['details'] : null;
                let tooltip = '';
                if (isValueTBD) {
                    let word = (_this.vProduct === PRODUCTS.SYCL) ? 'QUARTUS_SYCL' : 'QUARTUS';
                    tooltip = lookUpTerminology(word);
                }
                if (node['type'] === 'system')
                    systemRow = new FPGADataRow(node['id'], node['name'], null, columns, '', 0, 0, '', note, tooltip);
                else
                    aclSystemRow = new FPGADataRow(node['id'], node['name'], null, columns, '', 0, 0, '', note, tooltip);
            });
        }
        // Add the rows in the order of: device resource count, static partition, QII entire system, QII full design, Estimated
        this.vTable.addRow(deviceRow);
        this.vTable.addRow(staticPartitionRow);
        this.vTable.addRow(aclSystemRow);
        this.vTable.addRow(systemRow);
        this.vTable.addRow(estSystemRow);
        createAccordionCard(this.vDiv, this.vID, this.vName, 'fpgasummary-card', this.vTable.draw(), pShow);
    };
};
// Summary of estimate resources per function. For OpenCL, we include System ROM and Global interconnect
// It also interleave Quartus results because Quartus resource summary only shows top level nodes.
var FPGAResourceEstSummary = function (pDiv, pProduct) {
    this.vDiv = pDiv;
    this.vProduct = pProduct;
    this.vID = 'estimatedResources'; // headingOne
    this.vBodyRef = this.vID + 'Body'; // href=#collapseOne
    this.vQuartusID = 'quartusFitResourceUsageSummary';
    if (this.vProduct === PRODUCTS.HLS)
        this.vName = 'HLS Estimated Resource Utilization Summary';
    else
        this.vName = 'Compile Estimated ' + function_prefix + ' Resource Utilization Summary';
    this.vTable = null;
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    // Kernel system estimated resources
    this.draw = function (pShow) {
        var _this = this;
        this.vTable = new FPGADataTable(this.vID + 'Table');
        this.vTable.setShowName(1);
        this.vTable.setShowLoc(1);
        this.vTable.setShowCaption(0);
        this.vTable.setTranpose(0);
        this.vTable.setClass('table table-hover table-bordered fpgasummary-table'); // No strip
        this.vTable.setColumnList('ALM', 'ALUT', 'REG', 'MLAB', 'RAM', 'DSP');
        this.vTable.setAttributeMap({ 'ALM': 'alm', 'ALUT': 'alut', 'REG': 'reg', 'MLAB': 'mlab', 'RAM': 'ram', 'DSP': 'dsp' });
        let estDataRows = [];
        let quartusDataRows = [];
        // Estimated Resource Usage - if empty, we will just display only Quartus data below
        if (!$.isEmptyObject(summaryJSON) && summaryJSON.hasOwnProperty(this.vID) && summaryJSON[this.vID].hasOwnProperty('children') &&
            Array.isArray(summaryJSON[this.vID]['children'])) {
            if (this.vProduct === PRODUCTS.HLS) { // Add estimates only
                let tmpSummary = summaryJSON[this.vID];
                tmpSummary['children'].filter(function (row) {
                    return (row['name'] !== "Available");
                }).forEach(function (row) {
                    let columns = {};
                    for (let c = 1; c < row['data'].length; c++) {
                        columns['alut'] = row['data'][0];
                        columns['reg'] = row['data'][1];
                        columns['ram'] = row['data'][2];
                        columns['dsp'] = row['data'][3];
                        columns['mlab'] = row['data'][4];
                    }
                    let debugLoc = (row.hasOwnProperty('debug') && row['debug'][0][0]['line']) ? row['debug'] : null;
                    if (row['name'] === 'Total') // TODO: fix name in compiler
                        estDataRows.push(new FPGADataRow(1000, 'Compile Estimated: Full Design (All Components)', debugLoc, columns, 'fpgagrayrow', 0, 0, '', '', ''));
                    else
                        estDataRows.push(new FPGADataRow(1011, row['name'], debugLoc, columns, '', 0, 0, '', '', ''));
                    // TODO: output correct ID from compiler. I don't want to parse treeJSON to add more dependency here
                });
            }
            else { // (OpenCL or SYCL) Add estimates and interleave Quartus results
                let tmpSummary = summaryJSON[this.vID];
                let subTotal = { 'alut': 0, 'reg': 0, 'ram': 0, 'dsp': 0, 'mlab': 0 };
                // TODO: From compiler, compute correct subtotal by sum(Kernels, Sys ROM, Global Interconnect)
                tmpSummary['children'].filter(function (row) {
                    return !(row['name'] === 'Kernel Subtotal' || row['name'] === 'Board Interface' || row['name'] === 'Total' || row['name'] === 'Available');
                }).forEach(function (row) {
                    let columns = {};
                    for (let c = 1; c < row['data'].length; c++) {
                        columns['alut'] = row['data'][0];
                        columns['reg'] = row['data'][1];
                        columns['ram'] = row['data'][2];
                        columns['dsp'] = row['data'][3];
                        columns['mlab'] = row['data'][4];
                    }
                    Object.keys(subTotal).forEach(function (c) {
                        subTotal[c] += columns[c];
                    });
                    let debugLoc = (row.hasOwnProperty('debug') && row['debug'][0][0]['line']) ? row['debug'] : null;
                    // TODO: get the ID from compiler, I don't want to parse another JSON which could result in more dependency
                    // Check for name if it's compute unit, i.e. <kernel_name> (<number>)
                    let compute_ids = row['name'].match(/(\S+)\s\(x(\d+)\)/);
                    if (compute_ids !== null && compute_ids.length == 3) {
                        let user_kernel_name = compute_ids[1];
                        let count = compute_ids[2];
                        Object.keys(columns).forEach(function (attr) {
                            columns[attr] /= count; // divide the total by count - assume same for each kernel for now
                        });
                        estDataRows.push(new FPGADataRow(1011, user_kernel_name, debugLoc, columns, '', 0, 0, '', '', ''));
                        for (let id = 1; id < count; id++) {
                            estDataRows.push(new FPGADataRow(1011, user_kernel_name + '_' + id, debugLoc, columns, '', 0, 0, '', '', ''));
                        }
                    }
                    else
                        estDataRows.push(new FPGADataRow(1011, row['name'], debugLoc, columns, '', 0, 0, '', '', ''));
                });
                // TODO: output proper name and ID from compiler
                estDataRows.push(new FPGADataRow(1000, 'Compile Estimated: Kernel System', null, subTotal, 'fpgagrayrow', 0, 0, '', '', ''));
            }
        }
        // Add the data
        if (estDataRows.length > 0) {
            // The estimated has the right order we want to show, use it when it's available
            estDataRows.forEach(function (estdrow) {
                estdrow.setName(estdrow.getName());
                _this.vTable.addRow(estdrow); // estimate
            });
        }
        createAccordionCard(this.vDiv, this.vID, this.vName, 'fpgasummary-card', this.vTable.draw(), pShow);
    };
};
// Creates a table to show compiler warnings
var FPGAWarningSummary = function (pDiv) {
    this.vDiv = pDiv;
    this.vID = 'warnings'; // headingOne
    this.vBodyRef = this.vID + 'Body'; // href=#collapseOne
    this.vCompileWarnID = 'compileWarnings';
    this.vName = 'Warnings Summary';
    this.vTable = null;
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    this.draw = function (pShow) {
        if ((summaryJSON.hasOwnProperty(this.vCompileWarnID) && summaryJSON[this.vCompileWarnID].hasOwnProperty('children') &&
            Array.isArray(summaryJSON[this.vCompileWarnID]['children']) && summaryJSON[this.vCompileWarnID]['children'].length) ||
            (warningsJSON.hasOwnProperty('nodes') && Array.isArray(warningsJSON['nodes']) && warningsJSON['nodes'].length)) {
            var _this = this;
            this.vTable = new FPGADataTable(this.vID + 'Table');
            this.vTable.setShowHeader(0);
            this.vTable.setClass('table table-hover table-bordered fpgasummary-table'); // No strip
            let warnCnt = 10;
            for (let wi = 0; wi < warningsJSON['nodes'].length; wi++) {
                let row = warningsJSON['nodes'][wi];
                let debugLoc = (row.hasOwnProperty('debug') && row['debug'][0][0]['line']) ? row['debug'] : null;
                let noteHTML = (row.hasOwnProperty('details')) ? row['details'][0]['text'] : '';
                let noteCall = 'changeDivContent(0,\"' + noteHTML + '\")';
                _this.vTable.addRow(new FPGADataRow(warnCnt, row['name'], debugLoc, null, '', 0, 0, '', noteCall));
                warnCnt++;
            }
            // Also include compileWarnings from compiler
            //   - may end up needing to distinguish between warnings based on origin (clang, opt, or llc)
            //     in which case this may stay as javascript, or an extra field will need to be added to the JSON
            //       Eg. , "origin": "clang"
            if (summaryJSON.hasOwnProperty(this.vCompileWarnID) && summaryJSON[this.vCompileWarnID].hasOwnProperty('children') &&
                Array.isArray(summaryJSON[this.vCompileWarnID]['children'])) {
                for (let wi = 0; wi < summaryJSON[this.vCompileWarnID]['children'].length; wi++) {
                    let row = summaryJSON[this.vCompileWarnID]['children'][wi];
                    let debugLoc = (row.hasOwnProperty('debug') && row['debug'][0][0]['line']) ? row['debug'] : null;
                    let noteHTML = (row.hasOwnProperty('details') && row['details'].length > 0 && row['details'][0].hasOwnProperty('text')) ? row['details'][0]['text'] : '';
                    let noteCall = 'changeDivContent(0,\"' + noteHTML + '\")';
                    _this.vTable.addRow(new FPGADataRow(warnCnt, row['name'], debugLoc, null, '', 0, 0, '', noteCall));
                    warnCnt++;
                }
            }
            createAccordionCard(this.vDiv, this.vID, this.vName, 'fpgasummary-card', this.vTable.draw(), pShow);
            return;
        }
        createEmptyCard(this.vDiv, this.vID, this.vName + ': No Warnings', 'fpgasummary-card');
    };
};
