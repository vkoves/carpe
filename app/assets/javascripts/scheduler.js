var sideHTML; // Instantiates sideHTML variable
var schHTML; // Instantiates schedule HTML variable, which will contain the "Mon-Sun" html on the main scheduler div.

var gridHeight = 25; //the height of the grid of resizing and dragging
var border = 2; //the border at the bottom for height stuff
var ctrlPressed = false; //is the control key presed? Updated upon clicking an event
var refDate = new Date(); // Reference date for where the calendar is now, so that it can switch between weeks.
var dropScroll = 0; //the scroll position when the last element was dropped

var scheduleItems = {}; //the map of all schedule item objects
var categories = {};
var breaks = {};

var eventTempId = 0; //the temp id that the next event will have, incremented on each event creation or load

var currEvent; //the event being currently edited
var currCategory; //the category being currently edited
var currMins; //the current top value offset caused by the minutes of the current item

var readied = false; //whether the ready function has been called

var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]; //Three letter month abbreviations
var dayNames = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']; //the names of the days

//Run schedule ready when the page is loaded. Either fresh or from turbo links
$(document).ready(scheduleReady);
$(document).on('page:load', scheduleReady);


/****************************/
/******* PROTOTYPES *********/
/****************************/

//written with help from:
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Introduction_to_Object-Oriented_JavaScript

function ScheduleItem() //The prototype for the schedule items
{
	this.categoryId; //the id of the associated category
	this.eventId; //the id of the event in the db
	this.tempId; //the id of the event in the hashmap

	this.startDateTime; //the start date and time, as a js Date()
	this.endDateTime; //the end date and time

	this.repeatType; //the repeat type as a string
	this.startRepeatType; //the date the repeating starts on
	this.endRepeatType; //the date the repeating starts on
	this.breaks = []; //an array of the repeat exceptions of this event. Does not include category level repeat exceptions

	this.name; //the name of the event
	this.description; //the event description
	this.location; //the event location

	this.lengthInHours =  function() //returns an float of the length of the event in hours
	{
		return differenceInHours(this.startDateTime, this.endDateTime, false);
	};

	this.hoursSpanned = function() //returns an integer of the difference in the hours
	{
		return this.endDateTime.getHours() - this.startDateTime.getHours();
	}

	this.destroy = function() //deletes the schedule item from the frontend
	{
		this.element().slideUp("normal", function() { $(this).remove(); }); //slide up the element and remove after that is done
		delete scheduleItems[this.tempId]; //then delete from the scheduleItems map
	};

	this.setStartDateTime = function(newStartDateTime, resize, userSet) //if resize is true, we do not move the end time
	{
		if(newStartDateTime.getTime() > this.endDateTime.getTime() && userSet) //if trying to set start before end
		{
			alert("The event can't start after it ends!"); //throw an error unless this is a new event (blank name)
			var startArr = [currEvent.startDateTime.getHours(), paddedMinutes(currEvent.startDateTime)]; //and reset the field
			$("#time-start").val(convertTo12Hour(startArr));
		}
		else
			setDateTime(true, newStartDateTime, this, resize);
	};

	this.setEndDateTime = function(newEndDateTime, resize, userSet) //if resize, we don't move the start time
	{
		if(newEndDateTime.getTime() < this.startDateTime.getTime() && userSet) //if trying to set end before start
		{
			alert("The event can't end before it begins!"); //throw an error unless this is a new event
			var endArr = [currEvent.endDateTime.getHours(), paddedMinutes(currEvent.endDateTime)]; //and reset the field
			$("#time-end").val(convertTo12Hour(endArr));
		}
		else
			setDateTime(false, newEndDateTime, this, resize);
	};

	this.setName = function(newName)
	{
		this.name = newName; //set the object daat
		this.element().find(".evnt-title").text(newName); //and update the HTML element
	};

	this.dragComplete = function(elem, resize)
	{
		var dateString = elem.parent().siblings(".col-titler").children(".evnt-fulldate").html();
		var offsetDiff = -Math.ceil($(".col-snap:first").offset().top);
		var hours = 0;
		if(resize)
			hours = Math.floor((parseInt(elem.css("top")))/gridHeight);
		else
			hours = (parseInt(elem.css("top")))/gridHeight;
		var newDate = new Date(dateString + " " + hours + ":" + paddedMinutes(this.startDateTime));
		this.setStartDateTime(newDate, resize);
		this.tempElement = elem;
	};

	this.resizeComplete = function(elem)
	{
		this.dragComplete(elem, true);
		var endDT = new Date(this.startDateTime.getTime());
		endDT.setHours(this.startDateTime.getHours() + (elem.outerHeight()/gridHeight));
		endDT.setMinutes(this.endDateTime.getMinutes());
		this.endDateTime = endDT;
	};

	this.getHeight = function() //returns the top value based on the hours and minutes of the start
	{
		var hourStart = this.startDateTime.getHours() + (this.startDateTime.getMinutes()/60);
		var h =  gridHeight*hourStart;
		return h;
	}

	this.getMinutesOffsets = function() //returns the pixel offsets caused by the minutes as an array
	{
		var offsets = [];
		offsets.push(gridHeight*(this.startDateTime.getMinutes()/60));
		offsets.push(gridHeight*(this.endDateTime.getMinutes()/60));
		return offsets;
	}

	this.updateHeight = function()
	{
		this.element().css("height", gridHeight*this.lengthInHours() - border);
	};

	this.element = function() //returns the HTML element for this schedule item, or elements if it is repeating
	{
		return $(".sch-evnt[evnt-temp-id="+ this.tempId + "]");
	};

	//HELPERS
	function setDateTime(isStart, dateTime, schItem, resize) //pass in whether this is start time, the date time, and whether this is resizing
	{
		var elem = schItem.element();

		if(isStart)
		{
			var topDT = dateTime;
			var change = differenceInHours(schItem.startDateTime, topDT); //see how much the time was changed
			var botDT = new Date(schItem.endDateTime.getTime());
			botDT.setHours(schItem.endDateTime.getHours() + change);
		}
		else
		{
			var botDT = dateTime;
			var change = differenceInHours(schItem.endDateTime, botDT); //see how much the time was changed
			var topDT = new Date(schItem.startDateTime.getTime());
			topDT.setHours(schItem.startDateTime.getHours() + change);
		}

		//console.log("Change: " + change);

		if(isStart || !resize) //only set the startDateTime if we are not resizing or starting
		{
			schItem.startDateTime = topDT;
			elem.css("top", schItem.getHeight()); //set the top position by gridHeight times the hour
			elem.children(".evnt-time.top").text(convertTo12Hour([topDT.getHours(), paddedMinutes(topDT)])).show();
		}

		if(!isStart || !resize) //only set the bottom stuff if this is setting the end time or we are not resizing
		{
			schItem.endDateTime = botDT;
			elem.children(".evnt-time.bot").text(convertTo12Hour([botDT.getHours(), paddedMinutes(botDT)])).show();
		}

		elem.attr("time", topDT.getHours() + ":" + paddedMinutes(topDT)); //set the time attribute
	}

	function differenceInHours(start, end, round) //return the difference in hours between two dates
	{
		var one_hour = 1000*60*60; //1000 ms/sec * 60 sec/min * 60 min/hr
		var diff = end.getTime() - start.getTime();
		if(round)
		{
			var roundDiff = Math.round(diff/one_hour);
			if (roundDiff == 0)
				roundDiff = 1;
			return  roundDiff;
			//Math.round(diff/one_hour);
		}
		else
			return diff/one_hour;
	}
};

