/*
 * Instantiates and handles the Carpe scheduling interface, populating
 * the users schedule, handling switching between weeks, and communicating
 * with the server about changes to the schedule, such as creating, moving
 * or deleting events or categories.
 */

var sideHTML; // Instantiates sideHTML variable
var schHTML; // Instantiates schedule HTML variable, which will contain the "Mon-Sun" html on the main scheduler div.

var gridHeight = 25; //the height of the grid of resizing and dragging
var border = 2; //the border at the bottom for height stuff
var ctrlPressed = false; //is the control key presed? Updated upon clicking an event
var refDate = new Date(); // Reference date for where the calendar is now, so that it can switch between weeks.
var visibleDates = []; //an array of dates that are currently visible on the schedule
var dropScroll = 0; //the scroll position when the last element was dropped

var scheduleItems = {}; //the map of all schedule item objects
var categories = {};
var breaks = {};

var eventTempId = 0; //the temp id that the next event will have, incremented on each event creation or load

var currEvent; //scheduleItem Object - the event being currently edited
var currCategory; //Category Object - the category being currently edited
var currMins; //the current top value offset caused by the minutes of the current item

var readied = false; //whether the ready function has been called

var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]; //Three letter month abbreviations
var fullMonthNames = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
var dayNames = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday']; //the names of the days

var viewMode = "week"; //either "week" or "month"

var saveEventsTimeout; // timeout for save events so it doesn't happen too often

var PLACEHOLDER_NAME = "<i>Untitled</i>"; // used by newly created categories and events

/****************************/
/**** DOCUMENT FUNCTIONS ****/
/****************************/

//Run scheduleReady when the page is loaded. Either fresh or from turbo links
$(document).ready(scheduleReady);
$(document).on('page:load', scheduleReady);

//Run when the user tries to leave the page through a Turbolink
$(document).unbind('page:before-change'); //unbind page before change from last time viewing
$(document).on('page:before-change', pageChange); //and load again


/**
 * If the user is allowed to leave, returns undefined.
 * If it is not a good time to leave, returns if the user is sure they want to leave.
 * run beforeunload
 * @return {boolean} true if the person wants to leave, false if the user wants to stay, undefined if user can leave
 */
function pageChange() //called by Turbolinks before-change
{
	if(!isSafeToLeave()) //if the save button is active (they have changes) and this is the user's schedule
	{
		return confirm("You still have changes to your schedule pending! Are you sure you want to leave this page?");
	}
}

//Run on closing the window or relaoding
$(window).on('beforeunload', function()
{
	if(!isSafeToLeave()) //if the save button is active (they have changes) and this is the user's schedule
	{
		return "You still have changes to your schedule pending!";
	}
});

/**
 * Helper function that determines whether or not it is safe for user
 * to leave a page. If user is on schedule page, this is determined
 * by the active state of the Save button on the page; on other pages,
 * it is always safe for the user to leave the page, as there is no data
 * to be saved.
 * @return {boolean} returns true if changes are saved, nothing otherwise
 */
function isSafeToLeave()
{
	if($("#sch-save").length == 0) //we're not on the schedule page anymore
		return true;
	else if($("#sch-save").hasClass("disabled") //if the save button is disabled, the user saved some time ago
		|| $("#sch-save").hasClass("active") //if the save button is active, save suceeded just now
		|| readOnly) //and if the page is read only the page can't be edited
		return true; //thus for any of these, it's safe to leave
}


/****************************/
/** END DOCUMENT FUNCTIONS **/
/****************************/

/****************************/
/******* PROTOTYPES *********/
/****************************/

/**
 * Defines the class for schedule items.
 * @class
 * @see Written with help from {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Introduction_to_Object-Oriented_JavaScript|Mozilla Developer Network's Introduction to Object-Oriented JavaScript}
 */
