"use strict";

// The chart below is created by refering to this example
// https://bl.ocks.org/smokbel/c23acfed102dbcbaab0df7e07fa6bb9a
// with the MIT License

var xAxis, x2Axis, yAxis;
var barClickedDown;
var startIndex, latestData, latestRegion;
var scheduleXTickWidth = 28;
var scheduleBarHeight = 26;
var scheduleBarSpacing = 6;
var scheduleMaxXValue;  // the maximum value for x-axis
var scrollUpDownSize = 1;  // number of element to change everytime up and down was pressed. Default max is 3
var XAxisIntervalSize = 1;  // Integer, number of clock cycle per division
var scheduleData;  // To be obseleted - this is the whole set of data

/**
 * @function getLastNonHiddenBarID returns the ID of the last rendered bar.
 * Returns 0 and issues a message if nothing is found.
 */
function getLastNonHiddenBarID() {
  for (let bi=scheduleData.length-1; bi>=0; bi--) {
    let curBar = scheduleData[bi];
    if (curBar.getVisible()) {
      return curBar.getId();
    }
  }
  console.log("Warning! All bars are hidden.");
  return 0;
}

/**
 * @function getBarIndex find the index of a bar in scheduleData list.
 * @param {Integer} barID id of the bar.
 * @returns the index of a real bar if exist, -1 otherwise.
 */
function getBarIndex(barID) {
  for (let bi=0; bi<scheduleData.length; bi++) {
    let curBar = scheduleData[bi];
    if (curBar.getId() === barID) {
      return bi;
    }
  }
  return -1;
}

function fitInDiv(divWidth, dataRange) {
  let requiredWidth = Math.ceil(dataRange / XAxisIntervalSize) * scheduleXTickWidth;
  return (divWidth > requiredWidth);
}

var HorizontalFloatBar = function(element) {
  // load in arguments from config object
  this.element = element;
  this.data = [];  // this is the data we use to render
  this.linkCallback = null;
  this.captionCallback = null;
  this.notesCallback = null;

  this.setNotesCallback = function(callback) { this.notesCallback = callback; }
  this.getNotesCallback = function() { return this.notesCallback; }
}

HorizontalFloatBar.prototype.getMaxNodeCount = function() {
  let reportBodyHeight = $(this.element).height();
  return Math.floor( (reportBodyHeight-150)/(scheduleBarHeight+scheduleBarSpacing) );

}

HorizontalFloatBar.prototype.addBarItem = function(barItem) {
  if (barItem instanceof BarItem) {
    // onlyl allow barItem to be pushed
    this.data.push(barItem);
  }
}

HorizontalFloatBar.prototype.clearData = function() {
  this.data.length = 0;
  this.data = [];
}

HorizontalFloatBar.prototype.clearPopover = function() {
  d3.selectAll(".popover").remove();  // remove existing popover
}

/**
 * @function startScheduleChart removes the existing and redraw with more bars.
 *                              to be obseleted as we should not slice data to mimic vertical scroll
 * @param {boolean} force_top
 */
HorizontalFloatBar.prototype.startScheduleChart = function(force_top) {
  // Restart the new graph
  var _this = this;
  $(_this.element).html("");

  barClickedDown = '';  // Reset the bar click down, this is to show the details persistently

  let filterBarsList = _this.sliceSchedule(top_node_id, force_top);
  if (filterBarsList.length <= 0) {
    if (scheduleData.length > 0) {
      $(_this.element).html("Screen size too small to load data.");
      return;
    }
    $(_this.element).html("No schedule to load.");
    return;
  }
  // set up callbacks
  _this.setNotesCallback(changeBarDetails);
  // clear existing data and add new one
  _this.clearData();
  filterBarsList.forEach(function (curBar) {
    _this.addBarItem(curBar);
  });
  _this.drawSchedule();
}

