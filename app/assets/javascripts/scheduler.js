var sideHTML; // Instantiates sideHTML variable
var schHTML; // Instantiates schedule HTML variable, which will contain the "Mon-Sun" html on the main scheduler div.

var gridHeight = 25; //the height of the grid of resizing and dragging
var border = 2; //the border at the bottom for height stuff
var ctrlPressed = false;
var refDate = new Date(); // Reference date for where the calendar is now, so that it can switch between weeks.

var currEventsMap = {}; //map of all the events in the frontend
var eventTempId = 0; //the temp id

var currEvent; //the event being currently edited
var currCategory; //the category being currently edited

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
				var dateE = new Date(eventsLoaded[i].date);
				var dateEnd = new Date(eventsLoaded[i].end_date);
				
				clone.children(".evnt-title").text(eventsLoaded[i].name);
				var time = dateE.getHours() + ":" + dateE.getMinutes(); 
				clone.children(".evnt-time").text(convertTo12Hour([dateE.getHours(), dateE.getMinutes()])).show();
				clone.attr("time", time);
				clone.attr("event-id", eventsLoaded[i].id);
				clone.attr("evnt-temp-id", i); //Set the temp id
				clone.attr("rep-type", eventsLoaded[i].repeat);
				
				pushEventInfo(clone, true);
				
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
			//highlight the newly selected option
			$(".repeat-option").removeClass("red");
			$(this).addClass("red");

			//get the text of the button
			var repType = $(this).text().toLowerCase();
			currEvent.attr("rep-type", repType); //and set the repeat type attribute
			
			//then update the repeat type without going through push event info
			currEventsMap[currEvent.attr("evnt-temp-id")].repeat = repType;
			console.log("Repeat type updated");
			console.log(currEventsMap);
			
			//remove all of this element
			$(".sch-evnt[evnt-temp-id='" + currEvent.attr("evnt-temp-id") + "']").remove();
			populateEvents();
		});
		
		$("#cat-privacy span").click(function()
		{
			//highlight the newly recent option
			$("#cat-privacy span").removeClass("red");
			$(this).addClass("red");
			
			currCategory.attr("privacy", $(this).text().toLowerCase());
		});
		
		addDrag(); //add dragging, recursively
		
		colDroppable();
		
		addDates(new Date(), false);
		readied = true;
		console.log("Schedule ready!");
	}
}

//Add droppable onto columns
function colDroppable()
{
	//make the columns droppable
	$(".col-snap").droppable(
	{
		drop: function( event, ui ) //called when event is dropped on a new column (not called on moving it in the column)
		{
	    	var element = ui.draggable.detach();
			$(this).append(element); //append to the column
			$(this).parent().removeClass("over"); //dehighlight on drop
		},
		over: function( event, ui )
		{
			$(this).parent().addClass("over"); //highlight
			$(ui.draggable).draggable("option","gridOn", true); //and enable vertical grid
		},
		out: function( event, ui )
		{
			$(this).parent().removeClass("over"); //unhighlight
			$(ui.draggable).draggable("option","gridOn", false); //and disable grid
		}
	});
}