function ScheduleItem()
{
	/** The id of the associated category */
	this.categoryId
	this.eventId;
	/** The id of the event in the hashmap */
	this.tempId;
	/** The start date and time, as a js Date() */
	this.startDateTime;
	/** The end date and time */
	this.endDateTime;
	/** The repeat type as a string */
	this.repeatType;
	/** The date the repeating starts on */
	this.startRepeatType;
	/** The date the repeating starts on */
	this.endRepeatType;
	/** An array of the repeat exceptions of this event. Does not include category level repeat exceptions */
	this.breaks = [];
	/** The name of the event */
	this.name;
	/** The event description */
	this.description;
	/** The event location */
	this.location;
	/** Whether this object has bee updated since last save */
	this.needsSaving = false;

	/** Returns an float of the length of the event in hours */
	this.lengthInHours = function()
	{
		return differenceInHours(this.startDateTime, this.endDateTime, false);
	};

	/** Returns an integer of the difference in the hours */
	this.hoursSpanned = function()
	{
		return this.endDateTime.getHours() - this.startDateTime.getHours();
	};

	/** Deletes the schedule item from the frontend */
	this.destroy = function()
	{
		this.element().slideUp("normal", function() { $(this).remove(); }); //slide up the element and remove after that is done
		delete scheduleItems[this.tempId]; //then delete from the scheduleItems map
		updatedEvents(this.tempId, "Destroy");
	};

	/**
	 * Sets a start date time for the current event
	 * @param {Date} newStartDateTime - the new start date time that should be set
	 * @param {boolean} resize - true if the object is being resized, false if the object is being moved
	 * @param {boolean} userSet - checks if the user is the one who updated the time directly
	 */
	this.setStartDateTime = function(newStartDateTime, resize, userSet) //if resize is true, we do not move the end time
	{
		if(newStartDateTime.getTime() > this.endDateTime.getTime() && userSet) //if trying to set start before end
		{
			alertUI("The event can't start after it ends!"); //throw an error unless this is a new event (blank name)
			$("#time-start").val(convertTo12Hour(currEvent.startDateTime));
		}
		else
			setDateTime(true, newStartDateTime, this, resize);

		if(userSet) // if done by the user, and not dragComplete
			updatedEvents(this.tempId, "setStartDateTime"); // indicate the event was modified, triggering autocomplete
	};

	/**
	 * Sets an end date time for the current event
	 * @param {Date} newEndDateTime - the new end date time that should be set
	 * @param {boolean} resize - true if the object is being resized, false if the object is being moved
	 * @param {boolean} userSet - checks if the user is the one who updated the time directly
	 */
	this.setEndDateTime = function(newEndDateTime, resize, userSet) //if resize, we don't move the start time
	{
		if(newEndDateTime.getTime() < this.startDateTime.getTime() && userSet) //if trying to set end before start
		{
			alertUI("The event can't end before it begins!"); //throw an error unless this is a new event
			$("#time-end").val(convertTo12Hour(currEvent.endDateTime));
		}
		else
			setDateTime(false, newEndDateTime, this, resize);

		updatedEvents(this.tempId, "setEndDateTime");
	};

	/**
	 * Changes the name of the current event
	 * @param {String} newName - the new name that should be set
	 */
	this.setName = function(newName)
	{
		if(this.name != newName) // check for changes
		{
			this.name = newName; //set the object daat
			this.element().find(".evnt-title").text(newName); //and update the HTML element
			updatedEvents(this.tempId, "setName");
		}
	};

	/**
	 * Changes the repeat type of the current event
	 * @param {String} newRepeatType - new repeat type that should be set
	 * putting here for the time being
	 * 1. these will (like the name implies) happen every day/week/month/year
	 *   `daily`, `weekly`, `monthly`, `yearly`
	 * 2. events that happen on certain days every week, string will look like this
	 *   `certain_days-<comma seperated day values>`
	 *   e.g. certain_days-1,3,5 (1,3,5 is mon wed fri)
	 * 3. events that are entirely custom are built like so
	 *   `custom-<amount>-<unit>`
	 *   e.g. custom-3-weeks (will happen every 3 weeks)
	 */
	this.setRepeatType = function(newRepeatType)
	{
		if(this.repeatType != newRepeatType) // check for changes
		{
			this.repeatType = newRepeatType;
			updatedEvents(this.tempId, "setRepeatType");
		}
	};

	/**
	 * Set the date time where the repeating should start for the current event
	 * @param {Date} newRepeatStart - where the repeating should start
	 */
	this.setRepeatStart = function(newRepeatStart)
	{
		if(this.repeatStart != newRepeatStart) // check for changes
		{
			this.repeatStart = newRepeatStart;
			updatedEvents(this.tempId, "repeatStart");
		}
	};

	/**
	 * Set the date time where the repeating should end for the current event
	 * @param {Date} newRepeatEnd - where the repeating should end
	 */
	this.setRepeatEnd = function(newRepeatEnd)
	{
		if(this.repeatEnd != newRepeatEnd) // check for changes
		{
			this.repeatEnd = newRepeatEnd;
			updatedEvents(this.tempId, "repeatEnd");
		}
	};

	/**
	 * Set the description of the current event
	 * @param {Date} newDescription - new description
	 */
	this.setDescription = function(newDescription)
	{
		if(this.description != newDescription) // check for changes
		{
			this.description = newDescription;
			updatedEvents(this.tempId, "description");
		}
	}

	/**
	 * Set the location of the current event
	 * @param {Date} newLocation - new location
	 */
	this.setLocation = function(newLocation)
	{
		if(this.location != newLocation) // check for changes
		{
			this.location = newLocation;
			updatedEvents(this.tempId, "location");
		}
	}

	/**
	 * Runs once user has stoped dragging an event, either to resize or move
	 * @param {JQuery} elem - element that was dragged
	 * @param {boolean} resize - true if the object is being resized, false if the object is being moved
	 */
	this.dragComplete = function(elem, resize)
	{
		var dateString = elem.parent().siblings(".col-titler").children(".evnt-fulldate").html();
		var hours = 0;
		if(resize)
			hours = Math.floor((parseInt(elem.css("top")))/gridHeight);
		else
			hours = (parseInt(elem.css("top")))/gridHeight;
		var newDate = new Date(dateString + " " + hours + ":" + paddedMinutes(this.startDateTime));
		this.setStartDateTime(newDate, resize);
		this.tempElement = elem;

		if(!resize) //prevent resize double firing updatedEvents
			updatedEvents(this.tempId, "dragComplete");
	};

	/**
	 * Runs once user has stoped resizing an event
	 * @param {JQuery} elem - element that has been resized
	 */
	this.resizeComplete = function(elem)
	{
		this.dragComplete(elem, true);
		var endDT = new Date(this.startDateTime.getTime());
		endDT.setHours(this.startDateTime.getHours() + Math.round(($(elem).outerHeight() + this.getMinutesOffsets()[0] - this.getMinutesOffsets()[1])/gridHeight)); // TODO: Move this crazy way of getting height in hours somewhere else (used twice)
		endDT.setMinutes(this.endDateTime.getMinutes()); //minutes can't change from resize, so keep them consistent
		this.endDateTime = endDT;
		updatedEvents(this.tempId, "resizeComplete");
	};

	/** Returns the top value based on the hours and minutes of the start */
	this.getTop = function()
	{
		var hourStart = this.startDateTime.getHours() + (this.startDateTime.getMinutes()/60);
		var height =  gridHeight * hourStart;
		return height;
	};

	/** Returns the pixel offsets caused by the minutes as an array */
	this.getMinutesOffsets = function()
	{
		var offsets = [];
		offsets.push(gridHeight*(this.startDateTime.getMinutes()/60));
		offsets.push(gridHeight*(this.endDateTime.getMinutes()/60));
		return offsets;
	};
	/** Changes height of current event based on the time it takes up */
	this.updateHeight = function()
	{
		// only update height in view mode's where size indicates duration
		if(viewMode == "week")
		{
			this.element().css("height", gridHeight*this.lengthInHours() - border);
			updatedEvents(this.tempId, "updateHeight");
		}
	};

	/** a way of getting the name that handles untitled */
	this.getHtmlName = function()
	{
		return this.name ? escapeHtml(this.name) : PLACEHOLDER_NAME;
	}

	/** Returns the HTML element for this schedule item, or elements if it is repeating */
	this.element = function()
	{
		if(viewMode == "week")
			return $(".sch-evnt[evnt-temp-id="+ this.tempId + "]");
		else if(viewMode == "month")
			return $(".sch-month-evnt[evnt-temp-id="+ this.tempId + "]");
	};

	/****************************/
	/***** HELPER FUNCTIONS *****/
	/****************************/

	/**
	 * Sets the start or end date/time for an event on a user's schedule.
	 * @param {boolean}  isStart - Whether or not the Date object being passed in is an event's starting time
	 * @param {Date}    dateTime - The date/time this event is being changed to; can be start or end date
	 * @param {string}   schItem - The jQuery selector for the schedule item being modified
	 * @param {boolean}   resize - Whether or not we are resizing the schedule item we're setting the time for
	 */
	function setDateTime(isStart, dateTime, schItem, resize)
	{
		var elem = schItem.element();

		if(isStart)
		{
			var topDT = dateTime;
			var change = differenceInHours(schItem.startDateTime, topDT); //see how much the time was changed
			var botDT = cloneDate(schItem.endDateTime);
			botDT.setHours(schItem.endDateTime.getHours() + change);
		}
		else
		{
			var botDT = dateTime;
			var change = differenceInHours(schItem.endDateTime, botDT); //see how much the time was changed
			var topDT = cloneDate(schItem.startDateTime);
			topDT.setHours(schItem.startDateTime.getHours() + change);
		}

		//console.log("Change: " + change);

		if(isStart || !resize) //only set the startDateTime if we are not resizing or starting
		{
			schItem.startDateTime = topDT;
			elem.css("top", schItem.getTop()); //set the top position by gridHeight times the hour
			elem.children(".evnt-time.top").text(convertTo12Hour(topDT)).show();
		}

		if(!isStart || !resize) //only set the bottom stuff if this is setting the end time or we are not resizing
		{
			schItem.endDateTime = botDT;
			elem.children(".evnt-time.bot").text(convertTo12Hour(botDT)).show();
		}

		elem.attr("time", topDT.getHours() + ":" + paddedMinutes(topDT)); //set the time attribute

		if(viewMode == "month")
			repopulateEvents();
		else if(viewMode == "week")
			schItem.tempElement = elem; // update temp element for later populateEvents() calls - only used by weekly view
	}

	/**
	 * Returns the difference between two given Date objects in hours, with an option of
	 * whether or not to round that result to the nearest number of hours.
	 * @param  {Date}    start - Starting date for the difference calculation
	 * @param  {Date}      end - Ending date for the difference calculation
	 * @param  {boolean} round - If true, round difference up or down to the nearest hour,
	 *                             rounding up to one if the result of the rounding is zero
	 * @return {Date}        - the difference between the two given dates, in hours
	 */
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

/**
 * Defines the class for category items.
 * @class
 */
function Category(id)
{
	this.id = id; //the id of the category in the db
	this.name; //the name of the category, as a string.
	this.color; //the color of the category, as a CSS acceptable string
	this.privacy = "private"; //the privacy of the category, right now either private || followers || public
	this.breaks = []; //an array of the repeat exceptions of this category.

	this.getHtmlName = function()
	{
		return this.name ? escapeHtml(this.name) : PLACEHOLDER_NAME;
	}
}

/**
 * The class definition for breaks and repeat exceptions.
 * @class
 */
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

/****************************/
/****** SCHEDULER INIT ******/
/****************************/

/**
 * Initializer for the Carpe scheduling page.
 * Called by the $(document).ready() function.
 * @function
 */
function scheduleReady()
{
	if (readied) return;

	//load all initial data stuff
	loadInitialBreaks();
	loadInitialCategories();
	loadInitialEvents();

	sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops
	schHTML = $("#sch-weekly-view").html(); //The HTML for the scheduler days layout, useful for when days are refreshed

	addStartingListeners(); //add the event listeners

	addDrag(); //add dragging, recursively

	colDroppable();

	addDates(new Date(), false, true);
	readied = true;

	$(".col-snap").css("height", gridHeight*24); //set drop columns
	$(".sch-day-col").css("height", gridHeight*24 + 50); //set day columns, which have the divider line

	if(readOnly) //allow viewing of all events with single click
	{
		$(".edit, #repeat, #add-break-event").remove(); //remove repeat functionality, and adding breaks
		$("#overlay-title").attr("contenteditable", "false"); //disable editing on location title and description
		$("#overlay-loc, #overlay-desc").prop('disabled', true);
		$("#time-start, #time-end").attr("readonly", true); //disable editing of time
	}

	$("#sch-save").addClass("disabled");
}

/**
 * Adds event listeners to existing elements on page load.
 * @function
 */
function addStartingListeners()
{
	// resizes textboxes to give them height based on the content inside
	$('.auto-resize-vertically').on('input', function () {
	  textareaSetHeight(this);
	});

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
			currEvent.setRepeatStart(new Date($(this).val()));
		}
		else if(id == "repeat-end")
		{
			currEvent.setRepeatEnd(new Date($(this).val()));
		}
		repopulateEvents();
	});

	$("#repeat-custom").click(function()
	{
		//highlight the newly selected option
		$("#repeat-custom-options").show();
		var num = $("#repeat-custom-number").val();
		var unit = $("#repeat-custom-unit").val();
		currEvent.setRepeatType("custom-" + num + "-" + unit);
	});

	//Show the options to select certain days
	$("#repeat-certain-days").click(function()
	{
		$("#repeat-certain-days-options").show();
		currEvent.setRepeatType("certain_days");
	});

	//Update the repeat type when changing custom repeat type details
	$("#repeat-custom-number, #repeat-custom-unit").change(function()
	{
		var num = $("#repeat-custom-number").val();
		var unit = $("#repeat-custom-unit").val();

		currEvent.setRepeatType("custom-" + num + "-" + unit);

		//repopulate this event
		repopulateEvents();
	});

	$("#repeat-certain-days-options span").click(function()
	{
		$(this).toggleClass("red");
		var daysArray = [];

		//Iterate through all active day buttons
		$("#repeat-certain-days-options span.red").each(function() {
			daysArray.push($(this).attr("data-day")); //and add their day number to the array
		});

		currEvent.setRepeatType("certain_days-" + daysArray.join(","))

		//repopulate this event
		repopulateEvents();
	});

	//Add break button click handler, which shows the overlay
	$("#create-break-inside-add-break").click(function()
	{
		showBreakCreateOverlay();
	});

	$("#manage-breaks").click(function()
	{
		setupBreakAddOverlay(true);
		UIManager.slideInShowOverlay("#break-adder-overlay-box");
	});

	$("#break-overlay-box .close").click(function()
	{
		UIManager.slideOutHideOverlay("#break-overlay-box");
	});

	$("#add-break-event, #add-break-category").click(function()
	{
		setupBreakAddOverlay();
		UIManager.slideInShowOverlay("#break-adder-overlay-box");
	});

	//Submit break button in the overaly
	$("#submit-break").click(function()
	{
		var name = $("#break-name").val();
		var startDate = $("#break-start").val();
		var endDate = $("#break-end").val();

		if(name == "" || startDate == "" || endDate == "")
			alertUI("Fill out all fields!");
		else
			createBreak(name, startDate, endDate);
	});

	//When editing category title, defocus on enter
	$(".cat-overlay-title").on("keydown",function(e){
		var key = e.keyCode || e.charCode;  // ie||others
		if(key == 13)  // if enter key is pressed
		{
			e.preventDefault();
			$(this).blur();  // lose focus
		}
	}).click(function()
	{
		if($(this).html() == PLACEHOLDER_NAME)
			$(this).text("");
	})
	.focusin(function() {
		setTimeout(highlightCurrent, 100); // highlight the whole name after focus
	})
	.focusout(function()
	{
		// If no name, set to Untitled
		if($(this).text() == "")
			$(this).html(PLACEHOLDER_NAME);

		removeHighlight();
	});

	$(".repeat-option").click(function()
	{
		//highlight the newly selected option
		$(".repeat-option").removeClass("red");
		$(this).addClass("red");

		if($(this).attr("id") != "repeat-custom") //if this isn't custom, repeat stuff
		{
			//get the text of the button
			var repType = $(this).text().toLowerCase();
			currEvent.setRepeatType(repType);
			$("#repeat-custom-options").hide(); //hide custom options
		}

		if($(this).attr("id") != "repeat-certain-days") //if this isn't custom, repeat stuff
		{
			$("#repeat-certain-days-options").hide(); //hide custom options
		}


		//repopulate this event
		repopulateEvents();
	});

	//Active action for color swatches
	$(".color-swatch").click(function()
	{
		$(".color-swatch").removeClass("selected");

		currObj = currCategory;
		currObj.color = $(this).css("background-color");
		$(this).addClass("selected");
	});

	//On click of a category privacy button
	$("#cat-privacy span").click(function()
	{
		//highlight the newly recent option
		$("#cat-privacy span").removeClass("red");
		$(this).addClass("red");

		currCategory.privacy = $(this).text().toLowerCase();
	});

	$("#time-start").change(function()
	{
		//TODO: Fix this not working across different days (try noon in your local time)

		var dateE = currEvent.startDateTime.toDateString();

		var val = $(this).val();

		dateTime = new Date(dateE+" "+val);
		if (isNaN(dateTime.getTime()))
		{
			alertUI("Start date doesn't make sense! Tried \"" + dateE + " " + val + "\"");
			return; // don't apply this new invalid time
		}

		var newDateTime = cloneDate(currEvent.startDateTime); //We don't want to modify the date, only the time, so clone the date
		newDateTime.setHours(dateTime.getHours()); //change the hours
		newDateTime.setMinutes(dateTime.getMinutes()); //change the minutes

		currEvent.setStartDateTime(newDateTime, true, true); //and set!
		currEvent.updateHeight();
	});

	$("#time-end").change(function()
	{
		//TODO: Fix this not working across different days (try noon in your local time)

		var dateE = currEvent.startDateTime.toDateString();

		var val = $(this).val();

		dateTime = new Date(dateE+" "+val);
		if (isNaN(dateTime.getTime()))
			alertUI("End date doesn't make sense! Tried \"" + dateE+" "+val + "\"");

		var newDateTime = cloneDate(currEvent.startDateTime);
		newDateTime.setHours(dateTime.getHours());
		newDateTime.setMinutes(dateTime.getMinutes());

		currEvent.setEndDateTime(newDateTime, true, true);
		currEvent.updateHeight();
	});

	$("#overlay-desc").focusin(function() {
		setTimeout(highlightCurrent, 100); // highlight the whole name after focus
	})
	.focusout(function()
	{
		currEvent.setDescription($(this).val());
		removeHighlight();
	});

	$("#overlay-loc").focusin(function() {
		setTimeout(highlightCurrent, 100); // highlight the whole name after focus
	})
	.focusout(function()
	{
		currEvent.setLocation($(this).val());
		removeHighlight();
	});

	$("#overlay-title").on("keydown",function(e){
		var key = e.keyCode || e.charCode;  // ie||others
		if(key == 13)  // if enter key is pressed
		{
			e.preventDefault();
			$(this).blur();  // lose focus
			currEvent.setName($(this).text());
		}
	})
	.focusin(function() {
		// If the name is Untitled, remove it
		if($(this).html() == PLACEHOLDER_NAME)
			$(this).text("");

		setTimeout(highlightCurrent, 100); // highlight the whole name after focus
	})
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

	$("#embed-button").click(function()
	{
		var iframeUrl = "http://www.carpe.us/schedule?iframe=true&uid=" + userId; //create the iframe URL
		var iframeCode = "<iframe src='" + iframeUrl + "' width='900px' height='600'>";

		customAlertUI("Embed your schedule!", "<input id='iframe-embed' class='text-input' type='text' style='width: 90%;'></input><br><br>");
		$("#iframe-embed").val(iframeCode);
	});


	/****************************/
	/**** RAILS HTML CLICKS *****/
	/****************************/

	//TODO - All of these that call functions with no parameters shouldn't be broken down into function lines
	//Everything that's calling functions with paremeters should be made into functions for this specifc task
	$(".sch-week-next").click(function()
	{
		moveWeek(true);
	});

	$(".sch-week-prev").click(function()
	{
		moveWeek(false);
	});

	$(".color-swatch").click(function()
	{
		changeCategoryColor(this);
	});

	$(".sch-evnt-save-cat").click(function(event)
	{
		saveCategory(event, $(this), $('#cat-overlay-box').attr('data-id')); //TODO - Remove $(this), as it's unused
	});

	$("#sch-save").click(function()
	{
		saveEvents();
	});

	$(".cat-add").click(function()
	{
		createCategory();
	});

	$("#repeat").click(function()
	{
		$('#repeat-menu').toggle();
	});

	$("#event-overlay-box .default.red").click(function()
	{
		UIManager.slideOutHideOverlay("#event-overlay-box");
		currEvent = null; // indicate there's no current event
	});

	$("#break-adder-overlay-box .close").click(function()
	{
		UIManager.slideOutHideOverlay("#break-adder-overlay-box");
	});

	$("#view-monthly").click(initializeMonthlyView);

	$("#view-weekly").click(initializeWeeklyView);

	/****************************/
	/** END RAILS HTML CLICKS ***/
	/****************************/
}