// set the first element to the ID selected and don't show collapsed hierarchy 
// chop the longest bar if longer than the last bar since we don't support horizontal scroll
// to be obseleted as we should not slice data to mimic vertical scroll
HorizontalFloatBar.prototype.sliceSchedule = function(selectedNodeID, force_top) {
  let selectedNodeIndex = getBarIndex(selectedNodeID);
  if (selectedNodeIndex === -1) { 
    console.warn("Warning! Selected ID does not exist."); 
    return []; 
  }
  let filteredNodes = [];
  let maxBarCount = this.getMaxNodeCount();
  // check if the number of bars exceeds the height
  // 2 cases: too many bars --> push up to a certain amount based on size
  //          not enough bars to utilitize full height
  //          - check to shift bars preceed this index
  let barCount = 0;
  for (let bi=selectedNodeIndex; bi<scheduleData.length && barCount<maxBarCount; bi++) {
    let curBar = scheduleData[bi];
    if (curBar.getVisible()) {
      // reset the curBar end to previous value
      filteredNodes.push(curBar);  // copy by reference since we want the original data
      barCount++;
    }
  }
  if (!force_top && barCount<maxBarCount && selectedNodeIndex>0) {
    // shift more curBar preceed to this curBar if this is not the first curBar
    for (let bi=selectedNodeIndex-1; bi>=0 && barCount<maxBarCount; bi--) {
      let curBar = scheduleData[bi];
      if (curBar.getVisible()) {
        filteredNodes.unshift(curBar);
        barCount++;
      }
    }
  }
  return filteredNodes;
}

// A simplify version of draw to demo the horizontal floating bar
HorizontalFloatBar.prototype.draw = function() {
  var _this = this;
  let divObj = this.element;

  var width = (divObj.width > 0) ? divObj.width : 800;
  let height = this.data.length*30;

  var svg = d3.select(this.element).append("svg")
              .attr("width", width)
              .attr("height", height);

  // Margin definitions: top=50 and bottom=100 for axis label
  // Left margin have instruction labels, so truncate the names or reduce the margin if all short names
  let leftMargin = 0.2*(width-50);
  this.margin = {top: 50, right: 30, bottom: 100, left: leftMargin},
  this.width = width - this.margin.left - this.margin.right,
  this.height = height - this.margin.top - this.margin.bottom; 

  this.plot = svg.append("g")
  .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")") ;		

  // All functions to draw scheduleViewer
  this.calculateXAxisAttributes();

  this.createScales();
  this.addAxes();
  this.drawGridLine();
  this.displayAxisTitle();
  this.renderBar();
}