function Category() //The prototype for the category items
{
	this.id; //the id of the category in the db
	this.name; //the name of the category, as a string
	this.color; //the color of the category, as a CSS acceptable string
	this.privacy; //the privacy of the category, right now either private || friends || public
}

function Break() //The prototype for breaks/repeat exceptions
{
	this.id; //the id of the associated repeat_exception in the db
	this.name; //the name of the break
	this.startDate; //the date the break starts. Any time on this variable should be ignored
	this.endDate; //the date the break ends. Similarly, time should be ignored.
}

/****************************/
/*****  END PROTOTYPES ******/
/****************************/

function scheduleReady()
{
	if(!readied)
	{
		loadInitialBreaks();
		loadInitialCategories();
		loadInitialEvents();

		sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops
		schHTML = $("#sch-days").html(); //The HTML for the scheduler days layout, useful for when days are refreshed

		addStartingListeners(); //add the event listeners

		addDrag(); //add dragging, recursively

		colDroppable();

		addDates(new Date(), false, true);
		readied = true;

		$(".col-snap").css("height", gridHeight*24); //set drop columns
		$(".sch-day-col").css("height", gridHeight*24 + 50); //set day columns, which have the divider line

		if(readOnly) //allow viewing of all events with single click
		{
			$(".edit, #repeat").remove();
			$("#overlay-loc, #overlay-desc, #overlay-title").attr("contenteditable", "false");
			$("#time-start, #time-end").attr("readonly", true);
			$(".col-snap .sch-evnt").click(function(){
				showOverlay($(this));
			});
		}
	}
}