/**
 * Load user's categories from Rails-generated JSON
 * @function
 */
function loadInitialCategories()
{
	if(typeof categoriesLoaded !== 'undefined') //if categoriesLoaded is defined
	{
		for(var i = 0; i < categoriesLoaded.length; i++) //iterate through the loaded categories
		{
			var currCat = categoriesLoaded[i];

			var catInstance = new Category(currCat.id);
			catInstance.privacy = currCat.privacy;
			catInstance.color = currCat.color;
			catInstance.name = currCat.name;
			catInstance.breaks = currCat.break_ids;

			categories[catInstance.id] = catInstance;
		}
	}
}

/**
 * Load user's schedule breaks from Rails-generated JSON
 * @function
 */
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
			breakInstance.startDate = new Date(dateFromDashesToSlashes(currBreak.start));
			breakInstance.startDate.setHours(0,0,0,0); //clear any time
			breakInstance.endDate = new Date(dateFromDashesToSlashes(currBreak.end));
			breakInstance.endDate.setHours(0,0,0,0); //clear any time

			breaks[breakInstance.id] = breakInstance;
		}
	}
}

/**
 * Load user's events from Rails-generated JSON into the scheduleItems hashmap, also placing them in DOM
 * @function
 */
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
			{
				evnt.repeat_start = dateFromDashesToSlashes(evnt.repeat_start); //replace dashes with slashes, as Firefox doesn't seem to like dashes and timezones
				schItem.repeatStart = new Date(evnt.repeat_start);
			}

			if(evnt.repeat_end)
			{
				evnt.repeat_end = dateFromDashesToSlashes(evnt.repeat_end); //replace dashes with slashes, as Firefox doesn't seem to like dashes and timezones
				schItem.repeatEnd = new Date(evnt.repeat_end);
			}

			schItem.name = evnt.name;
			schItem.eventId = evnt.id;
			schItem.categoryId = evnt.category_id;
			schItem.setRepeatType(evnt.repeat);
			schItem.description = evnt.description;
			schItem.location = evnt.location;
			schItem.breaks = evnt.break_ids;
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

			clone.children(".evnt-title").text(evnt.name);
			clone.attr("time", time);
			clone.attr("event-id", evnt.id);
			clone.attr("evnt-temp-id", i); //Set the temp id
			clone.children(".evnt-desc").text(evnt.description);

			scheduleItems[i].tempElement = clone; //Store the element

			placeInSchedule(clone, scheduleItems[i].getTop(), scheduleItems[i].lengthInHours());

			eventTempId++; //increment the temp id
		}
	}
}

