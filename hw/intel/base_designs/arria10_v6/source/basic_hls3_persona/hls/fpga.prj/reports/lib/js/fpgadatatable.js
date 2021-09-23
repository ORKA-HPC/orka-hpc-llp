//===------------------------- fpgadatatable.js ---------------------------===//
//
// FPGADataTable draws html tables and rely on datatable as engine
//
//===----------------------------------------------------------------------===//
"use strict";
/**
 * @function FPGATable returns a DOM table object. The table is rendered in the order of datalist which the user adds.
 * vTranspose compitability table
 *                |  0   |  1   |
 * ---------------+------+-------
 * showHeader     |    Yes      |
 * showLoc        | Yes  |  No  |
 * showCaption    | Yes  |  No  |
 * vEventRow      | Yes  |  No  |
 * vEventColumns  |    Yes*     | Append (?) to show row title during mouseover. *See _drawHeaderTranspose to see how to add title to header.
 * parent indent  | Yes  |  No  | To be implemented
 * group collapse | Yes  |  No  | To be implemented
 */
var FPGADataTable = function (pID) {
    this.vID = pID; // ID given to the table in the document
    this.vColumnList = null; // Ordered list of columns to display. TODO: support for tooltip
    this.vShowName = 1;
    this.vShowLoc = 0; // 1 means add 2nd column debugLoc
    this.vShowCaption = 0; // 1 means add last column to show user useful brief messages
    this.vShowHeader = 1; // 1 means include a header in the table. Data column is defined by vColumnList
    this.vAttrColumnMap = null; // User defined mapping from display column name to internal attribute name
    this.vTranspose = 0; // 1 means show row as columns
    this.vEventRow = 1; // 1 means the row to see details
    this.vEventColumns = []; // a list of columns which user to overwrite for per column details
    this.vLinksCallback = null; // Callback to render locations
    this.vNotesCallback = null; // Callback to render more detail information
    this.vTooltipCallback = null;
    this.vDataList = []; // rows in the table
    this.vNameWidth = 200; // px
    this.vLocWidth = 50; // px
    this.vDataWidth = 50; // px
    this.vCaptionWidth = 36; // px
    this.vClassName = "table table-striped table-bordered table-sm"; // default style is for details
    this.setShowName = function (val) { this.vShowName = val; };
    this.setShowLoc = function (val) { this.vShowLoc = val; };
    this.setShowCaption = function (val) { this.vShowCaption = val; };
    this.setShowHeader = function (val) { this.vShowHeader = val; };
    this.setTranpose = function (val) { this.vTranspose = val; };
    this.setNameWidth = function (val) { this.vNameWidth = val; };
    this.setDataWidth = function (val) { this.vDataWidth = val; };
    this.setClass = function (val) { this.vClassName = val; };
    this.setEventRow = function (val) { this.vEventRow = val; };
};
FPGADataTable.prototype.setColumnList = function () {
    this.vColumnList = new Array();
    for (var i = 0; i < arguments.length; i++) {
        this.vColumnList.push(arguments[i]);
    }
};
FPGADataTable.prototype.setEventColumns = function (val) {
    if (!(Array.isArray(val)))
        return;
    this.vEventColumns = val;
};
FPGADataTable.prototype.setAttributeMap = function (val) {
    this.vAttrColumnMap = {};
    var _this = this;
    if (!(typeof val === "object"))
        return;
    for (var key in val) {
        _this.vAttrColumnMap[key] = val[key];
    }
};
FPGADataTable.prototype.addRow = function (pRow) {
    if (!(pRow instanceof FPGADataRow)) {
        return;
    }
    this.vDataList.push(pRow);
};
FPGADataTable.prototype.clearRows = function () {
    this.vDataList = [];
};
FPGADataTable.prototype.draw = function () {
    var _this = this;
    var vTable = document.createElement('table');
    vTable.className = this.vClassName;
    vTable.id = this.vID;
    if (this.vTranspose) {
        // Transpose does not support location and caption
        if (this.vShowHeader)
            this._drawHeaderTranspose(vTable);
        // draw table by turning column into row
        this.vColumnList.forEach(function (col) {
            var vTmpRow = document.createElement('tr');
            // column becomes the name
            if (_this.vShowName)
                _this._newCell(vTmpRow, 'td', col, _this.vNameWidth, '');
            if (_this.vAttrColumnMap) { // no data when no attribute map
                _this.vDataList.forEach(function (row) {
                    let vValue = row.getDataValue(_this.vAttrColumnMap[col]);
                    if (_this.vEventColumns.indexOf(_this.vAttrColumnMap[col]) !== -1)
                        _this._newCell(vTmpRow, 'td', vValue, _this.vDataWidth, row.getClass(), row.getTitle(), row.getNote());
                    else
                        _this._newCell(vTmpRow, 'td', vValue, _this.vDataWidth, row.getClass());
                });
            }
            vTable.appendChild(vTmpRow);
        });
    }
    else { // draw normal table
        // draw header
        if (this.vShowHeader)
            this._drawHeader(vTable);
        let vParentIdLevelDict = {};
        // draw table
        for (let i = 0; i < this.vDataList.length; i++) {
            let row = this.vDataList[i];
            // Add intentation for children
            let vRowParentID = row.getParentID();
            if (vRowParentID === 0 || !vParentIdLevelDict.hasOwnProperty(vRowParentID)) {
                // No parent
                vParentIdLevelDict[row.getID()] = 0;
                if (vRowParentID !== 0 && !vParentIdLevelDict.hasOwnProperty(vRowParentID))
                    console.log("Parent of " + row.getID() + " does not exist");
            }
            else {
                // Compute margin based on the level
                vParentIdLevelDict[row.getID()] = vParentIdLevelDict[vRowParentID] + 1;
            }
            var vTmpRow = document.createElement('tr');
            if (this.vEventRow) {
                vTmpRow.className = row.getClass(); // apply the class to the whole row
                if (row.getNote())
                    vTmpRow.setAttribute('onclick', row.getNote());
            }
            if (this.vShowName) {
                let vNameCell;
                if (_this.vEventRow)
                    vNameCell = this._newCell(vTmpRow, 'td', row.getName(), this.vNameWidth, '', row.getTitle());
                else if (!_this.vEventRow && _this.vEventColumns.indexOf('name') !== -1)
                    vNameCell = this._newCell(vTmpRow, 'td', row.getName(), this.vNameWidth, '', row.getTitle(), row.getNote());
                else
                    vNameCell = this._newCell(vTmpRow, 'td', row.getName(), this.vNameWidth, '', '', row.getNote());
                vNameCell.style.paddingLeft = (parseInt((vParentIdLevelDict[row.getID()] + 1) * 8)).toString() + 'px';
                ;
            }
            if (this.vShowLoc) {
                let debugLoc = row.getDebugLoc();
                // TODO: Using the outerHTML is a workaround since we flatten with outerhtml in main.js
                if (debugLoc)
                    this._newCell(vTmpRow, 'td', createDebugLocation(debugLoc[0][0]).outerHTML, this.vLocWidth, '');
                else
                    this._newCell(vTmpRow, 'td', '', this.vLocWidth, '');
            }
            if (this.vAttrColumnMap) {
                this.vColumnList.forEach(function (col) {
                    let vValue = row.getDataValue(_this.vAttrColumnMap[col]);
                    if (!_this.vEventRow) {
                        if (_this.vEventColumns.indexOf(col) !== -1)
                            _this._newCell(vTmpRow, 'td', vValue, _this.vDataWidth, '', row.getTitle(), row.getNote()); // highlight apply on the cell
                        else
                            _this._newCell(vTmpRow, 'td', vValue, _this.vDataWidth, '', '', row.getNote());
                    }
                    else
                        _this._newCell(vTmpRow, 'td', vValue, _this.vDataWidth, '', '', row.getNote());
                });
            }
            // TODO: show caption
            vTable.appendChild(vTmpRow);
        }
    }
    return vTable;
};
FPGADataTable.prototype._drawHeader = function (pParent) {
    var vTmpHead = document.createElement('thead');
    var vTmpRow = document.createElement('tr');
    if (this.vShowName)
        this._newCell(vTmpRow, 'th', 'Name', this.vNameWidth, '');
    if (this.vShowLoc)
        this._newCell(vTmpRow, 'th', 'Source Location', this.vLocWidth, '');
    for (var i = 0; i < this.vColumnList.length; i++) {
        this._newCell(vTmpRow, 'th', this.vColumnList[i], this.vDataWidth, '');
    }
    if (this.vShowCaption)
        this._newCell(vTmpRow, 'th', '\u00A0', this.vCaptionWidth, '');
    vTmpHead.appendChild(vTmpRow);
    pParent.appendChild(vTmpHead);
};
FPGADataTable.prototype._drawHeaderTranspose = function (pParent) {
    var vTmpHead = document.createElement('thead');
    var vTmpRow = document.createElement('tr');
    if (this.vShowName)
        this._newCell(vTmpRow, 'th', '\u00A0', this.vNameWidth, '');
    // Go through all data and turn the name into header
    for (var i = 0; i < this.vDataList.length; i++) {
        if (this.vEventColumns.indexOf('name') !== -1)
            this._newCell(vTmpRow, 'th', this.vDataList[i].getName(), this.vDataWidth, '', this.vDataList[i].getTitle(), this.vDataList[i].getNote());
        else
            this._newCell(vTmpRow, 'th', this.vDataList[i].getName(), this.vDataWidth, '');
    }
    vTmpHead.appendChild(vTmpRow);
    pParent.appendChild(vTmpHead);
};
/**
 * @function _newCell creates a table header cell or data cells.
 * @param {element} pParent is a DOM table row element which the cell will be append to.
 * @param {string} pType can only be th or td
 * @param {string} pText is the content of the cell
 * @param {string/integer} pWidth is width of the cell
 * @param {string} pClass is the class apply to the cell
 * @param {string} pTitle is an optional parameter. If provided, it will add (?) next to the text where the content of pTitle will appear
 *                        when the user mouseover the (?). pTitle is expected to be HTML formatted.
 * @param {function} pCallback is an optional parameter. If provided, it defined the behavior for onclick.
 */
