var sideHTML; // Instantiates sideHTML variable
var gridHeight = 25; //the height of the grid of resizing and dragging
var border = 2; //the border at the bottom for height stuff
var ctrlPressed = false;
var schHTML; // Instantiates schedule HTML variable, which will contain the "Mon-Sun" html on the main scheduler div.
var refDate = new Date(); // Reference date for where the calendar is now, so that it can switch between weeks.


var schItemNames = [];
var schItemStart = [];
var schItemDate = [];
var schItemCategory = [];
var schItemColor = [];

var schItem = [];

var curEvent;

var readied = false;


$(window).keydown(function(evt) {
  if (evt.which == 17) { // ctrl
    ctrlPressed = true;
  }
}).keyup(function(evt) {
  if (evt.which == 17) { // ctrl
    ctrlPressed = false;
  }
});


$(document).ready(function()
{
	if(!readied)
	{
		setTitles();
		
		curEvent = 0;
		
		sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops
		schHTML = $("#sch-days").html(); //The HTML for the scheduler days layout, useful for when days are refreshed
		
		$("#sidebar-title").tooltip({
			position: { my: "left top", at: "left bottom"}	
		}); //toss a tooltip on the events text
		
		
		//Add tooltips, which are also in add drag
		$(".evnt-desc").tooltip({
			position: { my: "left+15 top", at: "left bottom"}
		}); //toss a tooltip on the events text
		
		addDrag(); //add dragging, recursively
		
		colDroppable();
		
		addDates(new Date(), false);
		readied = true;
	}
});

function colDroppable()
{
	//make the columns droppable
	$(".col-snap").droppable({
		drop: function( event, ui ) //called when event is dropped on a new column (not called on moving it in the column)
		{
			if(ui.draggable.parent().attr("id") == "sch-tiles")
			{
				var topVal = parseFloat(ui.draggable.css("top"));
				topVal += 16;
				if(topVal < 0) //make sure the event is not halfway off the top
				{
					topVal = 0;
				}
				else if(topVal > $(this).height() - ui.draggable.outerHeight()) //or bottom
				{
					topVal = $(this).height() - ui.draggable.outerHeight();
				}
				//ui.draggable.css("top",topVal);
				console.log("Set top to " + topVal);
			}
			
	    	var element = ui.draggable.detach();
			$(this).append(element);
			ui.draggable.css("left","0px");
			element.css("top","0");
			//ui.draggable.children(".sch-evnt-icon").show();
			ui.draggable.children(".evnt-desc").show();
			$(this).parent().css("background","");
			
			$(ui.draggable).resizable({
		    	handles: 'n, s',
		    	grid: [ 0, gridHeight ],
		    	containment: "parent",
		    	resize: function(event, ui)
		    	{
		    		updateTime($(this), ui, true);
		    	}
			});
		},
		over: function( event, ui ) {
			$(this).parent().css("background","rgb(255, 255, 151)");
			$(ui.draggable).draggable("option","gridOn", true);
		},
		out: function( event, ui ) {
			$(this).parent().css("background","");
			$(ui.draggable).draggable("option","gridOn", false);
		}
	});
}

