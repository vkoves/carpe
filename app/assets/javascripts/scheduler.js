var sideHTML; // Instantiates sideHTML variable
var gridHeight = 25; //the height of the grid of resizing and dragging
var border = 2; //the border at the bottom for height stuff
var ctrlPressed = false;
var schHTML; // Instantiates schedule HTML variable, which will contain the "Mon-Sun" html on the main scheduler div.
var refDate = new Date(); // Reference date for where the calendar is now, so that it can switch between weeks.

var currEventsMap = {};
var eventTempId = 0; //the temp id

var currEvent; //the event being currently edited

var readied = false;

//Three letter month abbreviations
var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

//Run schedule ready when the page is loaded. Either fresh or from turbo links
$(document).ready(scheduleReady);
$(document).on('page:load', scheduleReady);

function scheduleReady()
{
	if(!readied)
	{
		//Load in events
		if (typeof eventsLoaded !== 'undefined') //if eventsLoaded is defined
		{
			for(var i = 0; i < eventsLoaded.length; i++) //loop through it
			{
				var evnt = eventsLoaded[i]; //fetch the event at the current index
				var catParent = $("#sch-tiles .sch-evnt[data-id='" + evnt["category_id"] + "']"); //fetch the category
				var clone = catParent.clone();
				console.log(eventsLoaded[i].date);
				var dateE = new Date(eventsLoaded[i].date);
				var dateEnd = new Date(eventsLoaded[i].end_date);
				
				clone.children(".evnt-title").text(eventsLoaded[i].name); 
				clone.children(".evnt-time").text(dateE.getHours() + ":" + dateE.getMinutes()).show();
				clone.attr("event-id", eventsLoaded[i].id);
				clone.attr("evnt-temp-id", i); //Set the temp id
				clone.attr("rep-type", eventsLoaded[i].repeat);
				
				console.log("Event loading...");
				pushEventInfo(clone, catParent.attr("data-id"), i);
				
				currEventsMap[i].enddatetime = eventsLoaded[i].end_date;
				var dateString = monthNames[dateE.getMonth()] + " " + dateE.getDate() + ", " + dateE.getFullYear();
				currEventsMap[i].date = dateString;
				currEventsMap[i].datetime = eventsLoaded[i].date;
				placeInSchedule(clone, dateE.getHours(), dateEnd.getHours() - dateE.getHours());
				
				//increment the temp id
				eventTempId++;
			}
			
			console.log("Events loaded!");
		}
		
		console.log("Readying schedule");
		setTitles();
		
		sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops
		schHTML = $("#sch-days").html(); //The HTML for the scheduler days layout, useful for when days are refreshed
		
		//toss a tooltip on the sidebar, explaining how stuff works
		$("#sidebar-title").tooltip({
			position: { my: "left top", at: "left bottom"}	
		});
		
		//When editing category title, defocus on enter
		$(".catOverlayTitle").on("keydown",function(e){
		    var key = e.keyCode || e.charCode;  // ie||others
		    if(key == 13)  // if enter key is pressed
		    {
				e.preventDefault();
			    $(this).blur();  // lose focus	
		    }
		});
		
		$(".repeat-option").click(function()
		{
			$(".repeat-option").removeClass("red");
			$(this).addClass("red");

			var repType = $(this).text().toLowerCase();
			currEvent.attr("rep-type", repType); //set the repeat type attribute
			
			
			var eventObj = currEventsMap[currEvent.attr("evnt-temp-id")];
			eventObj.repeat = repType;
			currEventsMap[currEvent.attr("evnt-temp-id")] = eventObj;
			console.log("Repeat type updated");
			console.log(currEventsMap);
		});
		
		addDrag(); //add dragging, recursively
		
		colDroppable();
		
		addDates(new Date(), false);
		readied = true;
		console.log("Schedule ready!");
	}
}

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
		    	},
		    	stop: function(event, ui)
		    	{	
		    		console.log("Ui Draggable resize stop");
					pushEventInfo($(this),$(this).attr("id"), $(this).attr("evnt-temp-id"));	
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
	if(typeof readOnly !== 'undefined' && readOnly)
		return;
		
	var newSchItem = false;
	var catBefore = "";
	
	if (selector == null)
		selector = "#sch-sidebar .sch-evnt";
	
	$(selector).find(".evnt-title").on("keydown",function(e){
	    var key = e.keyCode || e.charCode;  // ie||others
	    if(key == 13)  // if enter key is pressed
	    {
			e.preventDefault();
		    $(this).blur();  // lose focus
		    console.log("Keydown");
		    pushEventInfo($(this).parent(),catBefore, $(this).parent().attr("evnt-temp-id")); //and save again
	    }
	})
	.focusout(function() { //so that clicking outside an event title also saves
		pushEventInfo($(this).parent(),catBefore, $(this).parent().attr("evnt-temp-id")); //save event
	});
	
	
		
	$(selector).mousedown(function(event) {
	if(event.ctrlKey)
		ctrlPressed = true;
	else
		ctrlPressed = false;
	});
		
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
				var clone = $(ui.helper).clone();
				$(this).parent().append(clone);
				clone.removeClass("ui-draggable ui-draggable-handle ui-resizable ui-draggable-dragging");  
				clone.css("opacity","1");
				clone.css("z-index","0");
				clone.children('.ui-resizable-handle').remove();
				
				//clear event id
				$(this).removeAttr("event-id");

				//the clone needs a new temp id, but in reality, this is the clone
				$(this).attr("evnt-temp-id", eventTempId);
				eventTempId++;
				
				pushEventInfo($(this),$(this).attr("id"), $(this).attr("evnt-temp-id"));
				pushEventInfo(clone,$(this).attr("id"), $(clone).attr("evnt-temp-id"));
				
				addDrag(clone);				
				
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
			
			if($(this).css("opacity") == 1) //if opacity is 1, this is a new event
			{
				$(this).children(".evnt-title").attr("contenteditable", "true");
				$(this).children(".evnt-title").trigger('focus'); 
				document.execCommand('selectAll',false,null); // Suggests to the user to change the schedule item title by making it editable upon drop here.
				document.execCommand('delete',false,null); // Suggests to the user to change the schedule item title by making it editable upon drop here.
				$(this).attr("evnt-temp-id", eventTempId);
				eventTempId++;
			}
			
			$("#sch-tiles").html(sideHTML); //reset the sidebar
			$(this).css("opacity", 1);
			
			if(inColumn($(this)))
			{
				$(this).css('position', 'absolute');
				$(this).css('top', ui.position.top - $(this).parent().offset().top);
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
			
			if ($(this).parent().offset()) 
			{
				$(this).attr("id",catBefore);
				pushEventInfo(this,catBefore, $(this).attr("evnt-temp-id"));
			}
		},
		drag: function(event, ui)
		{
			updateTime($(this), ui);
		}
	});
	
	if(selector != "#sch-sidebar .sch-evnt")
	{
		$(selector).resizable({
	    	handles: 'n, s',
	    	grid: [ 0, gridHeight ],
	    	containment: "parent",
	    	resize: function(event, ui)
	    	{
	    		updateTime($(this), ui, true);
	    	},
	    	stop: function(event, ui)
	    	{	
				pushEventInfo($(this),$(this).attr("id"), $(this).attr("evnt-temp-id"));	
	    	}
		});
	}
}

