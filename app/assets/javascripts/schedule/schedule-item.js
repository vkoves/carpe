/* Disable no-unsued-vars since this file is meant for exporting */
/* eslint no-unused-vars: "off" */

/* Setup globals from _schedule.html.erb <script> block */
/* global readOnly, groupID */

/* Setup globals from schedule.js */
/* global scheduleItems, updatedEvents, BORDER_WIDTH, cloneDate, convertTo12Hour,
          currEvent, GRID_HEIGHT, paddedMinutes, PLACEHOLDER_NAME, repopulateEvents,
          updatedEvents, viewMode  */

/**
 * Defines the class for schedule items.
 * @class
 * @see Written with help from {@link https://developer.mozilla.org/en-US/docs/Web/JavaScript/Introduction_to_Object-Oriented_JavaScript|Mozilla Developer Network's Introduction to Object-Oriented JavaScript}
 */
function ScheduleItem() {
  /** The id of the associated category */
  this.categoryId = undefined;
  this.eventId = undefined;
  /** The id of the event in the hashmap */
  this.tempId = undefined;
  /** If this is a hosted event, this is the event ID of the host event **/
  this.baseEventId = null;
  /** The start date and time, as a js Date() */
  this.startDateTime = undefined;
  /** The end date and time */
  this.endDateTime = undefined;
  /** The repeat type as a string */
  this.repeatType = undefined;
  /** The date the repeating starts on */
  this.startRepeatType = undefined;
  /** The date the repeating starts on */
  this.endRepeatType = undefined;
  /** An array of the repeat exceptions of this event. Does not include category level repeat exceptions */
  this.breaks = [];
  /** The name of the event */
  this.name = undefined;
  /** The event description */
  this.description = undefined;
  /** The event location */
  this.location = undefined;
  /** The group an event belongs to */
  this.groupId = groupID;
  /** Whether this object has bee updated since last save */
  this.needsSaving = false;
  /** This is only relevant to hosted events. It overrides normal category privacy */
  this.hostEventPrivacy = undefined;

  /**
   * Returns whether this is a hosted event - an event the current user was
   * invited to.
   * @return {booelan} Whether this event is a hosted event or not
   */
  this.isHosted = function() {
    return this.baseEventId !== null;
  };

  /**
   * Returns true if this specific event instance can be modified by the client.
   * @return {boolean} True the event can be modified, false otherwise.
   */
  this.isEditable = function() {
    return !readOnly && !this.isHosted();
  };

  /**
   * Returns true if this event hasn't been saved to the server, false otherwise.
   * @return {boolean} True the event is unsaved, false if it's saved
   */
  this.isTemporary = function() {
    return this.eventId === undefined || this.eventId === null;
  };

  /**
   * Returns an float of the length of the event in hours
   * @return {number} The float length of the event in hours
   */
  this.lengthInHours = function() {
    return differenceInHours(this.startDateTime, this.endDateTime, false);
  };

  /**
   * Returns an integer of the difference in the hours
   * @return {number} The difference in hours of the event's start and end times
   */
  this.hoursSpanned = function() {
    return this.endDateTime.getHours() - this.startDateTime.getHours();
  };

  /**
   * Deletes the schedule item from the frontend
   * @return {undefined}
   */
  this.destroy = function() {
    // slide up the element and remove after that is done
    this.element().slideUp('normal', function() { $(this).remove(); });
    delete scheduleItems[this.tempId]; // then delete from the scheduleItems map
    updatedEvents(this.tempId, 'Destroy');
  };

  /**
   * Sets a start date time for the current event
   * @param {Date} newStartDateTime - the new start date time that should be set
   * @param {boolean} resize - true if the object is being resized, false if the object is being moved
   * @param {boolean} userSet - checks if the user is the one who updated the time directly
   * @return {undefined}
   */
  this.setStartDateTime = function(newStartDateTime, resize, userSet) {
    // if resize is true, we do not move the end time
    // if trying to set start before end
    if (newStartDateTime.getTime() > this.endDateTime.getTime() && userSet) {
      alertUI('The event can\'t start after it ends!'); // throw an error unless this is a new event (blank name)
      $('#time-start').val(convertTo12Hour(currEvent.startDateTime));
    } else {
      setDateTime(true, newStartDateTime, this, resize);
    }

    // if done by the user, and not dragComplete
    if (userSet) {
      updatedEvents(this.tempId, 'setStartDateTime'); // indicate the event was modified, triggering autocomplete
    }
  };

  /**
   * Sets an end date time for the current event
   * @param {Date} newEndDateTime - the new end date time that should be set
   * @param {boolean} resize - true if the object is being resized, false if the object is being moved
   * @param {boolean} userSet - checks if the user is the one who updated the time directly
   * @return {undefined}
   */
  // if resize, we don't move the start time
  this.setEndDateTime = function(newEndDateTime, resize, userSet) {
    // if trying to set end before start
    if (newEndDateTime.getTime() < this.startDateTime.getTime() && userSet) {
      alertUI('The event can\'t end before it begins!'); // throw an error unless this is a new event
      $('#time-end').val(convertTo12Hour(currEvent.endDateTime));
    } else {
      setDateTime(false, newEndDateTime, this, resize);
    }

    updatedEvents(this.tempId, 'setEndDateTime');
  };

  /**
   * Changes the name of the current event
   * @param {String} newName - the new name that should be set
   * @return {undefined}
   */
  this.setName = function(newName) {
    // check for changes
    if (this.name != newName) {
      this.name = newName; // set the object daat
      this.element().find('.evnt-title').text(newName); // and update the HTML element
      updatedEvents(this.tempId, 'setName');
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
   * @return {undefined}
   */
  this.setRepeatType = function(newRepeatType) {
    if (this.repeatType != newRepeatType) {
      this.repeatType = newRepeatType;
      updatedEvents(this.tempId, 'setRepeatType');
    }
  };

  /**
   * Set the date time where the repeating should start for the current event
   * @param {Date} newRepeatStart - where the repeating should start
   * @return {undefined}
   */
  this.setRepeatStart = function(newRepeatStart) {
    if (this.repeatStart != newRepeatStart) {
      this.repeatStart = newRepeatStart;
      updatedEvents(this.tempId, 'repeatStart');
    }
  };

  /**
   * Set the date time where the repeating should end for the current event
   * @param {Date} newRepeatEnd - where the repeating should end
   * @return {undefined}
   */
  this.setRepeatEnd = function(newRepeatEnd) {
    if (this.repeatEnd != newRepeatEnd) {
      this.repeatEnd = newRepeatEnd;
      updatedEvents(this.tempId, 'repeatEnd');
    }
  };

  /**
   * Set the description of the current event
   * @param {Date} newDescription - new description
   * @return {undefined}
   */
  this.setDescription = function(newDescription) {
    if (this.description != newDescription) {
      this.description = newDescription;
      updatedEvents(this.tempId, 'description');
    }
  };

  /**
   * Set the location of the current event
   * @param {Date} newLocation - new location
   * @return {undefined}
   */
  this.setLocation = function(newLocation) {
    if (this.location != newLocation) {
      this.location = newLocation;
      updatedEvents(this.tempId, 'location');
    }
  };

  /**
   * set the category id for this event
   * @param {Date} newCategoryId - new category ID
   * @return {undefined}
   */
  this.setCategory = function(newCategoryId) {
    if (this.categoryId != newCategoryId) {
      this.categoryId = newCategoryId;
      updatedEvents(this.tempId, 'category');
    }
  };

  /**
   * Runs once user has stoped dragging an event, either to resize or move
   * @param {jQuery} elem - element that was dragged
   * @param {boolean} resize - true if the object is being resized, false if the object is being moved
   * @return {undefined}
   */
  this.dragComplete = function(elem, resize) {
    var dateString = elem.parent().siblings('.col-titler').children('.evnt-fulldate').html();
    var hours = 0;
    if (resize) {
      hours = Math.floor((parseInt(elem.css('top'))) / GRID_HEIGHT);
    } else {
      hours = (parseInt(elem.css('top'))) / GRID_HEIGHT;
    }
    var newDate = new Date(dateString + ' ' + hours + ':' + paddedMinutes(this.startDateTime));
    this.setStartDateTime(newDate, resize);
    this.tempElement = elem;

    // prevent resize double firing updatedEvents
    if (!resize) {
      updatedEvents(this.tempId, 'dragComplete');
    }
  };

  /**
   * Runs once user has stoped resizing an event
   * @param {jQuery} elem - element that has been resized
   * @return {undefined}
   */
  this.resizeComplete = function(elem) {
    this.dragComplete(elem, true);
    var endDT = new Date(this.startDateTime.getTime());
    endDT.setHours(this.startDateTime.getHours() + Math.round(($(elem).outerHeight() + this.getMinutesOffsets()[0] - this.getMinutesOffsets()[1]) / GRID_HEIGHT)); // TODO: Move this crazy way of getting height in hours somewhere else (used twice)
    endDT.setMinutes(this.endDateTime.getMinutes()); // minutes can't change from resize, so keep them consistent
    this.endDateTime = endDT;
    updatedEvents(this.tempId, 'resizeComplete');
  };

  /**
   * Returns the top value based on the hours and minutes of the start
   * @return {number} The top value, in pixels, of the event
   */
  this.getTop = function() {
    var hourStart = this.startDateTime.getHours() + (this.startDateTime.getMinutes() / 60);
    var height = GRID_HEIGHT * hourStart;
    return height;
  };

  /**
   * Returns the pixel offsets caused by the minutes as an array
   * @return {number} The number of pixels off the event is from it's starting hour
   */
  this.getMinutesOffsets = function() {
    var offsets = [];
    offsets.push(GRID_HEIGHT * (this.startDateTime.getMinutes() / 60));
    offsets.push(GRID_HEIGHT * (this.endDateTime.getMinutes() / 60));
    return offsets;
  };
  /**
   * Changes height of current event based on the time it takes up
   *  @return {undefined}
   */
  this.updateHeight = function() {
    // only update height in view mode's where size indicates duration
    if (viewMode == 'week') {
      this.element().css('height', GRID_HEIGHT * this.lengthInHours() - BORDER_WIDTH);
      updatedEvents(this.tempId, 'updateHeight');
    }
  };

  /**
   * A way of getting the name that handles untitled
   * @return {String} The event name (or the placeholder name if no title)
   */
  this.getHtmlName = function() {
    return this.name ? escapeHtml(this.name) : PLACEHOLDER_NAME;
  };

  /**
   * Returns the HTML element for this schedule item, or elements if it is repeating
   * @return {jQuery} The jQuery element for the object
   */
  this.element = function() {
    if (viewMode == 'week') {
      return $('.sch-evnt[evnt-temp-id=' + this.tempId + ']');
    } else if (viewMode == 'month') {
      return $('.sch-month-evnt[evnt-temp-id=' + this.tempId + ']');
    }
  };

  // -----------------------------------
  // HELPER FUNCTIONS
  // -----------------------------------

  /**
   * Sets the start or end date/time for an event on a user's schedule.
   * @param {boolean}  isStart - Whether or not the Date object being passed in is an event's starting time
   * @param {Date}    dateTime - The date/time this event is being changed to; can be start or end date
   * @param {string}   schItem - The jQuery selector for the schedule item being modified
   * @param {boolean}   resize - Whether or not we are resizing the schedule item we're setting the time for
   * @return {undefined}
   */
  function setDateTime(isStart, dateTime, schItem, resize) {
    var elem = schItem.element();
    var topDT, botDT, change;

    if (isStart) {
      topDT = dateTime;
      change = differenceInHours(schItem.startDateTime, topDT); // see how much the time was changed
      botDT = cloneDate(schItem.endDateTime);
      botDT.setHours(schItem.endDateTime.getHours() + change);
    } else {
      botDT = dateTime;
      change = differenceInHours(schItem.endDateTime, botDT); // see how much the time was changed
      topDT = cloneDate(schItem.startDateTime);
      topDT.setHours(schItem.startDateTime.getHours() + change);
    }

    // console.log("Change: " + change);

    // only set the startDateTime if we are not resizing or starting
    if (isStart || !resize) {
      schItem.startDateTime = topDT;
      elem.css('top', schItem.getTop()); // set the top position by GRID_HEIGHT times the hour
      elem.children('.evnt-time.top').text(convertTo12Hour(topDT)).show();
    }

    // only set the bottom stuff if this is setting the end time or we are not resizing
    if (!isStart || !resize) {
      schItem.endDateTime = botDT;
      elem.children('.evnt-time.bot').text(convertTo12Hour(botDT)).show();
    }

    elem.attr('time', topDT.getHours() + ':' + paddedMinutes(topDT)); // set the time attribute

    if (viewMode == 'month') {
      repopulateEvents();
    } else if (viewMode == 'week') {
      schItem.tempElement = elem; // update temp element for later populateEvents() calls - only used by weekly view
    }
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
  function differenceInHours(start, end, round) {
    var one_hour = 1000 * 60 * 60; // 1000 ms/sec * 60 sec/min * 60 min/hr
    var diff = end.getTime() - start.getTime();
    if (round) {
      var roundDiff = Math.round(diff / one_hour);
      if (roundDiff == 0) {
        roundDiff = 1;
      }
      return roundDiff;
      // Math.round(diff/one_hour);
    } else {
      return diff / one_hour;
    }
  }
}