// TODO: to be obsoleted
// Reason for obsoletion is because the way the scrolling is designed was a hack
HorizontalFloatBar.prototype.drawSchedule = function() {
  var _this = this;
  this.clearPopover();

  let divObj = $('#' + this.element.id);

  // === control begin ===
  // Add scroll up and down button
  let upIcon = document.createElement("span");
  upIcon.className = "body glyphicon";
  upIcon.innerHTML = "&#xe093;";
  let upButton = document.createElement("button");
  upButton.type = "button";
  upButton.id = "schUpButton";
  if (this.data[0].getId() === scheduleData[0].getId()) { upButton.disabled = true; }  // disable button if first element is already top
  upButton.appendChild(upIcon);
  let buttonsDiv = document.createElement("div");
  buttonsDiv.className = "text-left";
  buttonsDiv.appendChild(upButton);
  divObj.append(buttonsDiv);

  let downIcon = document.createElement("span");
  downIcon.className = "body glyphicon";
  downIcon.innerHTML = "&#xe094;";
  let downButton = document.createElement("button");
  downButton.type = "button";
  downButton.id = "schDownButton";
  if (this.getMaxNodeCount() >= scheduleData.length ||
    this.data[this.data.length-1].getId() === getLastNonHiddenBarID()) {
    // disable down when the screen can load more bars or I am at the bottom
    downButton.disabled = true; 
  }
  downButton.appendChild(downIcon);
  buttonsDiv.appendChild(downButton);  // Put near the top for alpha level

  // add zoom button to handle the case where bars below has large latency cause the x-axis scale too be too large
  let zoomInIcon = document.createElement("span");
  zoomInIcon.className = "body glyphicon";
  zoomInIcon.innerHTML = "&#xe015;";
  let zoomInButton = document.createElement("button");
  zoomInButton.type = "button";
  zoomInButton.id = "schZoomInButton";
  zoomInButton.disabled = (XAxisIntervalSize === 1) ? true : false;
  zoomInButton.appendChild(zoomInIcon);
  buttonsDiv.appendChild(zoomInButton);
  let zoomOutIcon = document.createElement("span");
  zoomOutIcon.className = "body glyphicon";
  zoomOutIcon.innerHTML = "&#xe016;";
  let zoomOutButton = document.createElement("button");
  zoomOutButton.type = "button";
  zoomOutButton.id = "schZoomOutButton";
  zoomOutButton.appendChild(zoomOutIcon);
  buttonsDiv.appendChild(zoomOutButton);
  // === control end ===

  // calculate width, height
  // make a minimum size if # of bars is too less, i.e. if I have collapsed everything
  var width = (divObj.width() > 0) ? divObj.width() : 800;
  let height = calculateHeight(this.data);

  var svg = d3.select(this.element).append("svg")
              .attr("width", width)
              .attr("height", height);

  // Margin definitions: top=50 and bottom=100 for axis label
  // Left margin have instruction labels, so truncate the names or reduce the margin if all short names
  let leftMargin = truncateLongNames(this.data);
  this.margin = {top: 50, right: 30, bottom: 100, left: leftMargin},
  this.width = width - this.margin.left - this.margin.right,
  this.height = height - this.margin.top - this.margin.bottom; 

  this.plot = svg.append("g")
                 .attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")") ;		

  // All functions to draw scheduleViewer
  this.calculateXAxisAttributes();

  // Enable when X-axis max less scheduleMaxXValue
  zoomOutButton.disabled = (this.XMaxDataValue >= scheduleMaxXValue);

  this.createScales();
  this.addAxes();
  this.drawGridLine();
  this.displayAxisTitle();
  this.renderBar();
  this.renderAxesAction();

  // Returns the height based on number of bars or use maximum
  function calculateHeight(nodeList) {
    if (divObj.height() <= 0) { 
      console.warn("Warning! Element height is 0.");
      return undefined;
    }
    // compare if there are more bars than can display too less
    let maxNodeCount = _this.getMaxNodeCount();
    if (nodeList.length < maxNodeCount) {
      return nodeList.length*40 + 150;
    }
    return divObj.height();
  }

  // truncate long names and returns the left margin use by the chart
  // Set max equals 15% of width and long words should be truncated. Design can always overwrite with less.
  function truncateLongNames(barList) {
    // reset all short name
    barList.forEach( function(curBar) {
      if (curBar.getMetadata("short name")) {
        curBar.deleteMetadata("short name");
      }
    });

    // set 20% of width or a readable minimum
    let maxWidth = 0.2*(width-50);
    maxWidth = (maxWidth < 80) ? 80 : maxWidth;
    // Find the maximum string length and see if it fits
    let maxNLenNode = barList.reduce(function(total, a) {
      if (a.getName().length > total.getName().length) { return a; }
      return total;
    });
    let maxNLen = maxNLenNode.getName().length * 10;  // string to pixel conversion factor 1char:10px
    if (maxNLen <= maxWidth) { return maxNLen; }  // everything fits

    let maxStrLen = Math.floor(maxWidth/10);
    barList.forEach( function(nodeObj) {
      if (nodeObj.getName().length > maxStrLen) {
          nodeObj.setMetadata("short name", "..." + 
                                nodeObj.getName().substring(nodeObj.getName().length-maxStrLen+3, nodeObj.getName().length));
      }
    });
    return maxWidth;
  }
}