function updateTime(elem, ui, resize) //if we're resizing, don't change the position
{
	var timeDiv = ui.helper.children(".evnt-time");
	var arr = timeDiv.html().split(":");

	//custom grid stuff using drag
	var offsetDiff = -Math.ceil($(".col-snap:first").offset().top);
	if(resize)
		offsetDiff = 0;
		
	//console.log("Offset difference: " + offsetDiff);
	
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

//called by next and previous buttons on click
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
	var todayDate = new Date();
	
	
	refDate = currDate;
	lastReportedDate = date;
	lastReportedMonth = month;
	
	if(refresh)
	{
		console.log("REFRESHING!");
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
				if (month == 12) {
					year++;
					month = 0;
				}
			}
		}
		startDate++;
	});
	
	popEvents(); // After refreshing the dates, populate the...er...schedule items for this week. As you can see, the terminology still confuses some.
}

function popEvents()
{
	console.log(currEventsMap);
	
	var repDates = [];
	
	$(".sch-day-col").each(function(index, col)
	{
		repDates.push($(col).children(".col-titler").children(".evnt-fulldate").html());
	}); // Populate the date range array created above, so that we can match up what events have dates that fall in this range.
	
	//console.log(schItem);


	for (var i = 0; i < repDates.length; i++)
	{
		for (var eventIndex in currEventsMap) //do a foreach since this is a hashmap
		{
			eventObj = currEventsMap[eventIndex];
			if (eventObj.date == repDates[i]) 
			{
				// So, this does not create a clone using the .clone() method...it was attempted before, though (the result was not optimal).
				var currentElem = eventObj.element;
				$(".sch-day-col:eq(" + i + ") .col-snap").append(currentElem);
				$(".sch-evnt").css("margin-left","auto");
				$(".sch-evnt").css("margin-right","auto");
				$(".sch-evnt").css("left","0");
				$(".sch-evnt").css("right","0");
				//updateTime($(".sch-evnt"),$(".sch-day-col"));
			}
		}
	}
	addDrag(".col-snap .sch-evnt"); // Re-enables the events to snap onto the date columns here.	
}