//the dragging function
function addDrag(selector)
{
	var newSchItem = false;
	var catBefore = "";
	
	if (selector == null)
		selector = "#sch-sidebar .sch-evnt";
		
	$(selector).draggable({
		containment: "window",
		snap: ".evt-snap",
		snapMode: "inner",
		appendTo: "body",
		cancel: "img",
		revert: "invalid",
		revertDuration: 0,
		stack: ".sch-evnt",
		opacity: 0.7,
		stack: "sch-evnt",
		distance: 10,
		gridOn: false,
		scroll: false,
		helper: function()
		{
			$copy = $(this).clone();
			$copy.children(".sch-cat-icon").css('display','none');
			var height = parseFloat($copy.css("height"));
			$copy.css("margin-top","0px");
			
			if((height+2)%gridHeight != 0 && !inColumn($(this)))
			{
				$copy.css("height", (gridHeight*3)-2);
			}
				
			$copy.children(".evnt-time").show();
			
			if(inColumn($(this)))
			{
				$(this).css("opacity", 0);
			}
				
			return $copy;
		},
		start: function(event, ui)
		{
			
			$(ui.helper).children(".sch-cat-icon").css('display','none');
			var height = parseFloat($(this).css("height"));
			if((height+2)%gridHeight != 0)
				$(ui.helper).css("height", (gridHeight*3)-2);
			$(ui.helper).children(".evnt-time").show();
			
			
			if(ctrlPressed && $(this).parent().attr("id") != "sch-tiles")
			{
				var clone = $(ui.helper).clone();;
				$(this).parent().append(clone);
				clone.removeClass("ui-draggable ui-draggable-handle ui-resizable ui-draggable-dragging");  
				clone.css("opacity","1");
				clone.css("z-index","0");
				clone.children('.ui-resizable-handle').remove();
				
				
				
				addDrag(clone);
				$(clone).resizable({
			    	handles: 'n, s',
			    	grid: [ 0, gridHeight ],
			    	containment: "parent",
			    	resize: function(event, ui)
			    	{
			    		updateTime($(this), ui);
			    	}
				});
				
				pushEventInfo(clone,$(this).attr("id"));
			}
			else if(!ctrlPressed && $(this).parent().attr("id") == "sch-tiles") 
			{
				catBefore = $(this).children(".evnt-title").html();
				console.log($(this).innerHTML);
				newSchItem = true;
			}
			
		},
		stop: function(event, ui) 
		{
			//$(ui.draggable).css("background","green");
			$(ui.helper).remove();
			
			$(this).children(".sch-cat-icon").css('display','none');
			var height = parseFloat($(this).css("height"));
			if((height+2)%gridHeight != 0)
				$(this).css("height", (gridHeight*3)-2);
			$(this).children(".evnt-time").show();
			
			if($(this).css("opacity") == 1) //if opacity is zero, this thing was already in the schedule
			{
				$(this).children(".evnt-title").trigger('focus'); 
				document.execCommand('selectAll',false,null); // Suggests to the user to change the schedule item title by making it editable upon drop here.
				document.execCommand('delete',false,null); // Suggests to the user to change the schedule item title by making it editable upon drop here.
				$(this).children(".evnt-title").trigger('focus');
			}
			
			$("#sch-tiles").html(sideHTML); //reset the sidebar
			$(this).css("opacity", 1);
			
			$(".evnt-title").on("keydown",function(e){
			    var key = e.keyCode || e.charCode;  // ie||others
			    if(key == 13)  // if enter key is pressed
			    {
					e.preventDefault();
				    $(this).blur();  // lose focus	
			    }
			});
			
			$("#sch-tiles .evnt-desc").tooltip({
				position: { my: "left+15 top", at: "left bottom"}
			}); //toss a tooltip on the events text
			
			if(inColumn($(this)))
			{
				$(this).css('position', 'absolute');
				$(this).css('top', ui.position.top - $(this).parent().offset().top);
				console.log($(this).parent().position().top);
			}
			addDrag();
			$(this).css("margin-top","0px");
			
			var topVal = parseFloat($(this).css("top"));
			if(topVal < 0) //make sure the event is not halfway off the top
			{
				topVal = 0;
			}
			else if(topVal > $(this).parent().height() - $(this).outerHeight()) //or bottom
			{
				topVal = $(this).parent().height() - $(this).outerHeight();
				topVal = topVal - (topVal%gridHeight);
			}
			$(this).css("top",topVal);
			
			if ($(this).parent().offset()) {
				
				$(this).attr("id",catBefore);
				pushEventInfo(this,catBefore);
				
			}
		},
		drag: function(event, ui)
		{
			updateTime($(this), ui);
		}
	});
}

function pushEventInfo(elem, catBefore) {
	
	// For some reason, these two lines are still important for cloned events.
	// It's never great if you have to start your comment with "For some reason"...isn't it?
	curEvnt = curEvent + 1; // Increments current event ID.
	$(elem).children(".evnt-numID").html == curEvnt.toString();
	
	// Start pushing to temporary data...starting with category we get from the passed in catBefore parameter.
	schItemCategory.push(catBefore);
	schItemColor.push($(elem).css("background-color"));
	schItemStart.push($(elem).children(".evnt-time").html());
	schItemNames.push($(elem).children(".evnt-title").text());
	schItemDate.push($(elem).parent().siblings(".col-titler").children(".evnt-fulldate").html().split(',')[0]);
	
	// Whereas the other lines actually split up the data (particularly useful later with POST requests),
	// the following line pushes the entire HTML content of the schedule item.
	// It's actually not too much, so it should not cause much drain here.
	schItem.push(elem);
	
}