/**
 * Adds jQuery UI Droppable plugin onto schedule columns,
 * so that events (the draggables) can be dropped onto columns (the droppables)
 * @function
 */
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

/**
 * Adds jQuery UI Draggable plugin to element selector specified by function parameter.
 * @param {string} selector - The jQuery selector for a particular event or category on user's schedule.
 * @function
 */
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
			$(this).blur();  // lose focus, which prompts saving and all that via focusout below
		}
	})
	.focusout(function()
	{
		//so that clicking outside an event title also saves
		$(this).parent().draggable("enable");

		scheduleItems[$(this).parent().attr("evnt-temp-id")].setName($(this).text());

		if($(this).text() == "")
			$(this).html(PLACEHOLDER_NAME);

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
		editEvent($(this));
	})

	$(selector).find(".sch-evnt-close").click(function(event)
	{
		deleteEvent(event, $(this));
	});

	$(selector).find(".sch-evnt-del-cat").click(function(event)
	{
		deleteCategory(event, $(this), $(this).parent().attr("data-id"));
	});

	$(selector).find(".evnt-title").click(function(event)
	{
		editEventTitle(event, $(this));
	})
	.focusin(function() {
		// If the name is Untitled, remove it
		if($(this).html() == PLACEHOLDER_NAME)
			$(this).text("");

		setTimeout(highlightCurrent, 100); // highlight the whole name after focus
	});

	$(selector).find(".sch-evnt-edit").click(function()
	{
		editEvent($(this).parent());
	});

	$(selector).find(".sch-evnt-edit-cat").click(function(event)
	{
		event.stopImmediatePropagation();

		var categoryElement = $(this).parent();
		editCategory(categoryElement);
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

			if(inColumn($(this))) //if this is a current element
				$(this).css("opacity", 0); //hide the original while we are moving the helper

			return $copy;
		},
		start: function(event, ui)
		{
			if($(this).parent().attr("id") == "sch-tiles-inside")
				setHeight(this, ui.helper, 3);

			// if(ctrlPressed && $(this).parent().attr("id") != "sch-tiles-inside") //if this is an existing event and control is pressed
			// {
				// handleClone(this, ui);
			// }
		},
		stop: function(event, ui)  //on drag end
		{
			var newItem = false;

			if(viewMode == "week" && !inColumn($(this))) //if this event was not placed
				return; //return

			if(viewMode == "week" && $(this).css("opacity") == 1) //if opacity is 1, this is a new event
			{
				$(this).css("height", gridHeight*3 - border);
				handleNewEvent(this);
				newItem = true;
			}
			else if(viewMode == "month" && $(this).attr("data-date")) // if monthly view, check for date from being over a date tile
			{
				handleNewEvent(this);
				var currItem = scheduleItems[eventTempId - 1];
				currItem.startDateTime = new Date($(this).attr("data-date"));
				currItem.endDateTime = new Date($(this).attr("data-date"));

				// Set end time to 11:59 PM so it's easier to edit the time
				currItem.endDateTime.setHours(23);
				currItem.endDateTime.setMinutes(59);
				repopulateEvents();
			}

			$("#sch-tiles").html(sideHTML); //reset the sidebar
			$(this).css("opacity", 1); //undo the setting opacity to zero

			var tempItem = scheduleItems[$(this).attr("evnt-temp-id")];

			if(viewMode == "week")
			{
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
					repopulateEvents(); //and populate
				}
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

/**
 * Adds resize event handlers for new events on user's schedule.
 * @param {string} selector - The jQuery selector for an event on user's schedule
 */
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
					repopulateEvents(); //and populateEvents to refresh things
				}
			}
		});
	}
}

/****************************/
/**** END SCHEDULER INIT ****/
/****************************/

/****************************/
/****** EVENT HANDLERS ******/
/****************************/

//Called on event stop, aka let go
/**
 * Adjusts position of a schedule item when user is done dragging it, so that the
 * event card is in a valid place on the column (i.e., not past the top or bottom
 * bounds of the column), and snaps the event to the hourly grid on the schedule.
 * This function is called on a draggable object's stop() event, which is when
 * the user "lets go" of the draggable object.
 * @param  {string} elem - The jQuery selector for an event on user's schedule
 * @param  {Object}   ui - A jQuery object representing the draggable element
 * @see {@link http://api.jqueryui.com/draggable/#event-stop|Documentation on the jQuery Draggable stop() event}
 */
function handlePosition(elem, ui)
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

/**
 * Called when creating a clone, copying a specified element.
 * @param  {jQuery} elem - The element being copied
 * @param  {Object}   ui - UI object from jQuery drag handler
 */
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
	schItem.setRepeatType(oldItem.repeatType);
	schItem.location = oldItem.location;
	schItem.description = oldItem.description;
	schItem.tempId = eventTempId;
	scheduleItems[eventTempId] = schItem;


	eventTempId++;


	clone.removeClass("ui-draggable ui-draggable-handle ui-resizable ui-draggable-dragging"); //remove dragging stuff
	addDrag(clone); //and redo dragging
}

/**
 * Called when new events are dragged from the sidebar
 * @param {jQuery} elem - The element that was dragged
 */
function handleNewEvent(elem)
{
	var schItem = new ScheduleItem();
	schItem.startDateTime = new Date();
	schItem.startDateTime.setMinutes(0);
	schItem.endDateTime = new Date();
	schItem.endDateTime.setMinutes(0);
	schItem.name = "";
	schItem.eventId = null;
	schItem.categoryId = $(elem).attr("data-id");
	schItem.setRepeatType("");
	schItem.tempId = eventTempId;
	schItem.tempElement = $(elem);
	schItem.needsSaving = true;
	scheduleItems[eventTempId] = schItem;

	if(viewMode == "week")
	{
		$(elem).children(".evnt-title").attr("contenteditable", "true");
		$(elem).children(".evnt-title").trigger('focus');
		highlightCurrent(); // Suggests to the user to change the schedule item title by making it editable upon drop here.
		document.execCommand('delete',false,null); // Suggests to the user to change the schedule item title by making it editable upon drop here.
		$(elem).attr("evnt-temp-id", eventTempId);
		addResizing($(elem)); //since the sidebar events don't have resizing, we have to add it on stop
	}

	eventTempId++;
}

/**
 * Change time while items are being dragged or resized, and also snap to a vertical grid
 * @param {jQuery} elem - element the time is being updated on
 * @param {Object} ui - UI object from jQuery drag handler
 * @param {boolean} resize - true if resizing event, false if moving event
 */
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
	arr = convertTo12HourFromArray(arr); //then convert to 12 hour

	//set Start time
	ui.helper.children(".evnt-time.top").html(arr); //and set the helper time
	$(elem).children(".evnt-time.top").html(arr); //as well as the element

	end_arr = convertTo12HourFromArray(end_arr);
	ui.helper.children(".evnt-time.bot").html(end_arr); //and set the helper time
	$(elem).children(".evnt-time.bot").html(end_arr); //as well as the element
}

/****************************/
/**** END EVENT HANDLERS ****/
/****************************/


/**
 * Moves the calender forward or backward in time
 * (e.g. by clicking next on weekly view)
 * @param {Date} newDateObj - new date to start from
 * @param {boolean} refresh - if true, cleans off all events from scheduler
 * @param {boolean} startToday - if true starts the weekly view on the current day
 */