//the dragging function
function addDrag(selector)
{
	if(typeof readOnly !== 'undefined' && readOnly) //don't add drag if this is read only
		return;
		
	if (selector == null)
		selector = "#sch-sidebar .sch-evnt";
	
	$(selector).find(".evnt-title").on("keydown",function(e){
	    var key = e.keyCode || e.charCode;  // ie||others
	    if(key == 13)  // if enter key is pressed
	    {
			e.preventDefault();
			$(this).parent().draggable("enable");
		    $(this).blur();  // lose focus
		    console.log("Keydown");
		    pushEventInfo($(this).parent()); //and save again
	    }
	})
	.focusout(function() { //so that clicking outside an event title also saves
		$(this).parent().draggable("enable");
		pushEventInfo($(this).parent()); //save event
	});
	
	//when the mouse is pressed on the events, check for control	
	$(selector).mousedown(function(event)
	{
		if(event.ctrlKey)
			ctrlPressed = true;
		else
			ctrlPressed = false;
	});
		
	$(selector).draggable(
	{
		containment: "window",
		snap: ".evt-snap",
		snapMode: "inner",
		appendTo: "body",
		cancel: "img",
		revertDuration: 0,
		opacity: 0.7,
		distance: 10,
		gridOn: false,
		scroll: false,
		revert: "invalid",
		helper: function()
		{
			$copy = $(this).clone();
			
			if(inColumn($(this))) //if this is a current element				$(this).css("opacity", 0); //hide the original while we are moving the helper
				
			return $copy;
		},
		start: function(event, ui)
		{
			var height = parseFloat($(this).css("height"));
			if((height+border)%gridHeight != 0)
				$(ui.helper).css("height", (gridHeight*3)-border);
			
			if(ctrlPressed && $(this).parent().attr("id") != "sch-tiles-inside") //if this is an existing event and control is pressed
			{
				var clone = $(ui.helper).clone(); //create a clone
				$(this).parent().append(clone);
				clone.css("opacity","1"); //set the clone to be fully opaque, as it'll be 0.7 opacity by default from dragging
				
				$(this).removeAttr("event-id"); //clear event id

				$(this).attr("evnt-temp-id", eventTempId); //the clone needs a new temp id, but in reality, this is the clone
				eventTempId++;
				
				pushEventInfo($(this));
				pushEventInfo(clone);
				
				clone.removeClass("ui-draggable ui-draggable-handle ui-resizable ui-draggable-dragging"); //remove dragging stuff
				addDrag(clone); //and redo draggin
			}
		},
		stop: function(event, ui)  //on drag end
		{
			var height = parseFloat($(this).css("height"));
			if((height+border)%gridHeight != 0)
				$(this).css("height", (gridHeight*3)-border);
				
			if($(this).css("opacity") == 1) //if opacity is 1, this is a new event
			{
				$(this).children(".evnt-title").attr("contenteditable", "true");
				$(this).children(".evnt-title").trigger('focus'); 
				document.execCommand('selectAll',false,null); // Suggests to the user to change the schedule item title by making it editable upon drop here.
				document.execCommand('delete',false,null); // Suggests to the user to change the schedule item title by making it editable upon drop here.
				$(this).attr("evnt-temp-id", eventTempId);
				eventTempId++;
				addResizing($(this)); //since the sidebar events don't have resizing, we have to add it on stop
			}
			
			$("#sch-tiles").html(sideHTML); //reset the sidebar
			$(this).css("opacity", 1);
			
			if(inColumn($(this)))
			{
				$(this).css('top', ui.position.top - $(this).parent().offset().top);
			}
			addDrag();
			
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
			updateTime(this, ui);
			
			if ($(this).parent().offset()) 
			{
				pushEventInfo($(this));
			}
		},
		drag: function(event, ui)
		{
			updateTime($(this), ui);
		}
	});
	
	addResizing(selector);
}

//add resizing for schedule events that are new
function addResizing(selector)
{
	if(selector != "#sch-sidebar .sch-evnt") //as long as the selector is not for the sidebar
	{
		$(selector).resizable( //make the items resizable
		{
	    	handles: 'n, s',
	    	grid: [ 0, gridHeight ],
	    	containment: "parent",
	    	resize: function(event, ui)
	    	{
	    		updateTime($(this), ui, true);
	    		console.log("Resize");
	    	},
	    	stop: function(event, ui)
	    	{	
				pushEventInfo($(this));
	    	}
		});
	}
}

//Change time while items are being dragged or resized, and also snap to a vertical grid
function updateTime(elem, ui, resize) //if we're resizing, don't snap, just update time
{
	var arr = ui.helper.attr("time").split(":");
	
	//Take care of grid snapping
	if($(elem).draggable('option', 'gridOn') || resize) //only update time if we are snapping in a column or are resizing
	{
		var offsetDiff = -Math.ceil($(".col-snap:first").offset().top);
		if(resize)
			offsetDiff = 0;
		
		if(!resize)
		{
			var topRemainder = (ui.position.top + offsetDiff) % gridHeight;
			ui.position.top = ui.position.top - topRemainder;
		}
		arr[0] = (ui.position.top + offsetDiff)/gridHeight;
	}
		
	$(elem).attr("time", arr.join(":")); //set the time attr using military
	arr = convertTo12Hour(arr); //then convert to 12 hour
	ui.helper.children(".evnt-time").html(arr); //and set the helper time
	$(elem).children(".evnt-time").html(arr); //as well as the element
}