function updateTime(elem, ui, resize) //if we're resizing, don't change the position
{
	var timeDiv = ui.helper.children(".evnt-time");
	var arr = timeDiv.html().split(":");

	//custom grid stuff using drag
	var offsetDiff = -Math.ceil($(".col-snap:first").offset().top);
	if(resize)
		offsetDiff = 0;
	console.log("Offset difference: " + offsetDiff);
	
	var topRemainder = (ui.position.top + offsetDiff) % gridHeight;
	if($(elem).draggable('option', 'gridOn'))
	{
		if(!resize)
			ui.position.top = ui.position.top - topRemainder;
		arr[0] = (ui.position.top + offsetDiff)/gridHeight;
	}

	timeDiv.html(arr.join(":"));
	$(elem).children(".evnt-time").html(arr.join(":"));
}

function addDates(referenceDate, refresh)
{
	var currDate = referenceDate;
	var day = currDate.getDay();
	var date = currDate.getDate();
	var month = currDate.getMonth();
	var year = currDate.getFullYear();
	var dayOffset = day - 1;
	var startDate;
	var lastCurrMonth = new Date(year, month + 1, 0);
	var lastPrevMonth = new Date(year, month, 0);
	var lastDateCurr = lastCurrMonth.getDate();
	var lastDatePrev = lastPrevMonth.getDate();
	var lastMonth = false;
	var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
	"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
	var todayDate = new Date();
	
	
	refDate = currDate;
	lastReportedDate = date;
	lastReportedMonth = month;
	
	if(refresh)
	{
		$("#sch-days").html(schHTML); // Refresh the layout so that we can properly prepend and append text below here
		colDroppable();
	}
	
	if(day == 0)
		startDate = date - 6;
	else
		startDate = date - dayOffset;
	
	if(startDate <= 0) //if the start is in the last month
	{
		startDate = lastDatePrev + startDate;
		lastMonth = true;
		lastReportedMonth = month - 1;
	}
	
	$(".sch-day-col").each(function(index, col)
	{
		if((startDate == date) && (referenceDate.toDateString() == todayDate.toDateString())) //if this is the same day of week, and is the correct week (is it today?)
		{
			$(col).attr("id","sch-col-today");	
		}
		if(startDate <= lastDateCurr+1)
		{
			$(col).children(".col-titler").prepend("<div class='evnt-date'>" + startDate + "</div> ");
			if(lastMonth && ((month-1)>-1))
				$(col).children(".col-titler").append("<br><div class='evnt-fulldate'>" + monthNames[month-1] + " " + startDate + ", " + year + "</div>");
			else if (lastMonth &&((month-1)==-1))
				$(col).children(".col-titler").append("<br><div class='evnt-fulldate'>" + monthNames[11] + " " + startDate + ", " + (year-1) + "</div>");
			else
				$(col).children(".col-titler").append("<br><div class='evnt-fulldate'>" + monthNames[month] + " " + startDate + ", " + year + "</div>");
				
			if((startDate == lastDateCurr && !lastMonth) || (startDate == lastDatePrev && lastMonth)) //if this is the last day in the month, reset the count
			{
				startDate = 0;
				month++;
			}
		}
		startDate++;
	});
	
	popEvents(); // After refreshing the dates, populate the...er...schedule items for this week. As you can see, the terminology still confuses some.
	
}

function popEvents() {
	var repDates = [];
	
	$(".sch-day-col").each(function(index, col)
	{
		repDates.push($(col).children(".col-titler").children(".evnt-fulldate").html().split(',')[0]);
	}); // Populate the date range array created above, so that we can match up what events have dates that fall in this range.
	
	for (var i = 0; i < repDates.length; i++) {
		for (var j = 0; j < schItemCategory.length; j++) {
			if (schItemDate[j] == repDates[i]) {
				console.log(schItemDate[j] + " | " + repDates[i]);
			
			// So, this does not create a clone using the .clone() method...it was attempted before, though (the result was not optimal).
			var currentElem = schItem[j];
			$(".sch-day-col:eq(" + i + ")").append(currentElem);
			$(".sch-evnt").css("margin-left","auto");
			$(".sch-evnt").css("margin-right","auto");
			$(".sch-evnt").css("left","0");
			$(".sch-evnt").css("right","0");
			updateTime($(".sch-evnt"),$(".sch-day-col"));
			addDrag(".sch-evnt"); // Re-enables the events to snap onto the date columns here.	
			}
		}
	}
}