function addDates(newDateObj, refresh, startToday)
{
	refDate = newDateObj; //set the global date to this new
	visibleDates = []; //reset the array of visible dates

	var currDate; //the date (day of month) we'll be using to iterate
	var date = newDateObj.getDate();
	var month = newDateObj.getMonth();
	var year = newDateObj.getFullYear();
	var monthLength = daysInMonth(month + 1, year); //add 1 to month since it starts at zero
	var lastMonthLength = daysInMonth(month, year); //the last month's length


	if(viewMode == "week")
	{
		if(refresh)
		{
			$("#sch-weekly-view").html(schHTML); // Refresh the layout so that we can properly prepend and append text below here
			colDroppable();
		}

		if(startToday) //if we want to start today, just do so
			currDate = cloneDate(newDateObj);
		else //if we want to start on a Monday
		{
			startDateData = getStartDate(newDateObj);
			currDate = startDateData.startDate;
		}

		$(".sch-day-col").each(function(index, col)
		{
			$(col).attr("data-date", verboseDateToString(currDate));

			var fullDate = monthNames[currDate.getMonth()] + " " + currDate.getDate() + ", " + currDate.getFullYear();

			$(col).children(".col-titler").prepend("<div class='evnt-date'>" + currDate.getDate() + "</div> "); //prepend the numeric date (e.g. 25)
			$(col).children(".col-titler").find(".evnt-day").text(dayNames[currDate.getDay()]);
			$(col).children(".col-titler").append("<div class='evnt-fulldate'>" + fullDate + "</div>"); //append the long form date to columns

			if(currDate.toDateString() == new Date().toDateString()) //if this is today
				$(col).attr("id","sch-today");

			var visibleDateCurr = cloneDate(currDate);
			visibleDateCurr.setHours(0,0,0,0);
			visibleDates.push(visibleDateCurr);
			currDate.setDate(currDate.getDate() + 1);
		});
	}
	else if(viewMode == "month")
	{
		startDateData = getStartDate(newDateObj, true); //get start date for month

		currDate = startDateData.startDate;

		$(".sch-day-tile").remove(); //remove old tiles
		$("#sch-monthly-view #month-name").text(fullMonthNames[newDateObj.getMonth()] + " " + currDate.getFullYear());

		var oldDatesCount = 0;
		if(startDateData.lastMonth)
			oldDatesCount = lastMonthLength - currDate.getDate() + 1;

		var endOfMonth = cloneDate(newDateObj);
		endOfMonth.setDate(monthLength); //get the last day of the month
		var nextMonthDatesCount = 7 - endOfMonth.getDay(); //go to end of week
		nextMonthDatesCount = nextMonthDatesCount % 7; //and remove if it's 7 (a full week)

		var counter = 0;
		while(counter < oldDatesCount + monthLength + nextMonthDatesCount)
		{
			var tileClass = "sch-day-tile";

			if(counter < oldDatesCount && startDateData.lastMonth) //if going through dates from the last month
				tileClass = tileClass + " last-month";

			if(counter >= oldDatesCount + monthLength) //if we are going through dates from the next month
				tileClass = tileClass + " next-month";

			var todaySimple = new Date();
			todaySimple.setHours(0,0,0,0);
			if(currDate < todaySimple)
				tileClass = tileClass + " in-past";

			$("#sch-monthly-view #tiles-cont").append("<div class='" + tileClass + "' data-date='" + verboseDateToString(currDate) + "' >"
					+ "<div class='inner'>"
						+ "<div class='day-of-month'>" + currDate.getDate() + "</div>"
					+ "</div>"
				+ "</div>");

			if(currDate.toDateString() == new Date().toDateString()) //if this is today
				$(".sch-day-tile:last-of-type").attr("id","sch-today");

			currDate.setHours(0,0,0,0);
			visibleDates.push(cloneDate(currDate));
			currDate.setDate(currDate.getDate() + 1);
			counter++;
		}
	}

	populateEvents(); // After refreshing the dates, populate the...er...schedule items for this week. As you can see, the terminology still confuses some.
}

/** Initializes the monthly view calender */
function initializeMonthlyView()
{
	viewMode = "month";

	$("#view-weekly").removeClass("active");
	$("#view-monthly").addClass("active");
	$("#sch-weekly-view").hide();
	$("#sch-monthly-view").show();

	addDates(refDate, true);
}

/** Initializes the weekly view calender */
function initializeWeeklyView()
{
	viewMode = "week";

	$("#view-monthly").removeClass("active");
	$("#view-weekly").addClass("active");
	$("#sch-monthly-view").hide();
	$("#sch-weekly-view").show();

	addDates(refDate, true);
}

/**
 * Converts a month and a year to a data object
 * @param {number} month - 1(January) thru 12(December)
 * @param {number} year - e.g. 2017
 * @return {Date} date object made from year and month
 */
function daysInMonth(month,year)
{
	return new Date(year, month, 0).getDate();
}

/**
 * Gets the date the schedule starts on
 * @param {Date} dateObj - user inputed date used as a reference point to where the schedule should start
 * @param {boolean} useMonth - if true, sets date to first day of month
 * @return {Object} object consisting of the start date of an event, and if its start was in the last month
 */
function getStartDate(dateObj, useMonth)
{
	var copyDate = cloneDate(dateObj);
	if(useMonth)
		copyDate.setDate(1);

	var startDate;
	var day = copyDate.getDay();
	var date = copyDate.getDate();
	var month = copyDate.getMonth();
	var year = copyDate.getFullYear();
	var lastDatePrev = new Date(year, month, 0).getDate();
	var lastMonth = false;

	if(day == 0)
		startDate = date - 6;
	else
		startDate = date - day + 1;

	if(startDate <= 0) //if the start is in the last month
	{
		lastMonth = true;
	}

	copyDate.setDate(startDate);

	return {startDate: copyDate, lastMonth: lastMonth}
}

/** Clears events from the schedule before running populateEvents(). Used when the schedule gets updated */
function repopulateEvents()
{
	$("#sch-holder .sch-evnt, #sch-holder .sch-month-evnt").remove(); // remove week and month events
	populateEvents(); // and then populate events
}

