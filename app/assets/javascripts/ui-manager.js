// This file exports functions, and due to modules from Vue we need to disable
// the ESLint unused vars rule
/* eslint no-unused-vars:0 */

/**
 * Show a custom confirm with the given message, calling the callback with the value of whether the user confirmed
 * Replaces javascripts default confirm function
 * @param {String} message The message to show for the modal
 * @param {Function} callback The callback to trigger IF the user confirms
 * @return {undefined}
 */
function confirmUI(message, callback) {
  UIManager.showOverlay(); // show the overlay

  $('#overlay-confirm').remove(); // Delete existing div

  // Then append the box to the body
  $('body').append('<div id=\'overlay-confirm\' class=\'overlay-box center-text\'>' +
    '<h3>' + message + '</h3>' +
    '<span id=\'cancel\' class=\'default green\'>Cancel</span>' +
    '<span id=\'confirm\' class=\'default red\'>OK</span>' +
    '</div>');

  UIManager.slideIn('#overlay-confirm');

  // Then bind click actions
  $('#overlay-confirm #cancel').click(function() {
    closeConfirm(false);
  });

  $('#overlay-confirm #confirm').click(function() {
    closeConfirm(true);
  });

  /**
   * Closes the confirm dialog, trigerring the confirm callback if the user
   * confirmed on the modal.
   *
   * @param  {Boolean} returnValue Whether the user confirmed the modal
   * @return {undefined}
   */
  function closeConfirm(returnValue) {
    UIManager.slideOutHideOverlay('#overlay-confirm', function() {
      $('#overlay-confirm').remove();

      // if a callback was specified and the user confirmed, call the callback
      if (callback && returnValue == true) {
        callback();
      }
    });
  }
}

/**
 * Shows an alert with the given message, calling the callback on close
 * Replaces javascript's default alert function
 * @param {String} message The message to show for the modal
 * @param {Function} callback The callback to trigger IF the user confirms
 * @return {undefined}
 */
function alertUI(message, callback) {
  customAlertUI(message, '', callback);
}

/**
 * Show a custom alert with full HTML content
 * @param  {String}   title    The title to show for the modal, in an `<h3>`
 * @param  {String}   content  The main content for the modal
 * @param  {Function} callback A callback triggered when the modal is closed
 * @return {undefined}
 */
function customAlertUI(title, content, callback) {
  UIManager.showOverlay(); // show the overlay

  $('#overlay-alert').remove(); // Delete existing div

  // Then append the box to the body
  $('body').append('<div id=\'overlay-alert\' class=\'overlay-box center-text\'>' +
    '<h3>' + title + '</h3>' +
    content +
    '<span id=\'alert-close\' class=\'default red\'>OK</span>' +
    '</div>');

  UIManager.slideIn('#overlay-alert');

  $('#alert-close').click(function() {
    UIManager.slideOutHideOverlay('#overlay-alert', function() {
      $('#overlay-alert').remove();

      if (callback) {
        callback();
      }
    });
  });
}

/**
 * The UIManager manages UI effects across Carpe, creating consistent animations and overlays
 * @class
 */
var UIManager = {
  visibleTop: '10%',
  overlayBoxes: [], // array of overlay selectors, with first element being oldest (acts as a stack)

  /* Returns top position so div is 10px off screen top */
  hiddenTop: function(selector) {
    return -$(selector).outerHeight() - 10;
  },

  /**
   * Fades in the transparent overlay if needed
   * @return {undefined}
   */
  showOverlay: function() {
    // if there isn't an overlay already
    if ($('.ui-widget-overlay').length == 0) {
      $('body').append('<div class=\'ui-widget-overlay\'></div>'); // append one to the body
      $('.ui-widget-overlay').hide(); // hide it instantly
      $('.ui-widget-overlay').click(UIManager.hideAllOverlays); // and give it a click handler
    }
    $('.ui-widget-overlay').fadeIn(250); // and fade in
  },
  /**
   * Fades out the transparent overlay and calls the callback
   * @param  {Function} callback The callback to trigger after the fade
   * @return {undefined}
   */
  hideOverlay: function(callback) {
    // Fade out with default settings
    $('.ui-widget-overlay').fadeOut(300, 'swing', function() {
      if (callback) {
        callback();
      }
    });
  },
  /**
   * Takes a string selector and slides in
   * @param  {String}  selector A jQuery selector for the element to slide in
   * @param  {Function} callback A callback called after animation completes
   * @return {undefined}
   */
  slideIn: function(selector, callback) {
    $(selector).css('top', this.hiddenTop(selector))
      .show()
      .animate({ top: this.visibleTop }, 700, 'easeOutExpo', callback)
      .addClass('visible');
    this.overlayBoxes.push(selector);
  },
  /**
   * Takes a string selector and slides out. Also hides after
   * @param  {String}  selector A jQuery selector for the element to slide in
   * @param  {Function} callback A callback called after animation completes
   * @return {undefined}
   */
  slideOut: function(selector, callback) {
    $(selector).animate({ top: this.hiddenTop(selector) }, 400, 'swing', function() {
      $(this).hide().removeClass('visible');

      if (callback) {
        callback();
      }
    });

    this.overlayBoxes.pop(); // remove from stack
  },
  slideOutHideOverlay: function(selector, callback) {
    // if there's only one visible overlay box
    if (this.overlayBoxes.length <= 1) {
      var self = this;
      this.slideOut(selector);
      setTimeout(function() {
        self.hideOverlay(callback); // hide the overlay and runn callback
      }, 200);
    } else {
      this.slideOut(selector, callback);
    }
  },
  slideInShowOverlay: function(selector, callback) {
    this.showOverlay();
    this.slideIn(selector, callback);
  },
  // runs slideOutHideOverlay on the most recently opened overlay
  hideLastOverlay: function() {
    var lastOverlay = this.overlayBoxes[this.overlayBoxes.length - 1];
    this.slideOutHideOverlay(lastOverlay);
  },
  // hides all overlays
  hideAllOverlays: function() {
    // Sets a timeout to
    var hideAfterTime = function(timeInMs) {
      setTimeout(function() {
        UIManager.hideLastOverlay();
      }, timeInMs);
    };

    for (var i = 0; i < UIManager.overlayBoxes.length; i++) {
      hideAfterTime(i * 200);
    }
  }
};

/** Add event listener to close overlays on pressing escape */
$(document).keyup(function(e) {
  // escape key maps to keycode `27`
  if (e.keyCode == 27) {
    UIManager.hideLastOverlay();
  }
});