function createCategory() {
	window.location.href = './schedule?new=t&name=Untitled';
	//window.location.href = './schedule';
}

function editCategory(event, elem, id, name, col){
	if($(elem).siblings(".futureColors").children().length == 0) //only add swatches if there are none
	{
		event.stopImmediatePropagation();
		$(elem).siblings(".sch-evnt-editCat").css("display","none");
		$(elem).siblings(".sch-evnt-saveCat").css("display","inline");
		$(elem).siblings(".catOverlayTitle").trigger('focus');
		document.execCommand('selectAll',false,null);
		$(".futureColors").append("<div class='color-swatch' style='background-color: red;' onclick='changeCategoryColor(event,this,\"Red\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:orange;' onclick='changeCategoryColor(event,this,\"Orange\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:yellow;' onclick='changeCategoryColor(event,this,\"Yellow\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:green;' onclick='changeCategoryColor(event,this,\"Green\")'></div><br/>");
		$(".futureColors").append("<div class='color-swatch' style='background-color:blue;' onclick='changeCategoryColor(event,this,\"Blue\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:indigo;' onclick='changeCategoryColor(event,this,\"Indigo\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:violet;' onclick='changeCategoryColor(event,this,\"Violet\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:silver;' onclick='changeCategoryColor(event,this,\"Silver\")'></div>");
		
		var nameR = name;
		
		$(".ui-widget-overlay").show();
		$(".cat-overlay-box").css("display","block");
		$(".catTopOverlay").css("background-color",col)
		//$(".cat-overlay-box").css("border","solid 2px " + col)
		//$(".cat-overlay-box").css("box-shadow","0px 0px 16px " + col)
		$(".catOverlayTitle").html(nameR);
		$(".cat-overlay-box").attr("data-id",id);
		
	}
}

function changeCategoryColor(event,elem,col) {
	$(".catTopOverlay").css("background-color",col);
}

function saveCategory(event,elem,id) {
	window.location.href = './schedule?edit=t&id=' + id + '&name=' + $(".catOverlayTitle").html() + '&col=' + $(".catTopOverlay").css("background-color");
}

function delCategory(event, elem, id)
{
	/*event.stopImmediatePropagation();
	$(elem).parent().slideUp("normal", function() { $(this).remove(); } );*/
	window.location.href = './schedule?dest=t&id=' + id;
	//window.location.href = './schedule';
}

function removeEvent(event, elem)
{
	event.stopImmediatePropagation();
	$(elem).parent().slideUp("normal", function() { $(this).remove(); } );
	
	var current = ($(elem).siblings(".evnt-numID").html());
	
	schItemCategory[current] = "";
	schItemColor[current] = "";
	schItemStart[current] = "";
	schItemNames[current] = "";
	schItemDate[current] = "";
	
}

function editEvent(event, elem)
{
	event.stopImmediatePropagation();
	$(elem).siblings(".evnt-title").trigger('focus');
	document.execCommand('selectAll',false,null);
	$(elem).siblings(".sch-evnt-save").css("display","inline");
	
}

function showOverlay(elem)
{
	if(inColumn(elem))
	{
		$(".ui-widget-overlay").show();
		$(".overlay-box").show();
		var title = $(elem).children(".evnt-title").html();
		var desc = $(elem).children(".evnt-desc").html();
		var time = $(elem).children(".evnt-time").html();
		var arr = time.split(":");
		arr[0] = parseInt(arr[0])+$(elem).outerHeight()/gridHeight;
		var endTime = arr.join(":");
		$(".overlay-title").html(title);
		$(".overlay-desc").html(desc);
		$(".overlay-time").html(time + " - " + endTime);
	}
}

function hideOverlay()
{
	$(".ui-widget-overlay").hide();
	$(".overlay-box").hide();
	$(".cat-overlay-box").css("display","none");
}

function setTitles()
{
	$(".evnt-desc").each(function(index, desc)
	{
		$(desc).attr("title", $(desc).text());
	});
}

//returns whether the element is in a schedule element
function inColumn(elem)
{
	var class_data = elem.parent().attr("class");
	if(class_data && class_data.indexOf("col-snap evt-snap") > -1)
		return true;
	else
		return false;
}