/** Fills in events in the current week or month, loads from the scheduleItems hash */
function populateEvents()
{
	/**
	 * Place an event on the calender
	 * @param {ScheduleItem} eventObject - The Schedule event object to be placed on the schedule
	 * @param {number} visibleDate - the index of the date the event falls on in the currently visible dates
	 */
	function place(eventObject, visibleDate)
	{
		var color = categories[eventObject.categoryId].color;
		var currentElem = eventObject.tempElement.clone();

		if(viewMode == "week")
		{
			// Setup the UI element's color, text, and height to represent the schedule item
			currentElem.css("background-color", color);
			currentElem.find(".evnt-title").html(eventObject.getHtmlName());
			currentElem.find(".evnt-time.top").text(convertTo12Hour(eventObject.startDateTime));
			currentElem.find(".evnt-time.bot").text(convertTo12Hour(eventObject.endDateTime));
			currentElem.css("height", gridHeight*eventObject.lengthInHours() - border);
			currentElem.css("top", eventObject.getTop());
			currentElem.attr("evnt-temp-id", eventObject.tempId);

			// Add the event
			$(".sch-day-col:eq(" + i + ") .col-snap").append(currentElem);
		}
		else if(viewMode == "month")
		{
			var className = "";
			if(eventObject.name == "Private")
				className = " private";

			var eventId = "";
			if(eventObject.eventId)
				eventId = "event-id='" + eventObject.eventId + "'";

			var closeBtn = "";
			if(!readOnly) // close button shouldn't show up if you can't edit this schedule
				closeBtn = "<div class='close'></div>";

			$(".sch-day-tile:eq(" + i + ") .inner").append("<div class='sch-month-evnt" + className + "' evnt-temp-id='" + eventObject.tempId
				+ "' " + eventId + " data-id='" + eventObject.categoryId + "' data-hour='" + eventObject.startDateTime.getHours() + "' style='color: "
				+  color +  "; color: " + color + ";'>"
					+ "<span class='evnt-title'>" + eventObject.getHtmlName() + "</span>"
					+ "<div class='time'>"
						+ datesToTimeRange(eventObject.startDateTime, eventObject.endDateTime)
					+ "</div>"
					+ closeBtn
				+ "</div>");
		}
	}

	for (var i = 0; i < visibleDates.length; i++)
	{
		for (var eventIndex in scheduleItems) //do a foreach since this is a hashmap
		{
			eventObj = scheduleItems[eventIndex];

			var date = visibleDates[i];
			var itemDate = cloneDate(eventObj.startDateTime);

			//Handle repeatStart and endDates
			if(eventObj.repeatStart && eventObj.repeatStart > date) //if the repeatStart is later than this date, don't show
				continue;
			else if(eventObj.repeatEnd && eventObj.repeatEnd < date) //if the repeatEnd is before this date, don't show
				continue;

			var inBreak = false; //is this during a break
			//Then handle event repeat breaks

			var combinedBreaks = eventObj.breaks.concat(categories[eventObj.categoryId].breaks);

			for(var breakIndex = 0; breakIndex < combinedBreaks.length; breakIndex++) //iterate through all breaks
			{
				var currBreak = breaks[combinedBreaks[breakIndex]];
				var dateClone = cloneDate(date).setHours(0,0,0,0); //clear time on the date so time doesn't factor into breaks
				//otherwise since breaks times are the start of their day, an event on Sept. 30th at 3:00pm won't be impacted by a date
				//on Sept. 30th, since that's technically Sept. 30th 00:00

				if(currBreak.startDate <= dateClone && currBreak.endDate >= dateClone) //if the date falls in the break range
				{
					inBreak = true;
					break; //continue eventLoop;
				}
			}

			if(inBreak) //if we found that we are in a breaks
				continue; //skip to the next event

			if (itemDate.toDateString() == date.toDateString() && eventObj.repeatType.indexOf("certain_days") == -1 //if today's the event except certain days
				|| eventObj.repeatType == "daily"
				|| (eventObj.repeatType == "weekly" && date.getDay() == itemDate.getDay())
				|| (eventObj.repeatType == "monthly" && date.getDate() == itemDate.getDate())
				|| (eventObj.repeatType == "yearly" && date.getDate() == itemDate.getDate() && date.getMonth() == itemDate.getMonth()))
			{
				place(eventObj, i);
			}
			else if(eventObj.repeatType.split("-")[0] == "certain_days") //handle certain day repeats
			{
				var daysArray = eventObj.repeatType.split("-")[1];
				for(var d = 0; d < daysArray.length; d++)
				{
					if(daysArray[d] == date.getDay())
						place(eventObj, i);
				}
			}
			else if(eventObj.repeatType.split("-")[0] == "custom") //handle custom repeat types
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

	// Sort events in each monthly tile after they have been made
	if(viewMode == "month")
	{
		$(".sch-day-tile").each(function()
		{
			var monthTileEvents = $(this).find(".sch-month-evnt");
			$(this).find(".sch-month-evnt").remove();

			monthTileEvents.sort(function(a, b) {
				a = parseInt($(a).attr("data-hour"));
				b = parseInt($(b).attr("data-hour"));

				if (a > b)
					return +1;
				if (a < b)
					return -1;
				return 0;
			});

			$(this).find(".inner").append(monthTileEvents);
		});

		$(".sch-month-evnt:not(.private)").click(function()
		{
			editEvent($(this));
		});

		if(!readOnly)
		{
			$(".sch-month-evnt .close").click(function(event)
			{
				deleteEvent(event, $(this));
			});

			monthlyEventDraggable();
			monthlyTileDroppable();
		}

		/** Make each monthly event dragable (e.g. sidebar)  */
		function monthlyEventDraggable()
		{
			$(".sch-month-evnt").draggable(
			{
				containment: "#sch-holder",
				appendTo: "body",
				cancel: "img",
				revertDuration: 0,
				distance: 10,
				scroll: false,
				revert: "invalid",
				stack: ".sch-month-evnt",
				helper: function()
				{
					$copy = $(this).clone(); // copy the monthly event

					$(this).css('opacity', '0'); // hide the original

					$copy.css('width', $(this).css('width')); // set the copy's width (since % don't work without inheritance)
					$copy.css('z-index', '10'); // and increase the copy's z-index

					return $copy;
				},
				stop: function() {
					if($(this).attr('data-date')) // check for a data-date from being over a date tile
					{
						var currItem = scheduleItems[$(this).attr("evnt-temp-id")];
						var newDate = new Date($(this).attr('data-date'));
						currItem.startDateTime.setMonth(newDate.getMonth());
						currItem.startDateTime.setDate(newDate.getDate());
						currItem.startDateTime.setYear(newDate.getFullYear());
						currItem.endDateTime.setMonth(newDate.getMonth());
						currItem.endDateTime.setDate(newDate.getDate());
						currItem.endDateTime.setYear(newDate.getFullYear());
						updatedEvents(currItem.tempId, "Dragged monthly event");

						$(this).attr('data-date', ''); // remove data-date now that it's been used
					}
					repopulateEvents();
				}
			});
		}

		/** Make each monthly event dropable into the schedule (e.g. moving sidebar event into schedule)  */
		function monthlyTileDroppable() {
			$(".sch-day-tile").droppable(
			{
				drop: function( event, ui ) //called when event is dropped on a new column (not called on moving it in the column)
				{
					var element = ui.draggable;
					element.attr('data-date', $(this).attr('data-date'));
					$(this).removeClass("over"); //dehighlight on drop
				},
				over: function( event, ui )
				{
					$(this).addClass("over"); //highlight
				},
				out: function( event, ui )
				{
					$(this).removeClass("over"); //unhighlight
				}
			});
		}
	}

	if(readOnly)
	{
		$(".col-snap .sch-evnt").click(function(){
			editEvent($(this));
		});
	}
}

/**
 * Edit an event's title inline (without the overlay)
 * @param {ScheduleItem} event - item to edit title of
 * @param {JQuery} elem - element to edit title of
 */
function editEventTitle(event, elem)
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


/**
 * Edit a category using the category overlay
 * @param {JQuery} elem - category element to update
 */
function editCategory(elem)
{
	var categoryId = $(elem).attr("data-id");
	currCategory = categories[categoryId]; //set the current category

	//Select the proper privacy button
	$("#cat-privacy span").removeClass("red");
	if(currCategory.privacy)
	{
		$("#cat-privacy #" + currCategory.privacy).addClass("red");
	}

	$(".cat-overlay-title").trigger('focus');

	UIManager.slideInShowOverlay("#cat-overlay-box");

	var colForTop = currCategory.color;

	$(".cat-top-overlay").css("background-color",colForTop);

	/* if(col && col != "null") //check for null string from ruby
		$(".cat-top-overlay").css("background-color",col);
	else //if the color was null or empty remove the background-color
		$(".cat-top-overlay").css("background-color",""); */

	$(".cat-overlay-title").html(currCategory.getHtmlName());
	$("#cat-overlay-box").attr("data-id", categoryId);

	$(".color-swatch").removeClass("selected");
	$(".color-swatch").each(function() {
		if ($(this).css("background-color") == $(".cat-top-overlay").css("background-color"))
		{
			$(this).addClass("selected");
		}
	});
}

/**
 * Edit an event using the event overlay
 * @param {JQuery} elem - event element to update
 */
function editEvent(elem)
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

		//Reset all custom stuff, hiding custom options and deselecting all certain day options
		$("#repeat-custom-options").hide();
		$("#repeat-certain-days-options").hide();
		$("#repeat-certain-days-options span").removeClass("red");

		if(rep.indexOf("custom") > -1)
		{
			$("#repeat-custom").addClass("red");
			$("#repeat-custom-options").show();
			$("#repeat-custom-number").val(rep.split("-")[1]); //set the number
			$("#repeat-custom-unit").val(rep.split("-")[2]); //and the unit
		}
		else if(rep.indexOf("certain_days") > -1)
		{
			$("#repeat-certain-days").addClass("red");
			$("#repeat-certain-days-options").show();
			var daysArray = rep.split("-")[1].split(",");
			for(var i = 0; i < daysArray.length; i++)
			{
				$("#repeat-certain-days-options span[data-day=" + daysArray[i] + "]").addClass("red");
			}
		}

		$("#repeat-start").val(verboseDateToString(currEvent.repeatStart));
		$("#repeat-end").val(verboseDateToString(currEvent.repeatEnd));

		UIManager.slideInShowOverlay("#event-overlay-box");

		$("#overlay-title").html(currEvent.getHtmlName());
		$("#overlay-color-bar").css("background-color", categories[currEvent.categoryId].color);

		var desc = currEvent.description || ""; //in case the description is null
		var loc = currEvent.location || ""; //in case the location is null
		$("#overlay-desc").val(desc);
		$("#overlay-loc").val(loc);

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
		$("#time-start").val(convertTo12HourFromArray(startArr));
		$("#time-end").val(convertTo12HourFromArray(endArr));

		// resize the textareas to the appropriate size
		$('.auto-resize-vertically').each(function () {
			//check if the textbox contains a new line or else it takes up 2 unnessisary lines
		  textareaSetHeight(this);
			$(this).css('overflow-y', 'hidden');
		});
	}
}

/** Show the overlay for creating a new break */
function showBreakCreateOverlay()
{
	$("#break-overlay-box input").val(""); //clear all inputs
	UIManager.slideInShowOverlay("#break-overlay-box"); //and fade in
}

/**
 * Sets up an overlay to add breaks. If managing,
 * it is actually for editing and deleting breaks rather
 * than enabling or disabling breaks on the currente event
 * @param {boolean} managing - if true, show 'managing breaks', if false show 'adding breaks'
 */
function setupBreakAddOverlay(managing)
{
	var currObj;
	if(currEvent)
		currObj = currEvent;
	else
		currObj = currCategory;

	$("#break-cont").html(""); //clear the break container

	var checkbox = "<div class='check-box'></div>";

	if(managing)
	{
		checkbox = "";
		$("#break-adder-overlay-box h3").text("Manage Breaks");
	}
	else
	{
		$("#break-adder-overlay-box h3").text("Add Breaks");
	}

	for (var id in breaks) //do a foreach since this is a hashmap
	{
		var breakInstance = breaks[id]; //and add each break

		var classAdd = "";

		if(!managing && currObj.breaks.indexOf(parseInt(id)) > -1)
		{
			classAdd = "active"
		}


		// Prepend each break so that the most recently created break created comes first in the list
		$("#break-cont").prepend("<div class='break-elem " +  classAdd +"' data-id='" + id + "' >"
				+ checkbox
				+ breakInstance.name + " | " + dateToString(breakInstance.startDate) + " | " + dateToString(breakInstance.endDate)
			+ "</div>");
	}

	if($(".break-elem").length == 0) //if no breaks were added, there were no breaks, so show a message
	{
		$("#break-cont").append("It looks like you haven't created any repeat breaks!"
			+ "<br>Make some by pressing \"Create Break\" on your schedule!");
	}

	if(!managing)
		setupBreakClickHandlers();

	/** Sets up toggles for if the event or category has breaks enabled */
	function setupBreakClickHandlers()
	{
		$(".break-elem").click(function()
		{
			var currId = parseInt($(this).attr("data-id")); //get the id of the current break

			var currObj;
			if(currEvent)
				currObj = currEvent;
			else
				currObj = currCategory;

			if($(this).hasClass("active")) //disable this
			{
				var index = currObj.breaks.indexOf(currId);

				if(index > -1) //if this is indeed a current break
				{
					$(this).removeClass("active");
					currObj.breaks.splice(index, 1); //and remove
				}
			}
			else
			{
				$(this).addClass("active");

				currObj.breaks.push(currId);
			}

			if(currEvent)
				updatedEvents(currEvent.tempId, "breaks"); //mark that the events changed to enable saving

			repopulateEvents();
		});
	}
}

/**
 * Update the color of the category overlay from a color being picked
 * @param {JQuery} elem - element to take background color from
 */
function changeCategoryColor(elem)
{
	$(".cat-top-overlay").css("background-color",$(elem).css("background-color"));
}

/**
 * Setup properties of a place schedule item from the db, setting position and height
 * @param {JQuery} elem -
 * @param {number} hours - the height of the object is proportional to the hours
 * @param {number} lengthHours - the amount of hours an element takes up
 */
