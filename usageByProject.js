
var bufferSpace = 50;
var width = $(window).width() - 100;
var height = $(window).height() - 100;


// TODO: would be quite nice if this accepted CIDR notation
var availableNetworks = [ '192.168.4', '192.168.5', '192.168.19', '172.25' ];

var valueOptions = [ 'count', 'cpu', 'mem' ];
var sumFrom = "count";   // start with count as the selected option

var projectArray = [];

//displayArray(projectArray);

var radius = Math.min(width, height) / 2;
var legendRectSize = 18;
var legendSpacing = 4;

var availableTypes = [ 'physical', 'virtual' ];
var availableOs = [ 'solaris', 'windows', 'redhat', 'noanswer' ];

var includes = {
	// defaults
	types:		[ 'virtual'  ],
	os:		[ 'solaris', 'windows', 'redhat', 'noanswer' ],
	networks:	[ '192.168.4' ],

	physical:	function(){return isInArray('physical', this.types)},
	virtual:	function(){return isInArray('virtual', this.types)},
	solaris:	function(){return isInArray('solaris', this.os)},
	windows:	function(){return isInArray('windows', this.os)},
	redhat:		function(){return isInArray('redhat', this.os)},
	noanswer:	function(){return isInArray('noanswer', this.os)},
	};








// -----------------  functions and classes --------------

// define Project object
var Project = {
	name:	"unset",
	count:	0,
	mem:	0,
	cpu:	0,
	enabled:	true,
	setName:	function(inText){this.name = inText;},
	getName:	function() {return this.name;},
	isEnabled:	function() {return this.enabled;},
	changeEnabled:	function() {if(this.enabled){this.enabled=false;}else{this.enabled=true;}},
	getCount:	function(){return this.count;},
	getCpu:		function(){return this.cpu;},
	getMem:		function(){return this.mem;},
	getValue:	function()
			{
				var rc=0;
				if(this.isEnabled()){
					if(sumFrom === 'count'){rc=this.count;}
					if(sumFrom === 'cpu'){rc=this.cpu;}
					if(sumFrom === 'mem'){rc=this.mem;}
				}
				return Math.round(rc);
			},
	getTextValue:	function(){ 
				rv=this.getValue();
				if(sumFrom === 'cpu'){rv=rv + " cpus";}
				if(sumFrom === 'mem'){rv=Math.round(rv/(1024*1024)) + " gb";}
				return rv;
				},
	setCount:	function(val){this.count=val;},
	setCpu:		function(val){this.cpu=val;},
	setMem:		function(val){this.mem=val;},
	incrCount:	function(){this.count++;},
	addToMem:	function(val){this.mem+=parseInt(val);},
	addToCpu:	function(val){this.cpu+=parseInt(val);},
	resetValues:	function(){this.setMem(0);this.setCpu(0);this.setCount(0);},
	};


function displayArray(thisArray) {
	console.log("array follows");
	for(var i=0;i<thisArray.length;i++){ 
		console.log("name:  " + thisArray[i].getName());
		console.log("cpu:   " + thisArray[i].getCpu());
		console.log("mem:   " + thisArray[i].getMem());
		console.log("count: " + thisArray[i].getCount());
		console.log("value: " + thisArray[i].getValue());
		console.log("enabled: " + thisArray[i].isEnabled());
	}
	console.log("array precedes");
	}

function changeEnabled(projName) {
	for(var i=0;i<projectArray.length;i++){ 
		if(projectArray[i].getName() === projName){
			projectArray[i].changeEnabled();
			//displayArray(projectArray);
			break;
		}
	}
}



function testAlert(){ 
	displayArray(projectArray);
	console.log(
		"physical:  " + includes.physical() + "\n" +
		"virtual:   " + includes.virtual() + "\n" +
		"solaris:   " + includes.solaris() + "\n" +
		"windows:   " + includes.windows() + "\n" +
		"redhat:    " + includes.redhat() + "\n" +
		"noanswer:  " + includes.noanswer() + "\n" +
		includes.networks + "\n" +
		includes.os + "\n" +
		includes.types + "\n"
		); 
	console.log("sumFrom: " + sumFrom);
};


function resetValues(projArray) {
	// console.log("Resetting values...");
	for(var count=0; count<projArray.length; count++) { projArray[count].resetValues();}
}

function getNumEnabledProjects(projArray) {
	var total = 0;
	for(var count=0; count<projArray.length; count++) { if(projArray[count].isEnabled()) { total++;} }
	return total;
}

function isInArray(item,thisArray) {
	for(var t=0;t<thisArray.length;t++) { if(thisArray[t] === item) {return true;}}
	return false;
}

function addToArray(item,thisArray) {
	return thisArray.push(item);
}

function removeFromArray(item,thisArray) {
	for(var count=0;count<thisArray.length;count++) { if(thisArray[count] === item) { thisArray.splice(count,1); break; }}
}

function addOrRemoveVal(theValue,theArray,shouldBePresent)
{
	if(shouldBePresent){addToArray(theValue,theArray);}else{removeFromArray(theValue,theArray);}
}