function addStartingListeners()
{
	$(".date-field").datepicker( //show the datepicker when clicking on the field
	{
		firstDay: 1, //set Monday as the first day
	});
	$("#week-date").datepicker('setDate', 'today'); //set the date to today

	$("#week-date").change(function() //when the date for the shown week is changed
	{
		addDates(new Date($(this).val()), true); //update what is visible
	});

	$("#repeat-start, #repeat-end").change(function() //update repeatStart and repeatEnd on change
	{
		var id = $(this).attr("id");
		if(id == "repeat-start")
		{
			currEvent.repeatStart = new Date($(this).val());
		}
		else if(id == "repeat-end")
		{
			currEvent.repeatEnd = new Date($(this).val());
		}
	});

	$("#repeat-custom").click(function()
	{
		//highlight the newly selected option
		$(".repeat-option").removeClass("red");
		$(this).addClass("red");

		$("#repeat-custom-options").toggle();
		var num = $("#repeat-custom-number").val();
		var unit = $("#repeat-custom-unit").val();
		currEvent.repeatType = "custom-" + num + "-" + unit;
	});

	$("#repeat-custom-number, #repeat-custom-unit").change(function()
	{
		var num = $("#repeat-custom-number").val();
		var unit = $("#repeat-custom-unit").val();
		currEvent.repeatType = "custom-" + num + "-" + unit;

		//repopulate this event
		$(".sch-evnt[evnt-temp-id='" + currEvent.tempId + "']").remove();
		populateEvents();
	});

	//Add break button click handler, which shows the overlay
	$("#create-break").click(function()
	{
		showBreakCreateOverlay();
	});

	$("#add-break-event").click(function()
	{
		showBreakAddOverlay();
	});

	//Submit break button in the overaly
	$("#submit-break").click(function()
	{
		var name = $("#break-name").val();
		var startDate = $("#break-start").val();
		var endDate = $("#break-end").val();

		if(name == "" || startDate == "" || endDate == "")
			alert("Fill out all fields!");
		else
			createBreak(name, startDate, endDate);
	});

	//When editing category title, defocus on enter
	$(".catOverlayTitle").on("keydown",function(e){
	    var key = e.keyCode || e.charCode;  // ie||others
	    if(key == 13)  // if enter key is pressed
	    {
			e.preventDefault();
		    $(this).blur();  // lose focus
	    }
	}).click(function()
	{
		highlightCurrent(); //higlight the category name
		if($(this).text() == "Untitled")
		{
			$(this).text("");
		}
	}).focusout(removeHighlight);

	$(".repeat-option").click(function()
	{
		//highlight the newly selected option
		$(".repeat-option").removeClass("red");
		$(this).addClass("red");

		if($(this).attr("id") != "repeat-custom") //if this isn't custom, repeat stuff
		{
			//get the text of the button
			var repType = $(this).text().toLowerCase();
			console.log("Rep type is " + repType);
			currEvent.repeatType = repType;
			$("#repeat-custom-options").hide(); //hide custom options
		}

		//repopulate this event
		$(".sch-evnt[evnt-temp-id='" + currEvent.tempId + "']").remove();
		populateEvents();
	});



	$(".color-swatch").click(function()
	{
		$(".color-swatch").removeClass("selected");

		$(this).addClass("selected");
	});

	$("#cat-privacy span").click(function()
	{
		//highlight the newly recent option
		$("#cat-privacy span").removeClass("red");
		$(this).addClass("red");

		currCategory.attr("privacy", $(this).text().toLowerCase());
	});

	$("#time-start").change(function()
	{
		//TODO: Fix this not working across different days (try noon in your local time)

		var dateE = currEvent.element().parent().siblings(".col-titler").children(".evnt-fulldate").html(); //the date the elem is on

		var val = $(this).val();
		var end_val = $("#time-end").val();

		dateTime = new Date(dateE+" "+val);
		if (isNaN(dateTime.getTime()))
			alert("Start date doesn't make sense! Tried \"" + dateE+" "+val + "\"");

		var newDateTime = new Date(currEvent.startDateTime.getTime()); //We don't want to modify the date, only the time, so clone the date
		newDateTime.setHours(dateTime.getHours()); //change the hours
		newDateTime.setMinutes(dateTime.getMinutes()); //change the minutes

		currEvent.setStartDateTime(newDateTime, true, true); //and set!
		currEvent.updateHeight();

	});

	$("#time-end").change(function()
	{
		//TODO: Fix this not working across different days (try noon in your local time)

		var dateE = currEvent.element().parent().siblings(".col-titler").children(".evnt-fulldate").html(); //the date the elem is on

		var val = $(this).val();
		var start_val = $("#time-start").val();

		dateTime = new Date(dateE+" "+val);
		if (isNaN(dateTime.getTime()))
			alert("End date doesn't make sense! Tried \"" + dateE+" "+val + "\"");

		var newDateTime = new Date(currEvent.startDateTime.getTime());
		newDateTime.setHours(dateTime.getHours());
		newDateTime.setMinutes(dateTime.getMinutes());

		currEvent.setEndDateTime(newDateTime, true, true);
		currEvent.updateHeight();

	});

	$("#overlay-desc").focusout(function()
	{
		currEvent.description = $(this).text();
		removeHighlight();
	}).click(highlightCurrent);

	$("#overlay-loc").focusout(function()
	{
		currEvent.location = $(this).text();
		removeHighlight();
	}).click(highlightCurrent);

	$("#overlay-title").on("keydown",function(e){
	    var key = e.keyCode || e.charCode;  // ie||others
	    if(key == 13)  // if enter key is pressed
	    {
			e.preventDefault();
		    $(this).blur();  // lose focus
		    currEvent.setName($(this).text());
	    }
	})
	.click(highlightCurrent)
	.focusout(function()
	{
		//so that clicking outside an event title also saves
		currEvent.setName($(this).text());
		removeHighlight();
	});

	$("#edit-desc").click(function()
	{
		$('#overlay-desc').focus();
		highlightCurrent();
	});

	$("#edit-loc").click(function()
	{
		$('#overlay-loc').focus();
		highlightCurrent();
	});

	$(document).keyup(function(e) //add event listener to close overlays on pressing escape
	{
		if (e.keyCode == 27) // escape key maps to keycode `27`
		{
			hideOverlay();
		}
	});
}

//Load in categories
function loadInitialCategories()
{
	if(typeof categoriesLoaded !== 'undefined') //if categoriesLoaded is defined
	{
		for(var i = 0; i < categoriesLoaded.length; i++) //iterate through the loaded categories
		{
			var currCat = categoriesLoaded[i];

			var catInstance = new Category();
			catInstance.id = currCat.id;
			catInstance.privacy = currCat.privacy;
			catInstance.color = currCat.color;
			catInstance.name = currCat.name;

			categories[catInstance.id] = catInstance;
		}
	}
}

function loadInitialBreaks()
{
	if(typeof breaksLoaded !== 'undefined') //if categoriesLoaded is defined
	{
		for(var i = 0; i < breaksLoaded.length; i++) //iterate through the loaded categories
		{
			var currBreak = breaksLoaded[i];

			var breakInstance = new Break();
			breakInstance.id = currBreak.id;
			breakInstance.name = currBreak.name;
			breakInstance.startDate = new Date(currBreak.start);
			breakInstance.endDate = new Date(currBreak.end);

			breaks[breakInstance.id] = breakInstance;
		}
	}
}