//called by next and previous buttons on click
function addDates(currDate, refresh)
{
	var day = currDate.getDay();
	var date = currDate.getDate();
	var month = currDate.getMonth();
	var year = currDate.getFullYear();
	var startDate;
	var lastCurrMonth = new Date(year, month + 1, 0);
	var lastPrevMonth = new Date(year, month, 0);
	var lastDateCurr = lastCurrMonth.getDate();
	var lastDatePrev = lastPrevMonth.getDate();
	var lastMonth = false;
	var todayDate = new Date();
	
	
	refDate = currDate;
	
	if(refresh)
	{
		console.log("REFRESHING!");
		$("#sch-days").html(schHTML); // Refresh the layout so that we can properly prepend and append text below here
		colDroppable();
	}
	
	if(day == 0)
		startDate = date - 6;
	else
		startDate = date - day - 1;
	
	if(startDate <= 0) //if the start is in the last month
	{
		startDate = lastDatePrev + startDate;
		lastMonth = true;
	}
	
	$(".sch-day-col").each(function(index, col)
	{
		if((startDate == date) && (currDate.toDateString() == todayDate.toDateString())) //if this is the same day of week, and is the correct week (is it today?)
		{
			$(col).attr("id","sch-col-today");	
		}
		if(startDate <= lastDateCurr+1)
		{
			var fullDate = "";
			
			if(lastMonth && ((month-1)>-1))
				fullDate = monthNames[month-1] + " " + startDate + ", " + year;
			else if (lastMonth &&((month-1)==-1))
				fullDate = monthNames[11] + " " + startDate + ", " + (year-1);
			else
				fullDate = monthNames[month] + " " + startDate + ", " + year;
			
			$(col).children(".col-titler").prepend("<div class='evnt-date'>" + startDate + "</div> "); //prepend the numeric date (e.g. 25)
			$(col).children(".col-titler").append("<div class='evnt-fulldate'>" + fullDate + "</div>"); //append the long form date to columns
				
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
	
	populateEvents(); // After refreshing the dates, populate the...er...schedule items for this week. As you can see, the terminology still confuses some.
}

//Populate the events in the current week from the hashmap
function populateEvents()
{
	var currentDates = []; //the dates that are visible in the current week
	
	$(".sch-day-col").each(function(index, col)
	{
		currentDates.push($(col).children(".col-titler").children(".evnt-fulldate").html());
	}); // Populate the date range array created above, so that we can match up what events have dates that fall in this range.
	

	for (var i = 0; i < currentDates.length; i++)
	{
		for (var eventIndex in currEventsMap) //do a foreach since this is a hashmap
		{
			eventObj = currEventsMap[eventIndex];
			var date = new Date(currentDates[i]);
			if (eventObj.date == currentDates[i]
				|| eventObj.repeat == "daily"
				|| (eventObj.repeat == "weekly" && date.getDay() == new Date(eventObj.datetime).getDay()))
			{
				var currentElem = eventObj.element.clone();
				$(".sch-day-col:eq(" + i + ") .col-snap").append(currentElem);
			}
		}
	}
	addDrag(".col-snap .sch-evnt"); // Re-enables the events to snap onto the date columns here.	
}

//Edit an event's text inline (without the overlay)
function editEvent(event, elem)
{
	//return if this is in the sidebar
	if(!inColumn($(elem).parent()) || $(elem).is(":focus"))
		return;
	
	console.log("Editing event");
	$(elem).parent().draggable("disable"); //disable dragging while editing the event text
	
	$(elem).attr("contenteditable", "true");
	event.stopImmediatePropagation();
	$(elem).trigger('focus');
	document.execCommand('selectAll',false,null);
	$(elem).siblings(".sch-evnt-save").css("display","inline");
}

//Push information about the passed event to the hashmap for saving
function pushEventInfo(elem, ignoreDateTime)
{
	var eId = $(elem).attr("evnt-temp-id"); //the temp id used in the hashmap
	var eventId = $(elem).attr("event-id"); //the permanent event id used in the database
	var dateE = $(elem).parent().siblings(".col-titler").children(".evnt-fulldate").html(); //the date the elem is on
	var nameE = $(elem).children(".evnt-title").text(); //the name of the event
	var startTime = $(elem).attr("time"); //the starting time of the event
	var endTime = parseInt(startTime.split(":")[0]) + Math.round($(elem).height()/gridHeight) + ":" + startTime.split(":")[1];  //the ending time
	var catId = $(elem).attr("data-id"); //the id of the category in the database
	var repeatType = $(elem).attr("rep-type"); //the repeat type of the element
	
	if(!ignoreDateTime) //if the date and time will be set after, don't bother with it
	{
		var dateTime, endDateTime = "";
		
		try
		{
			dateTime = new Date(dateE+" "+startTime).toISOString();
			endDateTime = new Date(dateE+" "+endTime).toISOString();
		}
		catch(err)
		{
			dateTime = "";
			endDateTime = "";
			console.log("Creating datetimes failed!");
		}
		console.log("Start: " + dateTime + " end: " + endDateTime);
	}
	
	var event_obj = {element: elem, repeat: repeatType, date: dateE, datetime: dateTime, enddatetime: endDateTime, 
		name: nameE, cat_id: catId, event_id: eventId};
		
	currEventsMap[eId] = event_obj;
	
	//Find all same elements and apply change
	$(".sch-evnt[evnt-temp-id='" + $(elem).attr("evnt-temp-id") + "']").attr("style", $(elem).attr("style"));
}

//Edit a category using the category overlay
function editCategory(event, elem, id, name, col)
{
	currCategory = $(elem).parent(); //set the current category
	
	//Select the proper privacy button
	$("#cat-privacy span").removeClass("red");
	if(currCategory.attr("privacy"))
	{
		$("#cat-privacy #" + currCategory.attr("privacy")).addClass("red");
	}
	
	event.stopImmediatePropagation();
	$(".catOverlayTitle").trigger('focus');
	document.execCommand('selectAll',false,null);
	
	$(".ui-widget-overlay, .cat-overlay-box").show();

	if(col && col != "null") //check for null string from ruby
		$(".catTopOverlay").css("background-color",col);
	else //if the color was null or empty remove the background-color
		$(".catTopOverlay").css("background-color","");
	
	$(".catOverlayTitle").html($(currCategory).find(".evnt-title").text());
	$(".cat-overlay-box").attr("data-id",id);
}

//show the event editing overlay
function showOverlay(elem)
{
	var editingEvent = $(document.activeElement).hasClass("evnt-title");
	
	if(inColumn(elem) && !editingEvent && !readOnly)
	{
		currEvent = elem; //Set the current event to the event being edited
		
		//Select the proper repeat button
		$(".repeat-option").removeClass("red");
		if($(elem).attr("rep-type"))
		{
			$("#repeat-" + $(elem).attr("rep-type")).addClass("red");
		}
		
		$(".ui-widget-overlay, .overlay-box").show();
		var title = $(elem).children(".evnt-title").html();
		var desc = $(elem).children(".evnt-desc").html();
		var time = $(elem).attr("time");
		var arr = time.split(":");
		arr[0] = parseInt(arr[0])+$(elem).outerHeight()/gridHeight;
		var endTime = arr.join(":");
		$(".overlay-title").html(title);
		$(".overlay-desc").html(desc);

		$(".overlay-time").html(convertTo12Hour(time.split(":")) + " - " + convertTo12Hour(endTime.split(":")));
	}
}

//Hide any type of overlay
function hideOverlay()
{
	//Hide overlay, the repeat menu and category and event overlays
	$(".ui-widget-overlay, #repeat-menu, .overlay-box, .cat-overlay-box").hide();
}

function setTitles()
{
	$(".evnt-desc").each(function(index, desc)
	{
		$(desc).attr("title", $(desc).text());
	});
}

//Update the color of the category overlay from a color being picked
function changeCategoryColor(color)
{
	$(".catTopOverlay").css("background-color",color);
}

//Setup properties of a place schedule item from the db, setting position and height
function placeInSchedule(elem, hours, lengthHours)
{
	var height = lengthHours*gridHeight;
	if((height+border)%gridHeight != 0)
		$(elem).css("height", (gridHeight*lengthHours)-border);

	$(elem).children(".evnt-time").show();
	
	var topVal = gridHeight*hours;
	$(elem).css("top",topVal);
}

/****************************/
/*** JSON SERVER METHODS ****/
/****************************/

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
	    	console.log("Save complete.");
	    },
	    error: function(resp)
	    {
	    	alert("Saving events failed :(");
	    }
	});
}