function removeEvent(event, elem)
{
	event.stopImmediatePropagation();
	$(elem).parent().slideUp("normal", function() { $(this).remove(); } );
	
	var eId = $(elem).parent().attr("event-id");
	var tempId = $(elem).parent().attr("evnt-temp-id");
	
	//remove map
	delete currEventsMap[tempId];
	
	if(!eId)
	{
		return;
	}
	
	$.ajax({
	    url: "/delete_event",
	    type: "POST",
	    data: {id: eId},
	    success: function(resp)
	    { 
	    	console.log("Resp: \"" + resp + "\"");
	    	console.log("Delete complete.");
	    },
	    error: function(resp)
	    {
	    	alert("Deleting event failed :/");
	    }
	});	
}

function editEvent(event, elem)
{
	$(elem).siblings(".evnt-title").attr("contenteditable", "true");
	event.stopImmediatePropagation();
	$(elem).siblings(".evnt-title").trigger('focus');
	document.execCommand('selectAll',false,null);
	$(elem).siblings(".sch-evnt-save").css("display","inline");
}

function pushEventInfo(elem, catBefore, eId)
{
	var dateE = $(elem).parent().siblings(".col-titler").children(".evnt-fulldate").html();
	var nameE = $(elem).children(".evnt-title").text();
	var startTime = $(elem).children(".evnt-time").html() + "";
	var endTime = parseInt(startTime.split(":")[0]) + Math.round($(elem).height()/gridHeight) + ":" + startTime.split(":")[1]; 
	
	var eventId = $(elem).attr("event-id");
	
	var repeatType = $(elem).attr("rep-type");
	
	var dateTime;
	var endDateTime = "";
	
	try
	{
		dateTime = new Date(dateE+" "+startTime).toISOString();
	}
	catch(err)
	{
		dateTime = "";
		console.log("Creating start date failed!");
	}
	try
	{
		endDateTime = new Date(dateE+" "+endTime).toISOString();
	}
	catch(err)
	{
		endDateTime = "";
		console.log("Creating end date failed!");
	}
	
	console.log("Start: " + dateTime + " end: " + endDateTime);
	
	var catId = $(elem).attr("data-id");	
	var event_obj = {element: elem, repeat: repeatType, date: dateE, datetime: dateTime, enddatetime: endDateTime, 
		name: nameE, cat_id: catId, event_id: eventId};
	currEventsMap[eId] = event_obj;
	console.log(currEventsMap);
}