//load events into the scheduleItems hashmap
function loadInitialEvents()
{
	//Load in events
	if (typeof eventsLoaded !== 'undefined') //if eventsLoaded is defined
	{
		for(var i = 0; i < eventsLoaded.length; i++) //loop through it
		{
			var evnt = eventsLoaded[i]; //fetch the event at the current index

			var schItem = new ScheduleItem();
			schItem.startDateTime = new Date(evnt.date);
			schItem.endDateTime = new Date(evnt.end_date);
			if(evnt.repeat_start)
				schItem.repeatStart = new Date(evnt.repeat_start + " CST"); //timezone dependant!

			if(evnt.repeat_end)
				schItem.repeatEnd = new Date(evnt.repeat_end + " CST"); //timezone dependant!

			schItem.name = evnt.name;
			schItem.eventId = evnt.id;
			schItem.categoryId = evnt.category_id;
			schItem.repeatType = evnt.repeat;
			schItem.description = evnt.description;
			schItem.location = evnt.location;
			schItem.tempId = i;
			scheduleItems[i] = schItem;

			var catParent = $("#sch-tiles .sch-evnt[data-id='" + evnt["category_id"] + "']"); //fetch the category

			if(catParent.length == 0) //if this user doesn't have access to the category, use the cat-template
				catParent = $("#cat-template");

			var clone = catParent.clone();
			clone.css("display", "block"); //make sure this is visible, just in case it's a child of the cat-template
			var dateE = new Date(evnt.date);
			var dateEnd = new Date(evnt.end_date);
			var time = dateE.getHours() + ":" + paddedMinutes(dateE);
			var dateString = monthNames[dateE.getMonth()] + " " + dateE.getDate() + ", " + dateE.getFullYear();

			clone.children(".evnt-title").text(evnt.name);
			clone.children(".evnt-time.top").text(convertTo12Hour([dateE.getHours(), paddedMinutes(dateE)])).show();
			clone.children(".evnt-time.bot").text(convertTo12Hour([dateEnd.getHours(), paddedMinutes(dateEnd)])).show();
			clone.attr("time", time);
			clone.attr("event-id", evnt.id);
			clone.attr("evnt-temp-id", i); //Set the temp id
			clone.children(".evnt-desc").html(evnt.description);

			scheduleItems[i].tempElement = clone; //Store the element

			placeInSchedule(clone, scheduleItems[i].getHeight(), scheduleItems[i].lengthInHours());

			eventTempId++; //increment the temp id
		}
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
	    	dropScroll = $("#sch-holder").scrollTop(); //appending this element will scroll us up to the top, so we have to adjust for that
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
			//$(ui.draggable).draggable("option","gridOn", false); //and disable grid
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

		    scheduleItems[$(this).parent().attr("evnt-temp-id")].setName($(this).text());

	    }
	})
	.focusout(function()
	{
		//so that clicking outside an event title also saves
		$(this).parent().draggable("enable");

		scheduleItems[$(this).parent().attr("evnt-temp-id")].setName($(this).text());

		removeHighlight();
	});

	//when the mouse is pressed on the events, check for control
	$(selector).mousedown(function(event)
	{
		if(event.ctrlKey)
			ctrlPressed = true;
		else
			ctrlPressed = false;
	});

	$(selector).dblclick(function()
	{
		showOverlay($(this));
	})

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

			if(inColumn($(this))) //if this is a current element
				$(this).css("opacity", 0); //hide the original while we are moving the helper

			return $copy;
		},
		start: function(event, ui)
		{
			if($(this).parent().attr("id") == "sch-tiles-inside")
				setHeight(this, ui.helper, 3);

			if(ctrlPressed && $(this).parent().attr("id") != "sch-tiles-inside") //if this is an existing event and control is pressed
			{
				handleClone(this, ui);
			}
		},
		stop: function(event, ui)  //on drag end
		{
			var newItem = false;

			if(!inColumn($(this))) //if this event was not placed
				return; //return

			if($(this).css("opacity") == 1) //if opacity is 1, this is a new event
			{
				$(this).css("height", gridHeight*3 - border);
				handleNewEvent(this);
				newItem = true;
			}

			$("#sch-tiles").html(sideHTML); //reset the sidebar
			$(this).css("opacity", 1); //undo the setting opacity to zero

			var tempItem = scheduleItems[$(this).attr("evnt-temp-id")];

			handlePosition(this, ui);
			if(!newItem) //if this is not a new item
				tempItem.dragComplete($(this)); //say it's been moved
			else //otherwise
			{
				tempItem.resizeComplete($(this)); //say it's been resized, to read all properties
				tempItem.endDateTime.setMinutes(0);
			}

			if(tempItem.repeatType && tempItem.repeatType != "none" && tempItem.repeatType != "") //if this is a repeating event
			{
				$(".sch-evnt[evnt-temp-id='" + tempItem.tempId + "']").remove(); //remove all of this event
				populateEvents(); //and populate
			}

			addDrag(); //add drag to the sidebar again
		},
		drag: function(event, ui)
		{
			updateTime($(this), ui);
		}
	});

	addResizing(selector);
}

