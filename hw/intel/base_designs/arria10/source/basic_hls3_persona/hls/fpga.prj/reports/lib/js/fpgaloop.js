"use strict";
// Global variable:
// Commonly used by HLD report
var vLoopInfoTable; // state saving for loop info table to avoid reinitialization
// Utility functions
/**
 * @function jsonHasChildrenArray checks whether jsonObj has a key-value pair
 *   where key is 'children' and value is an array.
 * @param {object} jsonObj in a json data structure.
 * @returns {boolean} true if it has a key-value pair
 *   where key is 'children' and value is an array; false otherwise.
 */
function jsonHasChildrenArray(jsonObj) {
    return jsonObj.hasOwnProperty('children') &&
        Array.isArray(jsonObj['children']);
}
/**
 * @function searchJsonArrayByName search for entry in the array with the target name.
 * @param {object} jsonArray is a json array.
 *   Its structure must be: [ {'name':<string>, 'children':[array], ...},
 *                            {'name':<string>, ...}]
 * @param {string} name is the name to search for.
 * @returns {object} one entry in jsonArray if its name matches. Otherwise null if none of the entries match.
 */
function searchJsonArrayByName(jsonArray, name) {
    var res = null;
    for (let i = 0; i < jsonArray.length; i++) {
        if (jsonArray[i]['name'] === name) {
            res = jsonArray[i];
            break;
        }
        ;
        if (jsonHasChildrenArray(jsonArray[i]))
            res = searchJsonArrayByName(jsonArray[i]['children'], name);
        if (res)
            break; // Return immediately if res is valid. Important for recursion.
    }
    return res;
}
/**
 * @function isFunction return true is the name indicates a function, return false otherwise.
 * @param {string} name is the name in question.
 */
function isFunction(name) {
    if (name.match(/\w+:\s+\w+/g))
        return true;
    else
        return false;
}
/**
 * @function isBasicBlock return true is the name indicates a basic block, return false otherwise.
 * @param {string} name is the name in question.
 */
function isBasicBlock(name) {
    if (name.match(/(Fused loop |Partially unrolled )?[\w<>]+\.B\d+.*/g))
        return true;
    else
        return false;
}
/**
 * @function getRealName returns the name of functions/blocks/loops without the prefix "kernel: "/"function: " etc.
 * @param {string} name is the name in question.
 * @returns {string} is the name without any prefix "kernel: "/"function: "/"Fused loop" ...
 */
function getRealName(name) {
    let res = name;
    if (isFunction(name)) {
        // "kernel: bb1"/"function: bb1"
        res = name.substring(name.indexOf(': ') + 2);
    }
    else if (name.match(/^Fused loop \w+\.B\d+.*/g)) {
        // Change:6087384 adds "Fused loop " in front of basic block names
        // Remove "Fused loop"
        res = name.substring(name.indexOf('Fused loop ') + 11);
    }
    else if (name.match(/Partially unrolled \w+\.B\d+.*/g)) {
        res = name.substring(name.indexOf('Partially unrolled ') + 19);
    }
    return res;
}
/**
 * @function FPGALoop create a table containing loop information
 * @param {object} pDiv is the parent element that contains the table
 */