function removeEvent(event, elem)
{
	event.stopImmediatePropagation();
	$(elem).parent().slideUp("normal", function() { $(this).remove(); } );
	
	var eId = $(elem).parent().attr("event-id");
	var tempId = $(elem).parent().attr("evnt-temp-id");
	
	delete currEventsMap[tempId]; //remove event map
	
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
	    	console.log("Delete complete.");
	    },
	    error: function(resp)
	    {
	    	alert("Deleting event failed :/");
	    }
	});	
}

function createCategory()
{
	$.ajax({
	    url: "/create_category",
	    type: "POST",
	    data: {name: "Untitled", user_id: userId},
	    success: function(resp)
	    { 
	    	console.log("Create category complete.");

	    	var newCat = $("#cat-template").clone();
	    	$("#sch-tiles-inside").append(newCat);
	    	newCat.show();
	    	newCat.attr("data-id", resp.id);
	    	newCat.find(".evnt-title").text(resp.name);
	    	newCat.find(".sch-evnt-editCat").attr("onclick", 'editCategory(event, this, "' + resp.id + '", "'+resp.name+'", "' + resp.color + '");');
	    	newCat.find(".sch-evnt-delCat").attr("onclick", 'delCategory(event, this,"' + resp.id + '");');
	    	addDrag();
	    	sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops
	    	newCat.find(".sch-evnt-editCat").click();
	    },
	    error: function(resp)
	    {
	    	alert("Creating category failed :(");
	    }
	});
}