//Called on event stop, aka let go
function handlePosition(elem, ui) //if
{
	var offset = $(elem).parent().offset().top;
	var topVal = ui.position.top - offset - currMins;

	if(topVal % gridHeight != 0)
		topVal += dropScroll;

	//console.log("Handle top: " + ui.position.top + " offset: " + $(elem).parent().offset().top + " scroll: " + dropScroll + " body: " + $("body").scrollTop());
	$("#sch-holder").scrollTop(dropScroll);

	if(topVal < 0) //make sure the event is not halfway off the top
	{
		topVal = 0;
	}
	else if(topVal > $(elem).parent().height() - $(elem).outerHeight()) //or bottom
	{
		topVal = $(elem).parent().height() - $(elem).outerHeight();
		topVal = topVal - (topVal%gridHeight);
	}

	$(elem).css("top",topVal);
}

//Called when creating a clone
function handleClone(elem, ui)
{
	var clone = $(ui.helper).clone(); //create a clone
	$(elem).parent().append(clone);
	clone.css("opacity","1"); //set the clone to be fully opaque, as it'll be 0.7 opacity by default from dragging

	$(elem).removeAttr("event-id"); //clear event id

	$(elem).attr("evnt-temp-id", eventTempId); //the clone needs a new temp id, but in reality, this is the clone

	var schItem = new ScheduleItem();
	var oldItem = scheduleItems[$(clone).attr("evnt-temp-id")];
	schItem.startDateTime = oldItem.startDateTime;
	schItem.endDateTime = oldItem.endDateTime;
	schItem.name = oldItem.name;
	schItem.eventId = null; //this is a new element so don't copy that
	schItem.categoryId = oldItem.categoryId;
	schItem.repeatType = oldItem.repeatType;
	schItem.location = oldItem.location;
	schItem.description = oldItem.description;
	schItem.tempId = eventTempId;
	scheduleItems[eventTempId] = schItem;

	eventTempId++;


	clone.removeClass("ui-draggable ui-draggable-handle ui-resizable ui-draggable-dragging"); //remove dragging stuff
	addDrag(clone); //and redo dragging
}

//called on new events dragged from the sidebar
function handleNewEvent(elem)
{
	var schItem = new ScheduleItem();
	schItem.startDateTime = new Date();
	schItem.startDateTime.setMinutes(0);
	schItem.endDateTime = new Date();
	schItem.name = "";
	schItem.eventId = null;
	schItem.categoryId = $(elem).attr("data-id");
	schItem.repeatType = "";
	schItem.tempId = eventTempId;
	schItem.tempElement = $(elem);
	scheduleItems[eventTempId] = schItem;

	$(elem).children(".evnt-title").attr("contenteditable", "true");
	$(elem).children(".evnt-title").trigger('focus');
	highlightCurrent(); // Suggests to the user to change the schedule item title by making it editable upon drop here.
	document.execCommand('delete',false,null); // Suggests to the user to change the schedule item title by making it editable upon drop here.
	$(elem).attr("evnt-temp-id", eventTempId);
	eventTempId++;
	addResizing($(elem)); //since the sidebar events don't have resizing, we have to add it on stop
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
	    	},
	    	stop: function(event, ui)
	    	{
				var tempItem = scheduleItems[$(this).attr("evnt-temp-id")];
				tempItem.resizeComplete($(this));

				if(tempItem.repeatType && tempItem.repeatType != "none" && tempItem.repeatType != "") //if this is a repeating event
				{
					$(".sch-evnt[evnt-temp-id='" + tempItem.tempId + "']").remove(); //remove all instances
					populateEvents(); //and populateEvents to refresh things
				}
	    	}
		});
	}
}

//Change time while items are being dragged or resized, and also snap to a vertical grid
function updateTime(elem, ui, resize) //if we're resizing, don't snap, just update time
{
	//TODO: Make this really important function not suck

	var arr = ui.helper.attr("time").split(":"); //fetch the time from the helper
	var end_arr = ui.helper.children(".evnt-time.bot").text().split(" ")[0].split(":");
	var item = scheduleItems[elem.attr("evnt-temp-id")];

	//Take care of grid snapping
	if($(elem).draggable('option', 'gridOn') || resize) //only update time if we are snapping in a column or are resizing
	{
		var offsetDiff = -Math.ceil($(".col-snap:first").offset().top);
		if(resize)
			offsetDiff = 0;

		currMins = 0;
		if(item)
			currMins = gridHeight*(item.startDateTime.getMinutes()/60);

		if(!resize)
		{
			var topRemainder = (ui.position.top + offsetDiff) % gridHeight;
			ui.position.top = ui.position.top - topRemainder;
			arr[0] = (ui.position.top + offsetDiff)/gridHeight;
		}
		else
		{
			arr[0] = Math.ceil(ui.position.top - currMins + offsetDiff)/gridHeight;
		}

		if(!resize)
			ui.position.top += currMins;
	}


	//var end_arr = arr.slice(0); //set end array
	var hoursLength = $(elem).outerHeight()/gridHeight; //find the length in hours
	var hoursSpanned = 3;
	if(item)
	{
		hoursLength = item.lengthInHours();
		hoursSpanned = item.hoursSpanned();
	}
	else
		hoursLength = 3;

	//if(hoursLength % 1 != 0) //if it's a decimal, we know this is a new event
	//	hoursLength = 3; //so set the default size

	if(!resize)
		end_arr[0] = arr[0] + hoursSpanned; //and add the height to the hours of the end time
	else
	{
		end_arr[0] = arr[0] + Math.round(($(elem).outerHeight() + item.getMinutesOffsets()[0] - item.getMinutesOffsets()[1])/gridHeight);
	}


	$(elem).attr("time", arr.join(":")); //set the time attr using military
	arr = convertTo12Hour(arr); //then convert to 12 hour

	//set Start time
	ui.helper.children(".evnt-time.top").html(arr); //and set the helper time
	$(elem).children(".evnt-time.top").html(arr); //as well as the element

	end_arr = convertTo12Hour(end_arr);
	ui.helper.children(".evnt-time.bot").html(end_arr); //and set the helper time
	$(elem).children(".evnt-time.bot").html(end_arr); //as well as the element
}