// Determine the tickSize based on interval size, calculate max value based on tickSize
// Set this.XNumTicks and this.XMaxDataValue
// TODO: this can be extended to do horizontal scrolling
HorizontalFloatBar.prototype.calculateXAxisAttributes = function() {
  // Determine number of ticks based on data
  // The maximum and minimum value on x-axis is rounded up to the nearest integer from the data
  let minData = d3.min(this.data, function(d) { return Math.ceil(d.getStart()) });
  let maxData = d3.max(this.data, function(d) { return Math.ceil(d.getEnd()) });
  let dataRange = Math.ceil(maxData - minData);
  this.XNumTicks = dataRange;
  let dataNotFit = fitInDiv(this.width, this.XNumTicks);
  if (XAxisIntervalSize > 1) {
    // reduce the number of ticks
    this.XNumTicks = Math.ceil(this.XNumTicks / XAxisIntervalSize);
  }
  if (!dataNotFit) {
    // width doesn't fit the whole thing, so reduce the max value
    let XMaxValue = Math.floor(this.width / scheduleXTickWidth);
    this.XMaxDataValue = XMaxValue * XAxisIntervalSize;
    this.XNumTicks = XMaxValue;
  }
  else {
    // everything fits, now scale max value as it zooms out
    this.XMaxDataValue = maxData + dataRange * (XAxisIntervalSize-1);
    if (this.XMaxDataValue > scheduleMaxXValue) {
      this.XMaxDataValue = scheduleMaxXValue;  // boundary condition, cap max
    }
  }
}

HorizontalFloatBar.prototype.createScales = function() {
  this.y = d3.scale.ordinal()
                  .rangeRoundBands([0, this.height])
                  .domain(this.data.map(function(d) { return d.getId() }));

  this.x = d3.scale.linear()
                  .range( [0, this.width] )
                  .domain( [d3.min(this.data,function(d){ return d.getStart(); }), 
                    this.XMaxDataValue ] );
}

HorizontalFloatBar.prototype.addAxes = function() {
  var _this = this;

  // create and append axis elements
  xAxis = d3.svg.axis()
              .scale(this.x)
              .orient("top")
              .ticks(this.XNumTicks)
              .tickFormat(function(d) {return d;});

  x2Axis = d3.svg.axis()
                 .scale(this.x)
                 .orient("bottom")
                 .ticks(this.XNumTicks)
                 .tickFormat(function(d) {return d;});

  yAxis = d3.svg.axis()
                .scale(this.y)
                .orient("left")
                .tickFormat(function(d) {
                    // To map by ID
                    let nodeObj = _this.getBarByID(d);
                    if (nodeObj) {
                      return (nodeObj.getMetadata("short name")) ? nodeObj.getMetadata("short name") : nodeObj.getName();
                    } else {
                      console.log("Warning! Can't find bar in data");
                      return "Unknown name"; // Else return original data
                    }
                });

  this.plot.append("g")
          .attr("class", "x axis")
          .call(xAxis);

  this.plot.append("g")
          .attr("class", "x2 axis")  
          .attr("transform", "translate(0," + this.height + ")")
          .call(x2Axis);

  this.plot.append("g")
          .attr("class", "y axis")
          .call(yAxis);
}

HorizontalFloatBar.prototype.drawGridLine = function(){
    // Draw grid on x axis
    this.plot.append("g")
        .attr("class", "grid") 
        .call(xAxis
            .tickSize(-this.height, 0, 0)
            .tickFormat("")
        )
}

HorizontalFloatBar.prototype.displayAxisTitle = function(){	
  var _this = this;

  //xAxis title on top 
  _this.plot.append("g")	
    .attr("transform", "translate(0,-10)")		
    .append("text")
    .attr("class", "axisTitle")
    .attr("x", this.width-200)  
    .attr("y", -this.margin.top-5)
    .attr("dy", "2.8em")
    .text("Cluster instruction schedule cycle");

  //xAxis title on bottom 
  _this.plot.append("g")	
    .attr("transform", "translate(0," + this.height + ")")	
    .append("text")
    .attr("class", "axisTitle")
    .attr("x", this.width-120)  
    .attr("y", -this.margin.top+55)
    .attr("dy", "2.8em")
    .text("Absolute clock cycle");
}