function delCategory(event, elem, id)
{
	$.ajax({
	    url: "/delete_category",
	    type: "POST",
	    data: {id: id},
	    success: function(resp)
	    { 
	    	console.log("Delete category complete.");
			sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops
	    },
	    error: function(resp)
	    {
	    	alert("Deleting category failed :(");
	    }
	});
	$(elem).parent().slideUp();
}

function saveCategory(event,elem,id)
{
	$.ajax({
	    url: "/create_category",
	    type: "POST",
	    data: {name: $(".catOverlayTitle").html(), id: id, color: $(".catTopOverlay").css("background-color"), privacy: currCategory.attr("privacy")},
	    success: function(resp)
	    { 
	    	console.log("Update category complete.");
	    	
	    	hideOverlay(); //Hide category editing panel
	    	
			$("#sch-sidebar .sch-evnt[data-id=" + id + "]").find(".evnt-title").html($(".catOverlayTitle").html()); //Update name in sidebar
			$(".sch-evnt[data-id=" + id + "]").css("background-color", $(".catTopOverlay").css("background-color")); //Update color of events
			sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops
	    },
	    error: function(resp)
	    {
	    	alert("Updating category failed :(");
	    }
	});
}

/****************************/
/* END JSON SERVER METHODS **/
/****************************/

/****************************/
/***** HELPER METHODS *******/
/****************************/

//converts an array [hour, minutes] from 24 hour to 12 hour time
function convertTo12Hour(timeArr)
{
	if(timeArr[0] >= 12)
	{
		if(timeArr[0] > 12)
			timeArr[0] -= 12;
		return timeArr.join(":") + " PM";
	}
	else
	{
		if(timeArr[0] == 0)
			timeArr[0] = 12;
		return timeArr.join(":") + " AM";
	}
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

/****************************/
/*** END HELPER METHODS *****/
/****************************/

/****************************/
/**** HTML TIED METHODS *****/
/****************************/

//Used by the next and previous buttons
function moveWeek(forward)
{
	if(forward) //if next button
		addDates(new Date(refDate.getYear()+1900,refDate.getMonth(),refDate.getDate()+7), true); //move forward
	else //otherwise
		addDates(new Date(refDate.getYear()+1900,refDate.getMonth(),refDate.getDate()-7), true); //move back
}

/****************************/
/***** END HTML METHODS *****/
/****************************/