function drawLegend() {
	//console.log("drawing legend");
	legend = svg.selectAll('.legend')
		.data(colourScale.domain())
		.enter()
		.append('g').attr('class','legend')
		.attr('transform',function(d,i) {
			var lheight = legendRectSize + legendSpacing;
			var loffset = -1 * lheight * colourScale.domain().length / 6;
			var horz = legendRectSize;
			var vert = i * lheight - loffset;
			return 'translate(' + horz + ',' + vert + ')';
	});

	legend.append('rect')
		.attr('width', legendRectSize)
		.attr('height', legendRectSize)
		.style('fill', colourScale)
		.style('stroke', colourScale)
		.on('click', function(label){
			var rect = d3.select(this);
			var enabled = true;
			var totalEnabled = getNumEnabledProjects(projectArray);
			changeEnabled(label);
			redrawPie();
			if(rect.attr('class') === 'disabled'){
				rect.attr('class','');
			} else {
				if(totalEnabled < 2) return;
				rect.attr('class', 'disabled');
				enabled = false;
			}
		});


	legend.append('text')
		.attr('x', legendRectSize + legendSpacing)
		.attr('y', legendRectSize - legendSpacing)
		.text(function(d) { return d; });

	//console.log(colourScale);
	//console.log(colourScale.domain());
	//console.log(legend);
	//console.log("finished drawing legend");
}


function populateProjectArray(thisProjectArray,theseSystems,theseIncludes) {
	for(var pcount=0;pcount<theseSystems.servers.length;pcount++) {
		var thisServ = theseSystems.servers[pcount];
		if(includes.physical()){
			addSystemToProjectArray(thisProjectArray,thisServ,theseIncludes);
		}
		if(includes.virtual()){
			for(var vcount=0;vcount<thisServ.vms.length;vcount++){
				var thisVm=thisServ.vms[vcount];
				if(thisVm.state !== "shut"){
					addSystemToProjectArray(thisProjectArray,thisVm,theseIncludes);
				}
			}
		}
	}
}

function addSystemToProjectArray(theArray,theServ,theIncludes){
	var projectAlreadyThere=false;
	var projIndex=-1;
	if(theServ.project === "") { console.log(theServ.name + " has no project?");};
	for(var i=0;i<theArray.length;i++){
		if(theArray[i].name === theServ.project){
			projectAlreadyThere=true;
			projIndex=i;
			// console.log("set projIndex to " + projIndex + " to match existing project " + theArray[i].name);
		}
	}
	if(!projectAlreadyThere){
		theArray.push(Object.create(Project, {'name': {value: theServ.project}}));
		projIndex=theArray.length-1;
		// console.log("set projIndex to " + projIndex + " for new project " + theServ.project);
	}
	//console.log(projIndex);
	if(isIncluded(theServ,theIncludes)){
		theArray[projIndex].addToCpu(theServ.cpus);
		theArray[projIndex].addToMem(theServ.maxMem);
		theArray[projIndex].incrCount();
	}
}


function isIncluded(aSystem,someIncludes)
{
	var netMatch=false;
	for(var netCount=0;netCount<someIncludes.networks.length;netCount++){
		var regex = RegExp(someIncludes.networks[netCount]);
		if(aSystem.ipAddr.match(regex)) {
			netMatch=true;
		}
	}
	return (
		(netMatch)
		&&
		(
			(someIncludes.solaris() && aSystem.os.match(/Solaris/i))
			||
			(someIncludes.redhat() && aSystem.os.match(/Redhat/i))
			||
			(someIncludes.redhat() && aSystem.os.match(/CentOS/i))
			||
			(someIncludes.windows() && aSystem.os.match(/windows/i))
			||
			(someIncludes.noanswer() && aSystem.os.match(/noanswer/i))
		)
	)
}


function arcTween(a) {
	// console.log("arcTween   " + a );
	var i = d3.interpolate(this._current, a);
	this._current = i(0);
	return function(t){ return arc(i(t)); };
	}