//called by next and previous buttons on click
function addDates(currDate, refresh, today)
{
	var day = currDate.getDay();
	var date = currDate.getDate();
	var month = currDate.getMonth();
	var year = currDate.getFullYear();
	var startDate;
	var lastDateCurr = new Date(year, month+1, 0).getDate(); //get the last date of the current month by getting the day before 1 on the next month
	var lastDatePrev = new Date(year, month, 0).getDate();
	var lastMonth = false;

	refDate = currDate;

	if(refresh)
	{
		$("#sch-days").html(schHTML); // Refresh the layout so that we can properly prepend and append text below here
		colDroppable();
	}

	if(!today)
	{
		if(day == 0)
			startDate = date - 6;
		else
			startDate = date - day + 1;
	}
	else
	{
		startDate = date;
	}

	if(startDate <= 0) //if the start is in the last month
	{
		startDate = lastDatePrev + startDate;
		lastMonth = true;
	}

	$(".sch-day-col").each(function(index, col)
	{
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
			$(col).children(".col-titler").find(".evnt-day").text(dayNames[new Date(fullDate).getDay()]);
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

		if(new Date(fullDate).toDateString() == new Date().toDateString())
		{
			$(col).attr("id","sch-col-today");
		}

		startDate++;
	});

	populateEvents(); // After refreshing the dates, populate the...er...schedule items for this week. As you can see, the terminology still confuses some.
}

//Populate the events in the current week from the hashmap
function populateEvents()
{
	function place(eventObject, i)
	{
		var currentElem = eventObject.tempElement.clone();
		$(".sch-day-col:eq(" + i + ") .col-snap").append(currentElem);
	}

	var currentDates = []; //the dates that are visible in the current week

	$(".sch-day-col").each(function(index, col)
	{
		currentDates.push($(col).children(".col-titler").children(".evnt-fulldate").html());
	}); // Populate the date range array created above, so that we can match up what events have dates that fall in this range.


	for (var i = 0; i < currentDates.length; i++)
	{
		for (var eventIndex in scheduleItems) //do a foreach since this is a hashmap
		{
			eventObj = scheduleItems[eventIndex];
			var date = new Date(currentDates[i]);
			var itemDate = new Date(eventObj.startDateTime.getTime());

			if(eventObj.repeatStart && eventObj.repeatStart > date) //if the repeatStart is later than this date, don't show
				continue;
			else if(eventObj.repeatEnd && eventObj.repeatEnd < date) //if the repeatEnd is before this date, don't show
				continue;

			if (itemDate.toDateString() == date.toDateString()
				|| eventObj.repeatType == "daily"
				|| (eventObj.repeatType == "weekly" && date.getDay() == itemDate.getDay())
				|| (eventObj.repeatType == "monthly" && date.getDate() == itemDate.getDate())
				|| (eventObj.repeatType == "yearly" && date.getDate() == itemDate.getDate() && date.getMonth() == itemDate.getMonth()))
			{
				place(eventObj, i);
			}
			else if(eventObj.repeatType.split("-")[0] == "custom")
			{
				var arr = eventObj.repeatType.split("-");
				var num = arr[1];
				var unit = arr[2];

				//simplify by removing hours and minutes from itemDate
				itemDate.setHours(0);
				itemDate.setMinutes(0);

				var day = 1000*60*60*24;
				var year_diff = date.getFullYear() - itemDate.getFullYear();
				var month_diff = year_diff*12 + date.getMonth() - itemDate.getMonth();
				var week_diff = Math.round((date - itemDate)/(day * 7));
				var day_diff = Math.round((date - itemDate)/day);

				if(unit == "years" && date.getDate() == itemDate.getDate() && date.getMonth() == itemDate.getMonth())
				{
					if(year_diff % num == 0) //if the number of years difference is divisible by the repat num
						place(eventObj, i);
				}
				else if(unit == "months" && date.getDate() == itemDate.getDate())
				{
					if(month_diff % num == 0)
						place(eventObj, i);
				}
				else if(unit == "weeks" && date.getDay() == itemDate.getDay())
				{
					if(week_diff % num == 0)
						place(eventObj, i);
				}
				else if(unit == "days")
				{
					if(day_diff % num == 0)
						place(eventObj, i);
				}

				var week = day*7;
			}
		}
	}
	addDrag(".col-snap .sch-evnt"); // Re-enables the events to snap onto the date columns here.

	if(readOnly)
	{
		$(".col-snap .sch-evnt").click(function(){
			showOverlay($(this));
		});
	}
}