FPGADataTable.prototype._newCell = function (pParent, pType, pText, pWidth, pClass, pTitle, pCallback) {
    if (pType !== 'th' && pType !== 'td')
        return;
    var vTitle = (pTitle !== undefined) ? pTitle : null;
    var vCallback = (pCallback !== undefined) ? pCallback : null;
    var vNewCell = newFPGAElement(pParent, pType, pClass, '', pText);
    if (pWidth)
        vNewCell.style.width = (isNaN(pWidth * 1)) ? pWidth : pWidth + 'px';
    if (pText !== null) {
        // Only add click event when there's text in the cell
        // TODO: add attribute onclick='pCallback' is a hack since our main invokes innerHTML which resulted
        // removing any event listener. The proper way to do this use appendChild
        if (vCallback)
            vNewCell.setAttribute('onclick', pCallback);
        // Only add tooltip if there's a name column
        if (vTitle) { // optional parameter, formatted HTML string
            vNewCell.appendChild(createHelpTooltip(vTitle));
        }
    }
    return vNewCell;
};
/**
 * @param {integer} pID is a positive non-zero integer unique for each row
 * @param {string} pName is the string for first column in the row
 * @param {Array} pLocations is a list of debug locations {"filename":"line #"}
 * @param {Dict} pDataDict is a dictionary of attribute and value
 * @param {integer} pParentID is the id of the parent row. A non zero number means will add left intent to it's parent to indicate child.
 *                  0 means no parentID.
 * @param {string} pClass is one of the style defined in fpgadatatable.css. Empty means use default.
 * @param {integer} pGroup 0 means no collapse, 1 means collapse to parent id.
 * @param {string} pCaption is the brief info to show in the last column of row
 * @param {string} pNote is a stringified function to be used for onclick.
 * @param {string} pTitle is an optional HTML string to display allow side name with (?) for mouseover tooltip
 */