function drawSelectionBoxes(){

	// ------- selectDiv for count / cpu /mem -------------
	var selectDiv = body.append("div")
		.attr("id", "selectDiv");

	var valueForm = selectDiv.append("form");

	var valueOptionsEnter = valueForm.selectAll("span")
		.data(valueOptions)
		.enter().append("span");

	valueOptionsEnter.append("input")
		.attr({
			type:	"radio",
			class:	"chooser",
			name:	"choice",
			value:	function(d){return d;},
			onclick:	"sumFrom=this.value;redrawPie();",
			})
			.property("checked", function(d){return(d===sumFrom); });

	valueOptionsEnter.append("label").text(function(d){return d;});
	// ------- selectDiv for count / cpu /mem -------------


	// ------- netSelectDiv for networks -------------
	var netSelectDiv = body.append("div")
		.attr("id", "netSelectDiv");
	var netForm = netSelectDiv.append("form");
	var netCheckBoxLabelEnter = netForm.selectAll("span")
		.data(availableNetworks)
		.enter()
		.append("span");
	netCheckBoxLabelEnter.append("input")
		.attr({
			type:	"checkbox",
			class:	"chooser",
			name:	"netchoice",
			value:	function(d){return d;},
			onclick:	"addOrRemoveVal(this.value,includes.networks,this.checked);resetValues(projectArray);populateProjectArray(projectArray,systems,includes);redrawPie();",
		})
		.property("checked", function(d){return(isInArray(d,includes.networks)); });
	netCheckBoxLabelEnter.append("label").text(function(d){return d;});
	// ------- netSelectDiv for networks -------------




	// ------- typeSelectDiv for different types (phys/virt) -------
	var typeSelectDiv = body.append("div")
		.attr("id", "typeSelectDiv");
	var typeForm = typeSelectDiv.append("form");
	var typeCheckBoxLabelEnter = typeForm.selectAll("span")
		.data(availableTypes)
		.enter()
		.append("span");
	typeCheckBoxLabelEnter.append("input")
		.attr({
			type:	"checkbox",
			class:	"chooser",
			name:	"typechoice",
			value:	function(d){return d;},
//			onclick:	"addOrRemoveVal(this.value,includes.types,this.checked);resetValues(projectArray);populateProjectArray(projectArray,systems,includes);redrawPie();",
                })
		.property("checked", function(d){return(isInArray(d,includes.types)); })
		.on('click',	function(){
				addOrRemoveVal(this.value,includes.types,this.checked);
				resetValues(projectArray);
				populateProjectArray(projectArray,systems,includes);
				redrawPie();
		});
	typeCheckBoxLabelEnter.append("label").text(function(d){return d;});
	// ------- typeSelectDiv for different types (sol/lin/win phys/virt) -------




	// ------- osSelectDiv for different os (phys/virt) -------
	var osSelectDiv = body.append("div")
		.attr("id", "osSelectDiv");
	var osForm = osSelectDiv.append("form");
	var osCheckBoxLabelEnter = osForm.selectAll("span")
		.data(availableOs)
		.enter()
		.append("span");
	osCheckBoxLabelEnter.append("input")
		.attr({
			type:	"checkbox",
			class:	"chooser",
			name:	"oschoice",
			value:	function(d){return d;},
			onclick:	"addOrRemoveVal(this.value,includes.os,this.checked);resetValues(projectArray);populateProjectArray(projectArray,systems,includes);redrawPie();",
		})
		.property("checked", function(d){return(isInArray(d,includes.os)); });
	osCheckBoxLabelEnter.append("label").text(function(d){return d;});
	// ------- osSelectDiv for different os (sol/lin/win phys/virt) -------
}


function drawPie(){
	tooltip = d3.select('body')
		.append('div')
		.attr('class', 'tooltip');
		tooltip.append('div').attr('class','label');
		tooltip.append('div').attr('class','value');
		tooltip.append('div').attr('class','percent');
	arc = d3.svg.arc().innerRadius(radius/2).outerRadius(radius);
	pie = d3.layout.pie() .value(function(d){ return d.getValue(); }).sort(null);
	path = g.selectAll('path')
		.data(pie(projectArray))
		.enter()
		.append('path');
	path.transition()
		.duration(1000)
		.attr('d', arc)
		.attr('fill', function(d, i) { 
			return colourScale(d.data.getName());
		})
		.each(function(d) { this._current = d; });
	path.on('mouseover', function(d){
		tooltip.select('.label').html(d.data.getName());          
		var total = d3.sum(pie(projectArray).map(function(d){
			//console.log(d.data.name + " " + d.data.isEnabled());
			return d.data.getValue(); 
		}));
		var percent = Math.round(1000*d.data.getValue() / total) / 10;
		tooltip.select('.value').html(d.data.getTextValue());
		tooltip.select('.percent').html(percent + '%');
		tooltip.style('display', 'block');
		});
	path.on('mouseout', function(d){
		tooltip.style('display', 'none');
		});
	path.on('mousemove', function(d) {
		tooltip.style('top', (d3.event.pageY + 10) + 'px')
       			.style('left', (d3.event.pageX + 10) + 'px');
		});
}

function redrawPie(){
	// console.log("Redrawing pie");
	path.data(pie(projectArray));
	path.transition()
		.duration(1000)
		.attrTween('d', arcTween);
}

// ------------------------ end of functions and classes ----------





var body = d3.select("body");

var svg = body.append("svg")
	.attr("width", width)
	.attr("height", height);


var colourScale = d3.scale.category20b();

drawSelectionBoxes();



//var testBtnDiv = body.append("div")
//	.attr("id", "testBtnDiv");
//var button = testBtnDiv
//	.append("button")
//	.attr("id", "testButton")
//	.text("testButton")
//	.attr("onclick", "testAlert();");



var g=svg.append('g').attr('transform', 'translate(' + (width/2) + ',' + (height/2) + ')');

var path;
var pie;
var arc;
var tooltip;
var legend;

populateProjectArray(projectArray,systems,includes);


drawPie();

drawLegend();