//Edit an event's text inline (without the overlay)
function editEvent(event, elem)
{
	//return if this is in the sidebar
	if(!inColumn($(elem).parent()) || $(elem).is(":focus"))
		return;

	$(elem).parent().draggable("disable"); //disable dragging while editing the event text

	$(elem).attr("contenteditable", "true");
	event.stopImmediatePropagation();
	$(elem).trigger('focus');
	highlightCurrent();
	$(elem).siblings(".sch-evnt-save").css("display","inline");
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

	$(".ui-widget-overlay, #cat-overlay-box").fadeIn(250);

	var colForTop = currCategory.css("background-color");

	$(".catTopOverlay").css("background-color",colForTop);

	/* if(col && col != "null") //check for null string from ruby
		$(".catTopOverlay").css("background-color",col);
	else //if the color was null or empty remove the background-color
		$(".catTopOverlay").css("background-color",""); */

	$(".catOverlayTitle").html($(currCategory).find(".evnt-title").text());
	$("#cat-overlay-box").attr("data-id",id);

	$(".color-swatch").removeClass("selected");
	$(".color-swatch").each(function() {
		if ($(this).css("background-color") == $(".catTopOverlay").css("background-color"))
		{
			$(this).addClass("selected");
		}
	});
}

//show the event editing overlay
function showOverlay(elem)
{
	var editingEvent = $(document.activeElement).hasClass("evnt-title");

	if(inColumn(elem) && !editingEvent && elem.attr("data-id") != -1) //make sure this is a placed event that isn't private and we aren't already editing
	{
		currEvent = scheduleItems[elem.attr("evnt-temp-id")];

		var categoryName = $("#sch-tiles .sch-evnt.category[data-id=" + currEvent.categoryId + "]").find(".evnt-title").text();
		$("#cat-title").html("In category <b>" + categoryName + "</b>");

		//Select the proper repeat button
		$(".repeat-option").removeClass("red");
		var rep = currEvent.repeatType || "none";
		$("#repeat-" + rep).addClass("red");

		if(rep.indexOf("custom") > -1)
		{
			$("#repeat-custom").addClass("red");
			$("#repeat-custom-options").show();
			$("#repeat-custom-number").val(rep.split("-")[1]); //set the number
			$("#repeat-custom-unit").val(rep.split("-")[2]); //and the unit
		}
		else
		{
			$("#repeat-custom-options").hide();
		}

		$("#repeat-start").val(dateToString(currEvent.repeatStart));
		$("#repeat-end").val(dateToString(currEvent.repeatEnd));

		$(".ui-widget-overlay, #event-overlay-box").fadeIn(250);

		$("#overlay-title").html(currEvent.name);
		$("#overlay-color-bar").css("background-color",elem.css("background-color"));

		var desc = currEvent.description || ""; //in case the description is null
		var loc = currEvent.location || ""; //in case the location is null
		$("#overlay-desc").html(desc);
		$("#overlay-loc").html(loc);

		if(desc.length == 0 && readOnly) //if this is readOnly and there is no description
			$("#overlay-desc, #desc-title").hide(); //hide the field and the title
		else
			$("#overlay-desc, #desc-title").show();

		if(loc.length == 0 && readOnly) //do the same for the location
			$("#overlay-loc, #loc-title").hide();
		else
			$("#overlay-loc, #loc-title").show();

		var startArr = [currEvent.startDateTime.getHours(), paddedMinutes(currEvent.startDateTime)];
		var endArr = [currEvent.endDateTime.getHours(), paddedMinutes(currEvent.endDateTime)];

		//$(".overlay-time").html(convertTo12Hour(time.split(":")) + " - " + convertTo12Hour(endTime.split(":")));
		$("#time-start").val(convertTo12Hour(startArr));
		$("#time-end").val(convertTo12Hour(endArr));
	}
}

//Show the overlay for creating a new break
function showBreakCreateOverlay()
{
	$("#break-overlay-box input").val(""); //clear all inputs
	$(".ui-widget-overlay, #break-overlay-box").fadeIn(250); //and fade in
}

function showBreakAddOverlay()
{
	$("#break-cont").html(""); //clear the break container
	for (var id in breaks) //do a foreach since this is a hashmap
	{
		var breakInstance = breaks[id]; //and add each break
		$("#break-cont").append(breakInstance.name + " | " + dateToString(breakInstance.startDate) + " | " + dateToString(breakInstance.endDate));
		$("#break-cont").append("<br><br>");
	}
	$(".ui-widget-overlay, #break-adder-overlay-box").fadeIn(250);
}

//Hide any type of overlay
function hideOverlay()
{
	//Hide overlay, the repeat menu and category and event overlays
	$(".ui-widget-overlay, #repeat-menu, #event-overlay-box, #cat-overlay-box, #break-overlay-box, #break-adder-overlay-box").fadeOut(250);
}

//Hide the break adding overlay
function hideBreakAddOverlay()
{
	$("#break-adder-overlay-box").fadeOut(250);
}

//Update the color of the category overlay from a color being picked
function changeCategoryColor(elem)
{
	$(".catTopOverlay").css("background-color",$(elem).css("background-color"));
}

//Setup properties of a place schedule item from the db, setting position and height
function placeInSchedule(elem, hours, lengthHours)
{
	//console.log("Length: " + lengthHours);
	$(elem).css("height", (gridHeight*lengthHours)-border); //set the height using the length in hours
	$(elem).css("top", hours); //set the top position by gridHeight times the hour
}

/****************************/
/*** JSON SERVER METHODS ****/
/****************************/

