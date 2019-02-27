/* Disable no-unsued-vars since this file is meant for exporting */
/* eslint no-unused-vars: "off" */

/**
 * Converts a date from 24 hour to 12 hour time string format
 * @param {Date} date - date to convert to 12 hour time format
 * @return {String} date in 12 hour time format
 */
function convertTo12Hour(date) {
  var timeArr = [date.getHours(), paddedMinutes(date)]; // and reset the field
  return convertTo12HourFromArray(timeArr);
}

/**
 * Converts a date from time array to 12 hour time string format
 * @param {Array} timeArr - array to convert to 12 hour time format
 * @return {String} date in 12 hour time format
 */
function convertTo12HourFromArray(timeArr) {
  if (timeArr[0] >= 12) {
    if (timeArr[0] > 12) { timeArr[0] -= 12; }
    if (timeArr[0] == 0) { timeArr[0] = '00'; }

    return timeArr.join(':') + ' PM';
  } else {
    if (timeArr[0] == 0) { timeArr[0] = 12; }
    if (timeArr[0] == 0) { timeArr[0] = '00'; }

    return timeArr.join(':') + ' AM';
  }
}


/**
 * Returns the minutes of a date
 * @param {Date} date - date to get minutes from
 * @return {String} minutes in padded form (e.g. 03 instead of just 3)
 */
function paddedMinutes(date) {
  var minutes = (date.getMinutes() < 10 ? '0' : '') + date.getMinutes(); // add zero the the beginning of minutes if less than 10
  return minutes;
}

// /**
//  * Zero pads a number to two digits.
//  *
//  * @param {number} num - number to be zero padded
//  * @return {String} zero padded number (e.g. 3 to 03 or 13 to 13)
//  */
// function paddedNumber(num) {
//   var paddedNum = (num < 10 ? '0' : '') + num; // add zero the the beginning of minutes if less than 10
//   return paddedNum;
// }

/**
 * Removes cursor highlight on page
 * @return {undefined}
 */
function removeHighlight() {
  window.getSelection().removeAllRanges();
}

/**
 * Highlight the entirety of the field currently selected (that the user has cursor in).
 * Runs HTMLInputElement.select if an input is in focus, otherwise runs 'selectAll' on document.
 * @return {undefined}
 */
function highlightCurrent() {
  if ($('textarea:focus').length > 0 || $('input:focus').length > 0) {
    $(':focus').select();
  } else {
    document.execCommand('selectAll', false, null);
  }
}

/**
 * Creates a clone of the date
 * @param {Date} date - date to clone
 * @return {Date} clone of date
 */
function cloneDate(date) {
  return new Date(date.getTime());
}

/**
 * Updates a textarea element's height based on the content passed to display in it.
 * Used specifically for event editing on My Schedule, this will update the size of the
 * description or location text area height dependent on content.
 * @param {jQuery} elem - The textarea element in question.
 * @return {undefined}
 */
function textareaSetHeight(elem) {
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
function dateFromDashesToSlashes(dateString) {
  return dateString.split('-').join('/');
}

/**
 * Convert a date into a string without zero padding
 * @param {Date} date - date to be converted to string
 * @return {String} date in the standard string format, with no zero padding in M/D/YY format (e.g. 6/2/16)
 */
function dateToString(date) {
  if (!date || !(date instanceof Date)) {
    return null;
  }

  // if invalid date
  if (isNaN(date.getTime())) {
    return 'INVALID!';
  }

  var dateString = (date.getMonth() + 1); // start with the month. JS gives the month from 0 to 11, so we add one
  dateString = dateString + '/' + date.getDate(); // then add a / plus the date
  dateString = dateString + '/' + ('' + date.getFullYear()).slice(-2); // then get the last two digits of the year by converting to string and slicing
  return dateString;
}

/**
 * Convert a date into a string with zero padding
 * @param {Date} date - date to be converted to string
 * @return {String} date string in the format of MM/DD/YYYY, always printing zero padding if needed (e.g. 06/02/2016)
 */
function verboseDateToString(date) {
  if (!date || !(date instanceof Date)) {
    return null;
  }

  // if invalid date
  if (isNaN(date.getTime())) {
    return 'INVALID!';
  }

  var yearStr = date.getFullYear().toString();
  var monthStr = (date.getMonth() + 1).toString(); // getMonth() is zero-based
  var dateStr = date.getDate().toString();

  return (monthStr[1] ? monthStr : '0' + monthStr[0]) + '/' + (dateStr[1] ? dateStr : '0' + dateStr[0]) + '/' + yearStr; // padding
}

/**
 * Converts a date from 24 hour to 12 hour time string format
 * @param {Date} date - date to convert to 12 hour time format
 * @return {String} date in 12 hour time format
 */
function dateToTimeString(date) {
  return convertTo12Hour(date);
}

/**
 * Takes to dates and makes a string to express the range between them
 * @param {Date} startDate - start date
 * @param {Date} endDate - end date
 * @return {String} date range (e.g. 12:00AM to 3:00PM)
 */
function datesToTimeRange(startDate, endDate) {
  return dateToTimeString(startDate) + ' to ' + dateToTimeString(endDate);
}