function saveEvents()
{
	//JSON encode our hashmap
	var arr  = JSON.parse(JSON.stringify(currEventsMap));
	$.ajax({
	    url: "/save_events",
	    type: "POST",
	    data: {map: arr, text: "testificates"},
	    success: function(resp)
	    { 
	    	console.log("Resp: \"" + resp + "\"");
	    	console.log("Save complete.");
	    },
	    error: function(resp)
	    {
	    	alert("Saving events failed :(");
	    }
	});
}

function createCategory()
{
	window.location.href = './schedule?new=t&name=Untitled';
}

function editCategory(event, elem, id, name, col)
{
	event.stopImmediatePropagation();
	$(elem).siblings(".sch-evnt-editCat").css("display","none");
	$(elem).siblings(".sch-evnt-saveCat").css("display","inline");
	$(elem).siblings(".catOverlayTitle").trigger('focus');
	document.execCommand('selectAll',false,null);
	if($(".futureColors").children().length == 0) //only add swatches if there are none
	{
		$(".futureColors").append("<div class='color-swatch' style='background-color: red;' onclick='changeCategoryColor(event,this,\"Red\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:orange;' onclick='changeCategoryColor(event,this,\"Orange\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:yellow;' onclick='changeCategoryColor(event,this,\"Yellow\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:green;' onclick='changeCategoryColor(event,this,\"Green\")'></div><br/>");
		$(".futureColors").append("<div class='color-swatch' style='background-color:blue;' onclick='changeCategoryColor(event,this,\"Blue\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:indigo;' onclick='changeCategoryColor(event,this,\"Indigo\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:violet;' onclick='changeCategoryColor(event,this,\"Violet\")'></div> ");
		$(".futureColors").append("<div class='color-swatch' style='background-color:silver;' onclick='changeCategoryColor(event,this,\"Silver\")'></div>");
	}
	var nameR = name;
	
	$(".ui-widget-overlay").show();
	$(".cat-overlay-box").css("display","block");
	$(".catTopOverlay").css("background-color",col);
	//$(".cat-overlay-box").css("border","solid 2px " + col)
	//$(".cat-overlay-box").css("box-shadow","0px 0px 16px " + col)
	$(".catOverlayTitle").html(nameR);
	$(".cat-overlay-box").attr("data-id",id);
}

function changeCategoryColor(event,elem,col)
{
	$(".catTopOverlay").css("background-color",col);
}

function saveCategory(event,elem,id)
{
	window.location.href = './schedule?edit=t&id=' + id + '&name=' + $(".catOverlayTitle").html() + '&col=' + $(".catTopOverlay").css("background-color");
}

function delCategory(event, elem, id)
{
	window.location.href = './schedule?dest=t&id=' + id;
}


function showOverlay(elem)
{
	var editingEvent = $(document.activeElement).hasClass("evnt-title");
	
	if(inColumn(elem) && !editingEvent)
	{
		currEvent = elem; //Set the current event to the event being edited
		
		
		$(".repeat-option").removeClass("red");
		if($(elem).attr("rep-type"))
		{
			$("#repeat-" + $(elem).attr("rep-type")).addClass("red");
		}
		
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
	$("#repeat-menu").hide();
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

//Setup properties of a place schedule item from the db, setting position and height
function placeInSchedule(elem, hours, lengthHours)
{
	$(elem).children(".sch-cat-icon").css('display','none');
	var height = lengthHours*gridHeight;
	if((height+2)%gridHeight != 0)
		$(elem).css("height", (gridHeight*lengthHours)-2);
	$(elem).children(".evnt-time").show();
	
	$(elem).css('position', 'absolute');
	$(elem).css("margin-top","0px");
	
	var topVal = gridHeight*hours;
	$(elem).css("top",topVal);
}