function saveEvents()
{
	//JSON encode our hashmap
	var arr  = JSON.parse(JSON.stringify(scheduleItems));

	$.ajax({
	    url: "/save_events",
	    type: "POST",
	    data: {map: arr, text: "testificates"},
	    success: function(resp)
	    {
	    	console.log("Save complete.");
	    	$("#sch-save").addClass("active");
	    	setTimeout(function()
	    	{
	    		$("#sch-save").removeClass("active");
	    	}, 1500);

	    	for(var key in resp)
	    	{
	    		$(".sch-evnt[evnt-temp-id="+ key + "]")	.attr("event-id", resp[key]);
	    		scheduleItems[key].eventId = resp[key];
	    	}
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

	delete scheduleItems[tempId]; //remove event map

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
	    	saveEvents();
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
	    	newCat.attr("privacy", "private");
	    	newCat.find(".evnt-title").text(resp.name);
	    	newCat.find(".sch-evnt-editCat").attr("onclick", 'editCategory(event, this, "' + resp.id + '", "'+resp.name+'", "' + resp.color + '");');
	    	newCat.find(".sch-evnt-delCat").attr("onclick", 'deleteCategory(event, this,"' + resp.id + '");');
	    	addDrag();
	    	sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops
	    	newCat.find(".sch-evnt-editCat").click(); //trigger the edit event
	    },
	    error: function(resp)
	    {
	    	alert("Creating category failed :(");
	    }
	});
}

function deleteCategory(event, elem, id)
{
	$.ajax({
	    url: "/delete_category",
	    type: "POST",
	    data: {id: id},
	    success: function(resp) //after the server says the delete worked
	    {
	    	console.log("Delete category complete.");
			$(elem).parent().slideUp("normal", function() //slide up the div, hiding it
			{
				$(this).remove(); //and when that's done, remove the div
				sideHTML = $("#sch-tiles").html(); //and save the sidebar html for restoration upon drops
				//Remove all events of this category from scheduleItems
				$(".col-snap .sch-evnt[data-id=" + id + "]").slideUp();
				for (var index in scheduleItems) //do a foreach since this is a hashmap
				{
					if(scheduleItems[index].categoryId = id)
					{
						delete scheduleItems[index];
					}
				}
			});
	    },
	    error: function(resp)
	    {
	    	alert("Deleting category failed :(");
	    }
	});
}

function saveCategory(event,elem,id)
{
	$.ajax({
	    url: "/create_category",
	    type: "POST",
	    data: {name: $(".catOverlayTitle").text(), id: id, color: $(".catTopOverlay").css("background-color"), privacy: currCategory.attr("privacy")},
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

function createBreak(name, startDate, endDate)
{
	console.log("Make the break: " + name + ", " + startDate + ", " + endDate);
	var startD = new Date(startDate);
	var endD = new Date(endDate);

	$.ajax({
	    url: "/create_break",
	    type: "POST",
	    data: {name: name, start: startD, end: endD},
	    success: function(resp) //server responds with the id
	    {
	    	var brk = new Break(); //create a new break instance
	    	brk.id = resp;
	    	brk.name = name;
	    	brk.startDate = startD;
	    	brk.endDate = endD;
	    	breaks[brk.id] = brk; //and add to the hashmap

	    	hideOverlay(); //Hide category editing panel
	    },
	    error: function(resp)
	    {
	    	alert("Creating break failed! :(");
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

		if(timeArr[0] == 0)
			timeArr[0] == "00";

		return timeArr.join(":") + " PM";
	}
	else
	{
		if(timeArr[0] == 0)
			timeArr[0] = 12;

		if(timeArr[0] == 0)
			timeArr[0] == "00";

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

function setHeight(getElem, setElem, hoursLength) //get the height of getElem and set the height of setElem if the height is not a proper height (divisible by gridheight)
{
	var height = parseFloat($(getElem).css("height"));
	if((height+border)%gridHeight != 0)
		$(setElem).css("height", (gridHeight*hoursLength)-border);
}

function paddedMinutes(date)
{
	var minutes = (date.getMinutes() < 10? '0' : '') + date.getMinutes(); //add zero the the beginning of minutes if less than 10
	return minutes;
}

function paddedNumber(num)
{
	var paddedNum = (num < 10? '0' : '') + num; //add zero the the beginning of minutes if less than 10
	return paddedNum;
}

//removes cursor highlight
function removeHighlight()
{
	window.getSelection().removeAllRanges();
}

//highlgiht the field currently selected
function highlightCurrent()
{
	document.execCommand('selectAll',false,null);
}

//convert a date into a standard string format
function dateToString(date)
{
	if(!date || !(date instanceof Date)) //if the date is null or not a date object
		return null; //return null

	if(isNaN(date.getTime())) //if invalid date
		return "INVALID!"; //return invalid string

	var dateString = (date.getMonth() + 1); //start with the month. JS gives the month from 0 to 11, so we add one
	dateString = dateString + "/" + date.getDate(); //then add a / plus the date
	dateString = dateString + "/" + ("" + date.getFullYear()).slice(-2); //then get the last two digits of the year by converting to string and slicing
	return dateString; //and return
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
	var newDate;

	if(forward) //if next button
		newDate = new Date(refDate.getYear()+1900,refDate.getMonth(),refDate.getDate()+7)
	else //otherwise
	{
		 //if we are looking at today but the first day is not monday
		if(new Date($("#week-date").val()).toDateString() == new Date().toDateString() && !$(".evnt-day").text().startsWith("Monday"))
			newDate = new Date(); //see this full week
		else //otherwise
			newDate = new Date(refDate.getYear()+1900,refDate.getMonth(),refDate.getDate()-7); //go to one week previous
	}
	addDates(newDate, true); //move back

	//And update the date thing. Recall that javascript get month starts at 0 with January, so we append 1 for humans
	$("#week-date").val(paddedNumber(newDate.getMonth() + 1) + "/" + paddedNumber(newDate.getDate()) + "/" + newDate.getFullYear());
}

/****************************/
/***** END HTML METHODS *****/
/****************************/