var FPGALoop = function (pDiv) {
    var vDiv = pDiv;
    var vID = 'loopAnalysis';
    var vBodyRef = vID + 'Body';
    var vName = "Loop Analysis";
    var vTable = null;
    var vShowBlock = false; // keeps the state of show block checkbox
    var vTreeData = null;
    // clear the content in the details
    clearDivContent();
    // Creates a card for the first time
    let vTmpCard = document.getElementById(vBodyRef);
    if (!vTmpCard) {
        // Print a message for the first time to let user to know to click the tree
        let fpgaloopTextMsg = newFPGAElement(null, 'P', 'fpgaloop-info-text', undefined, 'Click an option in the Loop List pane to see the loop pipeline information.');
        createCard(vDiv, vID, vName, 'fpgaloop-card', fpgaloopTextMsg);
        addCheckBox();
    }
    this.getTreeData = function () { return vTreeData; };
    function addCheckBox() {
        // add checkbox to fpgaloop-card-header for "Show all blocks"
        // the condition to allow checkbox is if loop has children and are blocks or latch
        let vCardHeader = document.getElementById(vID); // this is the header
        // <span style='font-size:1rem;float:right'>
        let vTmpCheckBoxGroup = newFPGAElement(vCardHeader, 'span', '', vID + 'BlockCheckBox');
        vTmpCheckBoxGroup.style.fontSize = 'smaller';
        vTmpCheckBoxGroup.style.cssFloat = 'right';
        let vTmpInput = newFPGAElement(vTmpCheckBoxGroup, 'input', '', vID + 'BlockCheckBox');
        vTmpInput.setAttribute('type', 'checkbox');
        vTmpInput.setAttribute('name', 'showBlock');
        // Add the event for check box
        vTmpInput.addEventListener('change', function (event) {
            vShowBlock = event.target.checked;
            if (vShowBlockCallback) {
                vShowBlockCallback(vTreeData);
            }
            else {
                console.log(vTreeData); // for debugging
            }
        });
        // Add the text for the element
        vTmpInput = newFPGAElement(vTmpCheckBoxGroup, 'label', '', '', '&nbsp;Show blocks');
        vTmpInput.setAttribute('for', 'showBlock');
    }
    /**
     * @function draw renders loop information in a tabular format.
     * @param {object} data is an object from tree node.
     */
    this.draw = function (data) {
        if (!data)
            return; // do nothing if data passed is empty
        if (vBodyRef)
            document.getElementById(vBodyRef).innerHTML = '';
        clearDivContent();
        // save the tree data for redraw with checkbox
        vTreeData = data;
        let vTreeNode = vTreeData.node.data;
        vTable = new FPGADataTable(vID + 'Table');
        vTable.setShowName(1);
        vTable.setShowLoc(1);
        vTable.setShowCaption(0);
        vTable.setTranpose(0);
        vTable.setClass('table table-bordered fpgaloop-table fpgaloop-hover-row');
        vTable.setColumnList('Pipelined', 'Block Scheduled II', 'Block Scheduled fMAX', 'Latency', 'Speculated Iterations', 'Max Interleaving Iterations', 'Brief Info');
        vTable.setAttributeMap({
            'Pipelined': 'pl',
            'Block Scheduled II': 'ii',
            'Block Scheduled fMAX': 'af',
            'Max Interleaving Iterations': 'mi',
            'Latency': 'lt',
            'Speculated Iterations': 'si',
            'Brief Info': 'brief'
        });
        let vLoopAttrData = null;
        let vOldLoopJson = null;
        let loopDataRows = [];
        if (loop_attrJSON.hasOwnProperty('nodes')) {
            if (vTreeNode.type === 'system') {
                let vFirstRow = true;
                loop_attrJSON['nodes'].forEach(function (vFuncObj) {
                    let vFuncName = vFuncObj['name'];
                    let vFuncType = (vFuncObj['type'] === 'component') ? "Component: " : "Kernel: ";
                    vOldLoopJson = searchJsonArrayByName(loopsJSON['children'], vFuncType + vFuncName);
                    if (!vOldLoopJson) {
                        vOldLoopJson = searchJsonArrayByName(loopsJSON['children'], "Task: " + vFuncName);
                    }
                    parseJson(vFuncObj, 0, vOldLoopJson);
                    vFirstRow = false;
                });
            }
            else {
                // type match with return from getLoopType()
                vLoopAttrData = (vTreeNode.type === 'loop')
                    ? searchJsonArrayByName(loop_attrJSON['nodes'], vTreeNode.name)
                    : searchJsonArrayByName(loop_attrJSON['nodes'], getRealName(vTreeNode.name));
                vOldLoopJson = searchJsonArrayByName(loopsJSON['children'], vTreeNode.name);
                if (vLoopAttrData) {
                    parseJson(vLoopAttrData, 0, vOldLoopJson);
                }
            }
        }
        /**
         * @function parseJson parses a json dictionary structure and writes results into loopDataRows
         * @param {object} loopBlock is a json dictionary structure found in loop_attrJSON
         * @param {int} ID of the parent row. Use 0 if this is highest parent.
         * @param {object} json is a json dictionary structure found in loopsJSON:
         *   { 'name':<string>,
         *     'data': [<int>, <int>, <int>],
         *      'details': [],
         *      'children': {...} }
         */
        function parseJson(loopBlock, pParentId, json) {
            let realName = loopBlock['name'];
            let columns = {};
            columns['pl'] = loopBlock['pl'];
            columns['ii'] = loopBlock['ii'];
            columns['af'] = loopBlock['af'];
            columns['mi'] = loopBlock['mi'];
            columns['lt'] = loopBlock['lt'];
            columns['si'] = (json) ? json['data'][2] : "n/a"; // block
            // details still comes from old json
            columns['brief'] = (json && json.hasOwnProperty('details') && json['details'][0]['type'] === "brief") ?
                json['details'][0]['text'] : "";
            let noteCall = 'clearDivContent()';
            // PATCH: We want to include the json details from loops.json AND the details from loops_attr.json
            // Remove when case:14013361689 is implemented!
            let detailsJSON = undefined;
            if (loopBlock.hasOwnProperty('details')) {
                detailsJSON = loopBlock['details'];
            }
            if (json && json.hasOwnProperty('details') && json.hasOwnProperty('name') && getRealName(json['name']) === realName) {
                if (detailsJSON != undefined)
                    detailsJSON = detailsJSON.concat(json['details']);
                else
                    detailsJSON = json['details'];
            }
            if (detailsJSON != undefined) {
                let detailHTML = getHTMLDetailsFromJSON(detailsJSON, realName);
                noteCall = 'changeDivContent(0,' + JSON.stringify(detailHTML) + ')';
            }
            let debugLoc = null;
            if (loopBlock.hasOwnProperty('debug')) {
                debugLoc = loopBlock['debug'];
            }
            let rowId = loopBlock['id'];
            // Add Component invocation to name
            // name still comes from old json until we unify all the names
            let secondaryName = (loopBlock.hasOwnProperty('ci') && loopBlock['ci'] === '1') ? " (Component invocation)" : "";
            // Front-end to add type so data is identical in every view
            let prefix = '';
            if (product === PRODUCTS.HLS) {
                // TODO: fix bug where Task is type kernel
                if (loopBlock['type'] === 'component') {
                    prefix = 'Component: ';
                }
                else if (loopBlock['type'] === 'kernel') {
                    prefix = 'Task: ';
                }
            }
            else {
                if (loopBlock['type'] === 'kernel') {
                    prefix = 'Kernel: ';
                }
            }
            loopDataRows.push(new FPGADataRow(rowId, prefix + realName + secondaryName, debugLoc, columns, '', pParentId, 0, '', noteCall, ''));
            // iterate using loopBlock because it's topologically sorted
            if (jsonHasChildrenArray(loopBlock)) {
                loopBlock['children'].forEach(function (child) {
                    if (child['type'] === 'loop') {
                        let vSubLoopName = child['name'];
                        if (jsonHasChildrenArray(json)) {
                            let vSubLoop = null;
                            // just search immediate children for subloop
                            for (let i = 0; i < json['children'].length; i++) {
                                if (vSubLoopName === getRealName(json['children'][i]['name'])) {
                                    vSubLoop = json['children'][i];
                                    break;
                                }
                            }
                            parseJson(child, rowId, vSubLoop);
                        }
                        else { // can't find subloop in old loopJSON
                            parseJson(child, rowId, null);
                        }
                    }
                    else if (vShowBlock) {
                        parseJson(child, rowId, null);
                    }
                });
            }
        }
        if (loopDataRows.length > 0) {
            loopDataRows.forEach(function (loopRow) {
                vTable.addRow(loopRow);
            });
            document.getElementById(vBodyRef).appendChild(vTable.draw());
        }
        else {
            let fpgaloopTextMsg = document.createElement("P");
            fpgaloopTextMsg.className = "fpgaloop-info-text";
            fpgaloopTextMsg.innerText = "No information found for this node.";
            document.getElementById(vBodyRef).appendChild(fpgaloopTextMsg);
        }
    };
    // Define the callback for checkbox
    var vShowBlockCallback = this.draw;
};
if (typeof exports == "object" && typeof module != "undefined") {
    module.exports = {
        'jsonHasChildrenArray': jsonHasChildrenArray,
        'searchJsonArrayByName': searchJsonArrayByName,
        'isFunction': isFunction,
        'isBasicBlock': isBasicBlock,
        'getRealName': getRealName
    };
}