HorizontalFloatBar.prototype.renderBar = function(){	 
  var _this = this;

  this.plot.selectAll(".bar")
           .data(this.data)
           .enter()
           .append("rect")
           .attr("id", function(d) { return "bar-" + d.getId(); })
           .attr("y", function(d) { return _this.y(d.getId()); })
           .attr("height", scheduleBarHeight)
           .attr("x", function(d) { return _this.x(d.getStart()); })
           .attr("width", function(d) {
             // not show if start > max, chop width if end > max, or it's okay
             if(d.getStart()>=_this.XMaxDataValue) { return 0; }
             else if (d.getEnd()>_this.XMaxDataValue) { return _this.x(_this.XMaxDataValue)-_this.x(d.getStart()); }
             else { return _this.x(d.getEnd())-_this.x(d.getStart()); }
           })
           .attr("fill", function(d) { return d.getColor(); })
          .style("cursor", function(d) { if (d.getNotes() !== null) { return "pointer"; } })
          .on('click', function(d) {
            let cb = _this.getNotesCallback();
            cb(d);
          });
}

// TODO: To be obseleted.
// This function should be obsoleted as it's not the proper support for scrolling for horizontal floating bar graph
HorizontalFloatBar.prototype.renderAxesAction = function() {
  var _this = this;

  // Up, down, zoom buttons
  let upButton = d3.select("#schUpButton");
  upButton.on('click', function(d) { 
    let barIndex = getBarIndex(_this.data[0].getId());
    // minus to shift up
    if (barIndex >= scrollUpDownSize) { 
      barIndex -= scrollUpDownSize;
      document.getElementById("schDownButton").disabled = false;  // enable down
    }
    top_node_id = scheduleData[barIndex].getId();  // update new top
    _this.startScheduleChart(false);
  });
  let downButton = d3.select("#schDownButton");
  downButton.on('click', function(d) { 
    let barIndex = getBarIndex(_this.data[0].getId());
    // plus to shift down
    if (barIndex < (scheduleData.length-scrollUpDownSize-1)) { 
      barIndex += scrollUpDownSize;
      document.getElementById("schUpButton").disabled = false;  // enable up
    }
    top_node_id = scheduleData[barIndex].getId();  // update new top
    _this.startScheduleChart(false);
  });
  let zoomInButton = d3.select("#schZoomInButton");
  zoomInButton.on('click', function(d) {
    XAxisIntervalSize /= 2;  // decrease the size when zoom in
    _this.startScheduleChart(false);
  })
  let zoomOutButton = d3.select("#schZoomOutButton");
  zoomOutButton.on('click', function(d) {
    XAxisIntervalSize *= 2;
    _this.startScheduleChart(false);
  })

  // Define 'div' for tooltips
  let div = d3.select("body")
              .append("div")  // declare the tooltip div 
              .attr("class", "popover")  // use popover for persistent for clicking
              .style("opacity", 0);      // set the opacity to nil

  _this.plot.selectAll('.y.axis .tick')
            .style("cursor", function(d) { 
              let barObj = _this.getBarByID(d); 
              if (barObj) {
                  if (barObj.getLink() || barObj.getMetadata("short name") || 
                        barObj.getMetadata("expand") !== null ) {
                    // change to pointer if has debug or name is truncated or has children to expand/collapse
                    return "pointer"; 
                  }
              }
            })
            .on('click', function(d) { createPopOver(d) });

  function createPopOver(d) {
    let barObj = _this.getBarByID(d);

    function toggleChildren(barId) {
      // toggle all children of bar hidden
      // rerender the whole graph by startScheduleChart
      let barIndex = getBarIndex(barId);
      if (barIndex < 0) {
        console.warn("Warning! Cannot find bar in schedule data:" + barId);
        return;
      }
      let bar = scheduleData[barIndex];
      bar.setMetadata('expand', !bar.getMetadata('expand'));
      let childrenIDList = bar.getMetadata("children");
      for(let ni=barIndex+1; ni<scheduleData.length; ni++) {
        let curNode = scheduleData[ni];
        if ( childrenIDList.includes(curNode.getId()) ) {
          curNode.setVisible(!curNode.getVisible());  // toggle it
          // do this recursively if child is expanded
          let curChildList = curNode.getMetadata("children");
          if (curChildList !== undefined && curNode.expand) {
            childrenIDList = childrenIDList.concat(curChildList);
          }
        }
      }
    }

    if (barObj) {
      if (barObj.getMetadata('tooltip')) {
        // remove tooltip capabilities if shown
        div.transition()
          .duration(200)
          .style("opacity", 0);
        barObj.setMetadata('tooltip', false);
        return;
      }
      // show tooltip
      barObj.setMetadata('tooltip', true);
      let divHTML = "";   // display the full name
      if (barObj.getLink()) {
          // add debug location and sync to editor
        let debugObj = barObj.getLink();
        let debugLoc = formatDebugLocation(debugObj);
        divHTML = "<a href=# onClick='syncEditorPaneToLine(" + debugObj.line + 
                  ", \"" + debugObj.filename + "\")'>" + barObj.getName() + " " + debugLoc + "</a><br/>";
      } else {
        divHTML = "<p>" + barObj.getName() +"</p>";
      }
      div.transition()
        .duration(200)
        .style("opacity", 1);

      if (barObj.getMetadata('expand') !== null) {
        // add expand and collapse button if it as children
        divHTML += "<button class=\"btn btn-secondary btn-sm\" id=\"schChildren\" data=" + barObj.getId();
        if (barObj.getMetadata('expand')) { divHTML += ">collapse</button>"; }
        else { divHTML += ">expand</button>"; }
      }

      div.html(divHTML)
        .style("left", (d3.event.pageX) + "px")
        .style("top", (d3.event.pageY - 28) + "px");  // 28 is from trial and error

      $('#schChildren').on('click', function () {
        toggleChildren( parseInt($(this).attr("data")) );
        _this.startScheduleChart(false);
      });
    }
  }
}