function placeInSchedule(elem, hours, lengthHours)
{
	//console.log("Length: " + lengthHours);
	$(elem).css("height", (gridHeight*lengthHours)-border); //set the height using the length in hours
	$(elem).css("top", hours); //set the top position by gridHeight times the hour
}

/**
 * Events were updated. Called by any modification of an event, which triggers auto saving
 * @param {number} eventId - id of the event being modified
 * @param {msg} string - message to show when events were updated... not currently used
 */
function updatedEvents(eventId, msg)
{
	// console.log("Events were updated!" + msg);
	$("#sch-save").removeClass("disabled");

	if(readied) // if we've loaded in intial events save. Prevents lots of saving on setup as events are dealt with
	{
		if(scheduleItems[eventId])
			scheduleItems[eventId].needsSaving = true;
		clearTimeout(saveEventsTimeout); // clear existing timeout to reset
		saveEventsTimeout = setTimeout(saveEvents, 5000); // and set new one at 5 seconds
	}
}

/****************************/
/*** JSON SERVER METHODS ****/
/****************************/

/** Saves all events */
function saveEvents()
{
	if($("#sch-save").hasClass("disabled") || $("#sch-save").hasClass("loading")) //if the save button is disabled or already saving
		return; //return

	$("#sch-save").addClass("loading"); //indicate that stuff is loading

	var scheduleItemsToSave = {};

	// TOOD: Swap needsSaving for an updatedAt timestamp and save when the last save request was sent
	// so you can use a date comparison to determine if saving is needed. This prevents having to deflag events
	// and makes sure you can mutate events during saving
	for(var eventId in scheduleItems) // iterate through schedule items to compile ones that need saving
	{
		if(scheduleItems[eventId].needsSaving) // if this event needs to be saved
			scheduleItemsToSave[eventId] = scheduleItems[eventId];
	}

	//JSON encode our hashmap
	var arr  = JSON.parse(JSON.stringify(scheduleItemsToSave));

	$.ajax({
		url: "/save_events",
		type: "POST",
		data: {map: arr, group_id: groupID},
		success: function(resp)
		{
			console.log("Save complete.");

			$("#sch-save").removeClass("loading");
			$("#sch-save").addClass("active"); //show checkmark


			//and hide it after 1.5 seconds
			setTimeout(function()
			{
				$("#sch-save").removeClass("active");
				$("#sch-save").addClass("disabled");
			}, 3000);

			for(var key in resp) // iterate through ids in the response, which specify the temp id of the event and the new DB id
			{
				$(".sch-evnt[evnt-temp-id="+ key + "]")	.attr("event-id", resp[key]);
				scheduleItems[key].eventId = resp[key];
			}
		},
		error: function(resp)
		{
			alertUI("Saving events failed :(");
		}
	});
}

/**
 * Deletes an event
 * @param {Event} event - event from preforming an action... stops propagation of this event
 * @param {JQuery} elem -element to delete
 */
function deleteEvent(event, elem)
{
	event.stopImmediatePropagation();

	var tempId = $(elem).parent().attr("evnt-temp-id");
	var schItem = scheduleItems[tempId];

	if(schItem.repeatType && schItem.repeatType != "none")
	{
		// Show the event deletion overlay for repeating elements
		UIManager.showOverlay();
		UIManager.slideIn("#evnt-delete.overlay-box");

		$("#evnt-delete.overlay-box .default").off(); // remove events from buttons

		$("#evnt-delete.overlay-box #single-evnt").click(deleteSingleEvent);
		$("#evnt-delete.overlay-box #all-evnts").click(deleteEventProper);

		// On cancel just hide overlay
		$("#evnt-delete.overlay-box .close, #evnt-delete.overlay-box #cancel").click(function()
		{
			UIManager.slideOutHideOverlay("#evnt-delete.overlay-box");
		});
	}
	else
	{
		confirmUI("Are you sure you want to delete this event?", deleteEventProper);
	}

	/** Deletes a single event among a repeating set by making a new repeat break and applying it */
	function deleteSingleEvent()
	{
		var tempId = $(elem).parent().attr("evnt-temp-id");
		var event = scheduleItems[tempId];

		var breakDateString;
		if(viewMode == "week")
			breakDateString = $(elem).parents(".sch-day-col").attr("data-date");
		else if(viewMode == "month")
			breakDateString = $(elem).parents(".sch-day-tile").attr("data-date");

		if(!breakDateString) // if the date string is undefined, return to prevent further errors
			return;

		// Format auto made break names as "No _event-name_ On _date_"
		// e.g. 'No Baseball Training On 9/27/17'
		var breakTitle = "No " + schItem.name + " On " + breakDateString;

		var newBreakId;

		// Check for existing break with this name to see if it was made
		for(var breakId in breaks)
		{
			if(breaks[breakId].name == breakTitle)
				newBreakId = breakId;
		}

		// If we didn't find an existing break with that name, make one
		if(typeof newBreakId == "undefined")
		{
			createBreak(breakTitle, breakDateString, breakDateString, function(newBreak)
			{
				newBreakId = newBreak.id;
				applyNewBreak(); // apply new break after server responds with our break ID
			});
		}
		else
		{
			applyNewBreak();
		}

		// Add the new break to the schedule item and repopulate the schedule to apply it
		function applyNewBreak()
		{
			// Now that we have a break that will make this event be skipped, add it and update UI accordingly
			schItem.breaks.push(newBreakId);

			updatedEvents(schItem.tempId, "breaks"); //mark that the events changed to enable saving

			repopulateEvents();

			UIManager.slideOutHideOverlay("#evnt-delete.overlay-box");
		}
	}

	/** Deletes the associated event object, like the old delete. This gets rid of all items repeating */
	function deleteEventProper()
	{
		var eId = $(elem).parent().attr("event-id");
		var tempId = $(elem).parent().attr("evnt-temp-id");

		if(viewMode == "week")
			$(".sch-evnt[evnt-temp-id='" + tempId + "']").slideUp("normal", function() {$(this).remove();});
		else if(viewMode == "month")
			$(".sch-month-evnt[evnt-temp-id='" + tempId + "']").slideUp("normal", function() {$(this).remove();});

		delete scheduleItems[tempId]; //remove event map

		UIManager.slideOutHideOverlay("#evnt-delete.overlay-box");

		if(!eId) // if no event, this event has not been saved, so no ajax is needed to delete it
			return;

		$.ajax({
			url: "/delete_event",
			type: "POST",
			data: {id: eId, group_id: groupID},
			success: function(resp)
			{
				console.log("Delete complete.");
			},
			error: function(resp)
			{
				alertUI("Deleting event failed :/");
			}
		});
	}
}

/** Creates category */
function createCategory()
{
	$.ajax({
		url: "/create_category",
		type: "POST",
		data: {name: "", user_id: userId, group_id: groupID, color: "silver"},
		success: function(resp)
		{
			console.log("Create category complete.");

			var newCat = $("#cat-template").clone();
			$("#sch-tiles-inside").append(newCat);
			newCat.show();
			newCat.attr("data-id", resp.id);
			newCat.attr("privacy", "private");
			newCat.find(".evnt-title").html(resp.name || PLACEHOLDER_NAME);
			newCat.attr("id", "");
			addDrag();
			// TODO - Make saving the sideHTML a function, as this line is called so many times
			sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops

			var catInstance = new Category(resp.id);
			catInstance.color = "silver";
			catInstance.privacy = "private";
			categories[catInstance.id] = catInstance;

			// By default, the 'edit category' overlay will appear when creating new categories.
			editCategory(newCat);
		},
		error: function(resp)
		{
			alertUI("Creating category failed :(");
		}
	});
}

/**
 * Deletes category
 * @param {Event} event - event from action
 * @param {Jquery} elem - element of category to be deleted
 * @param {number} id - id of data in element to remove from database
 */
function deleteCategory(event, elem, id)
{
	confirmUI("Are you sure you want to delete this category?", function(confirmed)
	{
		$.ajax({
			url: "/delete_category",
			type: "POST",
			data: {id: id, group_id: groupID},
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
				alertUI("Deleting category failed :(");
			}
		});
	});
}

/**
 * Saves Category
 * @param {Event} event - event from action
 * @param {Jquery} elem - element of category to be saved
 * @param {number} id - id of data in element to add to database
 */
function saveCategory(event,elem,id)
{
	// uses dom to determine if the category has been given an actual name.
	var categoryName = ( $(".cat-overlay-title").html() === PLACEHOLDER_NAME ? "" : $(".cat-overlay-title").text());

	$.ajax({
		url: "/create_category",
		type: "POST",
		data: {name: categoryName, id: id, color: $(".cat-top-overlay").css("background-color"),
			privacy: currCategory.privacy, breaks: currCategory.breaks, group_id: groupID},
		success: function(resp)
		{
			console.log("Update category complete.");

			// TODO - Literally what is this doing? These should be functions
			currCategory.name = $(".cat-overlay-title").text();
			$("#sch-sidebar .sch-evnt[data-id=" + id + "]").find(".evnt-title").html($(".cat-overlay-title").html()); //Update name in sidebar
			$(".sch-evnt[data-id=" + id + "]").css("background-color", $(".cat-top-overlay").css("background-color")); //Update color of events
			sideHTML = $("#sch-tiles").html(); //the sidebar html for restoration upon drops

			UIManager.slideOutHideOverlay("#cat-overlay-box"); // Hide category editing panel
			currCategory = null; // and indicate there's no current category
		},
		error: function(resp)
		{
			alertUI("Updating category failed :(");
		}
	});
}