var FPGADataRow = function (pID, pName, pLocations, pDataDict, pClass, pParentID, pGroup, pCaption, pNote, pTitle) {
    this.vID = parseInt(pID);
    this.vName = pName;
    this.vClass = pClass;
    this.vParentID = pParentID;
    this.vCaption = document.createTextNode(pCaption).data;
    this.vNote = pNote;
    this.vTitle = (pTitle !== undefined && pTitle) ? pTitle : null; // optional
    if (!(typeof pDataDict === "object")) {
        console.log("Error! FPGADataRow pDataDict is not an array.");
    }
    if (pLocations && !Array.isArray(pLocations)) {
        console.log("Error! FPGADataRow pDataDict is not an array.");
    }
    this.vDebugLocs = pLocations; // debug object
    this.vDataList = pDataDict; // list of key value pair for columns in table
    this.getID = function () { return this.vID; };
    this.getName = function () { return this.vName; };
    this.getDebugLoc = function () { return this.vDebugLocs; };
    this.getClass = function () { return this.vClass; };
    this.getTitle = function () { return this.vTitle; };
    this.getNote = function () { return this.vNote; };
    this.getParentID = function () { return this.vParentID; };
    // TODO: getGroup
    this.getDataValue = function (attr) {
        if (this.vDataList.hasOwnProperty(attr))
            return this.vDataList[attr];
        return ''; // always return empty string to avoid rendering error
    };
    this.setName = function (val) { this.vName = val; };
};
if (typeof exports == "object" && typeof module != "undefined") {
    module.exports = {
        'FPGADataTable': FPGADataTable,
        'FPGADataRow': FPGADataRow
    };
}