HorizontalFloatBar.prototype.getBarByID = function (id) {
  if (id <= 0) return undefined;
  for(let barIndex in this.data) {
    if (this.data[barIndex].getId() === id) { return this.data[barIndex]; }
  }
  return undefined;
}

/**
 * @class BarItem
 * @param {integer} id
 * @param {string} name
 * @param {integer} start
 * @param {integer} end
 * @param {hex code} color
 * @param {debug object} link single debug object = {filename:<string>, line:<integer>}
 * @param {string} caption text to be shown when mouseover the bar
 * @param {details list} notes to be shown
 */
var BarItem = function(id, name, start, end, color, link, caption, notes) {
  this.vId = id;
  this.vName = name;
  this.vStart = start;
  this.vEnd = end;
  this.vColor = color;
  this.vLink = link;
  this.vCaption = caption;  // mouseover tooltip
  this.vNotes = notes;      // additional information to show user
  this.vMetadata = {};      // key value pair: use by short name, hierarchy colliapse support
  this.vVisible = true;      // default is show in the graph, false means don't render it
  this.getId = function () { return this.vId; };
  this.getName = function () { return this.vName; };
  this.getStart = function() { return this.vStart; }
  this.getEnd = function() { return this.vEnd; }
  this.getLink = function () { return this.vLink; };
  this.getColor = function () { return this.vColor; };
  this.getCaption = function () { return this.vCaption; };
  this.getNotes = function () { return this.vNotes; };
  this.getVisible = function () { return this.vVisible; }
  this.getMetadata = function (key) {
    if (this.vMetadata.hasOwnProperty(key)) { return this.vMetadata[key]; }
    return null;
  }

  this.setVisible = function (visible) { this.vVisible = visible; }
  this.setMetadata = function (key, value) { 
    this.vMetadata[key] = value;
  }

  this.deleteMetadata = function (key) {
    delete this.vMetadata[key];
  }
}