/**
 * Creates a new break
 * @param {String} name - name of break
 * @param {Date} startDate - start date for the break
 * @param {Date} endDate - end date for the break
 * @param {function} callback - once the date has been created run this function
 */
function createBreak(name, startDate, endDate, callback)
{
	// console.log("Make the break: " + name + ", " + startDate + ", " + endDate);
	var startD = new Date(startDate);
	startD.setHours(0,0,0,0); //clear any time
	var endD = new Date(endDate);
	endD.setHours(0,0,0,0); //clear any time

	$.ajax({
		url: "/create_break",
		type: "POST",
		data: {name: name, start: startD, end: endD, group_id: groupID},
		success: function(resp) //server responds with the id
		{
			var brk = new Break(); //create a new break instance
			brk.id = resp;
			brk.name = name;
			brk.startDate = startD;
			brk.endDate = endD;
			breaks[brk.id] = brk; //and add to the hashmap

			UIManager.slideOutHideOverlay("#break-overlay-box"); // hide break create panel

			// if the adding break UI is visible, update it
			var addingBreakUiIsVisible = $("#break-adder-overlay-box").is(":visible");

			if (addingBreakUiIsVisible) {
				setupBreakAddOverlay();
			}

			// Call the callback and pass in the new break
			if(callback)
				callback(brk);
		},
		error: function(resp)
		{
			alertUI("Creating break failed! :(");
		}
	});
}

/****************************/
/* END JSON SERVER METHODS **/
/****************************/

/****************************/
/***** HELPER METHODS *******/
/****************************/

/**
 * Converts a date from 24 hour to 12 hour time string format
 * @param {Date} date - date to convert to 12 hour time format
 * @return {String} date in 12 hour time format
 */
function convertTo12Hour(date)
{
	var timeArr = [date.getHours(), paddedMinutes(date)]; //and reset the field
	return convertTo12HourFromArray(timeArr);
}

/**
 * Converts a date from time array to 12 hour time string format
 * @param {Array} timeArr - array to convert to 12 hour time format
 * @return {String} date in 12 hour time format
 */
function convertTo12HourFromArray(timeArr)
{
	if(timeArr[0] >= 12)
	{
		if(timeArr[0] > 12)
			timeArr[0] -= 12;

		if(timeArr[0] == 0)
			timeArr[0] = "00";

		return timeArr.join(":") + " PM";
	}
	else
	{
		if(timeArr[0] == 0)
			timeArr[0] = 12;

		if(timeArr[0] == 0)
			timeArr[0] = "00";

		return timeArr.join(":") + " AM";
	}
}

/**
 * Checks whether the element is in a schedule column (basically has it been placed in the schedule)
 * @param {JQuery} elem - element to check
 * @return {boolean} true if element is in schedule, false if not
 */
function inColumn(elem)
{
	var class_data = elem.parent().attr("class"); //get the parent's class data
	if(class_data && (class_data.indexOf("col-snap evt-snap") > -1 || class_data.indexOf("inner") > -1)) //and check for col-snap evt-snap
		return true;
	else
		return false;
}

/**
 * Set the height of an element if the height of another element
 * is not a proper height (divisible by gridheight)
 * @param {JQuery} getElem - element to check the height of
 * @param {JQuery} setElem - element to set height of
 * @param {number} hoursLength - hours to set the height too
 */
function setHeight(getElem, setElem, hoursLength)
{
	var height = parseFloat($(getElem).css("height"));
	if((height+border)%gridHeight != 0)
		$(setElem).css("height", (gridHeight*hoursLength)-border);
}

/**
 * Returns the minutes of a date
 * @param {Date} date - date to get minutes from
 * @return {String} minutes in padded form (e.g. 03 instead of just 3)
 */
function paddedMinutes(date)
{
	var minutes = (date.getMinutes() < 10? '0' : '') + date.getMinutes(); //add zero the the beginning of minutes if less than 10
	return minutes;
}

/**
 * Zero pads a number to two digits
 * @param {number} num - number to be zero padded
 * @return {String} zero padded number (e.g. 3 to 03 or 13 to 13)
 */
function paddedNumber(num)
{
	var paddedNum = (num < 10? '0' : '') + num; //add zero the the beginning of minutes if less than 10
	return paddedNum;
}

/** Removes cursor highlight on page */
function removeHighlight()
{
	window.getSelection().removeAllRanges();
}

/** Highlight the entirety of the field currently selected (that the user has cursor in).
 * Runs HTMLInputElement.select if an input is in focus, otherwise runs 'selectAll' on document.
 */
function highlightCurrent()
{
	if($("textarea:focus").length > 0 || $("input:focus").length > 0)
		$(":focus").select();
	else
		document.execCommand('selectAll',false,null);
}

/**
 * Creates a clone of the date
 * @param {Date} date - date to clone
 * @return {Date} clone of date
 */
function cloneDate(date)
{
	return new Date(date.getTime());
}

/**
 * Updates a textarea element's height based on the content passed to display in it.
 * Used specifically for event editing on My Schedule, this will update the size of the
 * description or location text area height dependent on content.
 * @param {Jquery} elem - The textarea element in question.
 */
function textareaSetHeight(elem)
{
	$(elem).attr('rows', 1);
	$(elem).height('auto').height(elem.scrollHeight);
}

/**
 * Converts a date string from dashes to slashes (e.g. 2016-10-25 to 2016/10/25).
 * This is needed as browsers don't like dash date formats much, but it's how Ruby prints dates by default.
 * On Chrome, dashes with dates are interpreted as the ISO format, and are used in UTC, while Firefox just refuses the date at all.
 * @param {String} dateString - date with slashes
 * @return {String} date without slashes
 */
function dateFromDashesToSlashes(dateString)
{
	return dateString.split("-").join("/");
}

/**
 * Convert a date into a string without zero padding
 * @param {Date} date - date to be converted to string
 * @return {String} date in the standard string format, with no zero padding in M/D/YY format (e.g. 6/2/16)
 */
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

/**
 * Convert a date into a string with zero padding
 * @param {Date} date - date to be converted to string
 * @return {String} date string in the format of MM/DD/YYYY, always printing zero padding if needed (e.g. 06/02/2016)
 */
function verboseDateToString(date)
{
	if(!date || !(date instanceof Date)) //if the date is null or not a date object
		return null; //return null

	if(isNaN(date.getTime())) //if invalid date
		return "INVALID!"; //return invalid string

   var yearStr = date.getFullYear().toString();
   var monthStr = (date.getMonth()+1).toString(); // getMonth() is zero-based
   var dateStr  = date.getDate().toString();

   return (monthStr[1]?monthStr:"0"+monthStr[0]) + "/" + (dateStr[1]?dateStr:"0"+dateStr[0]) + "/" + yearStr; // padding
}

/**
 * Converts a date from 24 hour to 12 hour time string format
 * @param {Date} date - date to convert to 12 hour time format
 * @return {String} date in 12 hour time format
 */
function dateToTimeString(date)
{
	return convertTo12Hour(date);
}

/**
 * Takes to dates and makes a string to express the range between them
 * @param {Date} startDate - start date
 * @param {Date} endDate - end date
 * @return {String} date range (e.g. 12:00AM to 3:00PM)
 */
function datesToTimeRange(startDate, endDate)
{
	return dateToTimeString(startDate) + " to " + dateToTimeString(endDate);
}

/****************************/
/*** END HELPER METHODS *****/
/****************************/

/****************************/
/**** HTML TIED METHODS *****/
/****************************/

/**
 * Used by the next and previous buttons to change the part of the schedule being shown
 * If forward is true, the schedules moves forward one week, otherwise back one week
 * Worth noting that when the schedule loads, the first day is the current day, not the Monday of that week
 * so that case is accounted for to move the schedule forward to the next Monday
 * @param {boolean} forward - true if the forward button was pressed
 */
function moveWeek(forward)
{
	var newDate;
	var dateDelta = 0; //the number of days to change by
	var monthDelta = 0; //the number of months to change by

	if(viewMode == "month")
		monthDelta = 1;
	else if(viewMode == "week")
		dateDelta = 7;

	if(forward) //if next button
		newDate = new Date(refDate.getYear()+1900, refDate.getMonth() + monthDelta, refDate.getDate() + dateDelta)
	else //otherwise
	{
		 //if we are looking at today but the first day is not monday
		if(new Date($("#week-date").val()).toDateString() == new Date().toDateString() && !$(".evnt-day").text().startsWith("Monday") && viewMode == "week")
			newDate = new Date(); //see this full week
		else //otherwise
			newDate = new Date(refDate.getYear()+1900, refDate.getMonth() - monthDelta, refDate.getDate() - dateDelta); //go to one week previous
	}
	addDates(newDate, true); //move back, but do not force today

	//And update the date thing. Recall that javascript get month starts at 0 with January, so we append 1 for humans
	$("#week-date").val(verboseDateToString(newDate));
}

/****************************/
/***** END HTML METHODS *****/
/****************************/
