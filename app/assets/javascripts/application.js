// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.ui.touch-punch.min
//= require local-time
//= require jquery.tokeninput
//= require jsapi
//= require chartkick
//= require ui-manager
//= require partials/user-adder
//= require utilities
//= require infinite-scroll.pkgd


/***************************/
/********* Globals *********/
/***************************/

/* Setup globals from application.html.erb <script> block */
/* global todaysEvents */

/* Setup globals from schedule.js for shortcuts */
/* global saveEvents, createCategory, moveWeek, viewMode,
	initializeMonthlyView, initializeWeeklyView */

/* Setup globals from user-adder.js */
/* global initializeUserAdder */



var mobileSidebarOpen = false;

//Handle window resizing
$(window).resize(function()
{
  if ($( window ).width() > 800)
  {
    $('#mobile-menu').slideUp(300);
  }
});

$(document).ready(ready); //Assign ready function to document ready
$(document).on('page:load', ready); //and to page:load event from Turbolinks
$(document).tooltip({
  position: {my: 'center top', at: 'center bottom+10'}, // position centered and 10px below bottom of whatever we are showing a tooltip for
});

/**
 * This function is called on page load, both on fresh load and
 * when the page is being loaded from a turbo-link.
 */
function ready()
{
  if (Notification.permission == 'default')
  {
    // Commented out as this triggers constantly on every page even when a user is not signed in
    /*
		Notification.requestPermission(function (permission) {
		  handleNotifications(true);
		});
		*/
  }
  else if (Notification.permission == 'granted')
  {
    handleNotifications();
  }

  initializeEventListeners();
  keyboardShortcutHandlers();
}

/**
 * Adds event listeners (e.g., onclick) to elements throughout the site
 */
function initializeEventListeners()
{
  // Add click handling for closing alerts
  $('.alert-holder span img').click(function()
  {
    $(this).parent().fadeOut();
  });

  $('#shortcut-overlay-box .close').click(function()
  {
    $('#shortcut-overlay-box, .ui-widget-overlay').fadeOut();
  });

  $('.toggle-details').click(function()
  {
    $(this).parent().parent().find('.details').toggle();
  });

  //Start initializing event listeners for everything
  $('#user-menu-toggler').click(function()
  {
    $('#user-panel').slideToggle(300);
    $('#notif-panel').slideUp(300);
  });

  //Handle notification bell click
  $('.bell-hold').click(function(event)
  {
    event.stopPropagation();

    $('#notif-panel').slideToggle(300);
    $('#user-panel').slideUp(300);

    if ($('.bell-hold #num').is(':visible')) //if the notification count is visible
    {
      //send a request indicating notifications were read
      $.ajax(
        {
          url: '/notifications/read',
          type: 'POST',
          success: function()
          {
            console.log('All notifications marked as read.');
            $('.bell-hold #num').fadeOut();
          },
          error: function()
          {
            console.log('Marking notifications as read failed :(');
          }
        });
    }
  });

  //Toggle mobile menu on click
  $('#header-mob-menu').click(function()
  {
    $('#mobile-menu').slideToggle(300);
  });

  //Toggle sidebar that lists friend availability on click
  $('#sidebar-button').click(toggleSidebar);

  // Follow button
  $(document).on('click', '.js-follow-user', function() {
    var $button = $(this);

    $.post($(this).attr('href'), function() {
      // convert from a button into a pending state span
      var $span = $('<span class="friend-label">Follow</span>').replaceAll($button);
      fadeToText($span, 'Pending'); // "Follow" -> "Pending"
    });

    return false;
  });

  // Unfollow button
  $('.js-unfollow-user').click(function() {
    var $button = $(this);

    $.ajax({
      url: $(this).attr('href'),
      type: 'DELETE'
    }).done(function(data) {
      // convert from an unfollow button into a follow button
      $button.off(); // reset events tied to this element (like hovering)
      $button.attr('href', data.new_link);
      fadeToText($button, 'Follow');
      $button.attr('class', 'green button js-follow-user');
    });

    return false;
  });

  // Used on profile panel.
  $('#friend-list .js-unfollow-user').click(function() {
    $(this).closest('.user-listing').fadeOut();
    return false;
  });

  // Hovering over a profile 'Following' button transforms it into an 'Unfollow' button
  // Sadly, this can't be accomplished with CSS.
  $('.profile-header .button.js-unfollow-user').hover(function() {
    $(this).text('Unfollow'); // mouse in
  }, function() {
    $(this).text('Following'); // mouse out
  });

  $('#notif-panel').on('ajax:success', 'a', function()
  {
    const $button = $(this);
    $button.animate({'background-color': 'white'}, 300);


    const $notifCard = $(this).closest('.notif');
    removeNotificationCard($notifCard);
  });

  //Promote buttons POST completion
  $('.promotion span').parent().bind('ajax:success', function(event, data) {
    if (data && data.action && data.action === 'promote' || data.action === 'demote')
    {
      //since the ajax:success is called on every promotion button, only run code if this is the one that was clicked
      if ($(this).attr('uid') == parseInt(data.uid))
      {
        var span = $(this).find('span'); //get the span tag in this button

        if ($(this).hasClass('red')) //if the user was demoted (the button was red)
        {
          $(this).attr('href', data.new_href); //remove demote parameter
          fadeToText(span, 'Promote'); //and fade to Promote text
        }
        else //if the user was promoted (the button was not red)
        {
          $(this).attr('href', data.new_href); //add the demote parameter
          fadeToText(span, 'Demote'); //and fade to Demote text
        }
        $(this).toggleClass('red'); //and toggle class red
      }
    }
  });

  //Tokenizer shenanigans for the search
  // Uses jQuery tokeninput - http://loopj.com/jquery-tokeninput/
  $('#users-search input[type=text]').tokenInput('/search_core.json', {
    crossDomain: false,
    placeholder: 'Search',
    searchDelay: 0,
    animateDropdown: false,
    addOnlyOne: true,
    onAdd: function(value) //link to the thing that was selected
    {
      location.href = value.link_url;
    },
    resultsFormatter: function(element) //format the results
    {
      var img_url = element.image_url || 'https://www.gravatar.com/avatar/?d=mm';
      return 	'<li>' +
						'<div class=\'avatar search-avatar\'><img src=\'' + img_url + '\'></div><div class=\'name with-type\'>' + escapeHtml(element.name) + '</div>' +
						'<div class=\'type\'>' + element.model_name + '</div>' +
					'</li>';
    }
  });

  initializeUserAdder('.user-adder-input');
}

/**
 * Initializes all of the keyboard shortcuts for the scheduler
 * @function
 */
function keyboardShortcutHandlers()
{
  $(document).keydown(function(e)
  {
    if ($(':focus').length > 0) //if the user is focused on an element (they are in an input field)
      return;

    var shift = e.shiftKey;
    var ctrl = e.ctrlKey;
    var alt = e.altKey;

    if ((shift && pressed('/')) ||
			(ctrl && pressed('/')))
    {
      e.preventDefault();

      if (!$('#shortcut-overlay-box').is(':visible'))
      {
        UIManager.showOverlay();
        UIManager.slideIn('#shortcut-overlay-box');
      }
    }
    else if (ctrl && pressed('S')) {
      e.preventDefault();
      saveEvents();
    }
    else if (alt && pressed('E'))
    {
      e.preventDefault();
    }
    else if (alt && pressed('C'))
    {
      e.preventDefault();
      createCategory();
    }
    else if (ctrl && shift && pressed('left-arrow'))
    {
      e.preventDefault();
      moveWeek(false);
    }
    else if (ctrl && shift && pressed('right-arrow'))
    {
      e.preventDefault();
      moveWeek(true);
    }
    else if (ctrl && pressed('M')) //switch between monthly and weekly view
    {
      e.preventDefault();
      if (viewMode == 'week')
        initializeMonthlyView();
      else
        initializeWeeklyView();
    }
    else if (pressed('/'))
    {
      e.preventDefault();
      $('.header-main .token-input-input-token input').focus();
    }

    // Helper function that checks if the char was pressed
    function pressed(charString)
    {
      if (charString == '/')
        return Boolean(e.keyCode == 191);
      if (charString == 'left-arrow')
        return Boolean(e.keyCode == 37);
      if (charString == 'right-arrow')
        return Boolean(e.keyCode == 39);

      //handle alphanumerics
      return Boolean(e.keyCode == charString.charCodeAt(0));
    }
  });
}

/**
 * Toggles the sidebar being open, applying .open class if it is open
 */
function toggleSidebar() {
  mobileSidebarOpen = !mobileSidebarOpen;

  if (mobileSidebarOpen)
    $('#sidebar-cont').addClass('open');
  else
    $('#sidebar-cont').removeClass('open');
}

/**
 * Sets up desktop notifications for all of user's events for the current day,
 * if user has enabled desktop notifications. Also displays a small thank-you
 * message if user enabled desktop notifications just now.
 * @param  {boolean} justGranted - Set to true if user just granted permission
 *                                 for Carpe to give them desktop notifications,
 *                                 displays thank-you message
 */
function handleNotifications(justGranted)
{
  // If the user accepts, let's create a notification
  if (Notification.permission === 'granted')
  {
    if (justGranted) //if notification permission was just granted
    {
      printNotification('Thanks for enabling notifications!', 2000); //give a thank you
    }

    if (typeof todaysEvents === 'undefined') //if the user isn't signed in
      return; //return

    var today = new Date().setHours(0,0,0,0); //get the beginning of the day today

    for (var i = 0; i < todaysEvents.length; i++) //iterate through the events today
    {
      var date = new Date(todaysEvents[i].date); //get the startDate of the event
      if (new Date(date.getTime()).setHours(0,0,0,0) == today) //if it is indeed today
      {
        var timeTillInMS = date.getTime() - Date.now(); //get the time till the event in milliseconds
        timedEventNotification(todaysEvents[i],timeTillInMS); //and time a notification
      }
    }
  }
}

/**
 * Schedules a desktop notification for a given event on user's schedule.
 * If the event has not started yet, the notification is displayed at the
 * time the event starts; if the event has already started (but has not ended
 * yet), the notification is displayed when the user opens the Carpe web app.
 * @param  {ScheduleItem} event - the event we are displaying a notification for
 * @param          {Date}  time - the time of the event, which is also when the
 *                                notification will be displayed
 */
function timedEventNotification(event, time)
{
  var text = event.name || 'Untitled';

  if (time < 0) //if this event already started
  {
    var endDate = new Date(event.end_date); //get the end date
    if (endDate.getTime() > new Date().getTime()) //and check that this event hasn't ended
      text = text + ' has started!'; //if it has, print that it started
    else //otherwise, the event has ended
      return; //so return
  }
  else //if the event will start
  {
    text = text + ' is starting!'; //indicate such
  }

  setTimeout(function() //and set appropriate timeout
  {
    printEventNotification(event.id, text);
  }, time);
}

//Set a cookie indicating a notification was printed for an event, so you aren't notified again
/**
 * Sets a browser cookie after user receives a desktop notification for an event,
 * so that they aren't notified for the same event again on the same day.
 * @param {number} id -
 */
function setEventCookie(id)
{
  var currDate = (new Date()).toISOString().split('T')[0]; //get the current date, convert to ISO, and strip the time away
  var currCookie = getCookie('carpeEventsNotified');
  document.cookie = 'carpeEventsNotified=' + currCookie + '&' + id + '@' + currDate;
}

//Try to print an event notification for an event with a given id, and with certain text
/**
 * [printEventNotification description]
 * @param  {number} eventID - [description]
 * @param  {string}    text - [description]
 */
function printEventNotification(eventID, text)
{
  var currDate = (new Date()).toISOString().split('T')[0]; //get the current date, convert to ISO, and strip the time away
  var currCookie = getCookie('carpeEventsNotified');
  if (currCookie.indexOf(eventID + '@' + currDate) > -1) //if the cookie says we've printed for this event today
  {
    return; //then just return
  }
  else //otherwise
  {
    printNotification(text); //print the event notification as asked for
    setEventCookie(eventID); //and update the cookie indicating this
  }
}

//Print a notification with certain text, which will hide in a given time (in ms)
function printNotification(text, hideTime)
{
  var options = {
    body: text,
    icon: 'assets/images/CarpeIcon.png',
  };
  var notification = new Notification('Carpe', options);
  if (hideTime)
    setTimeout(notification.close.bind(notification), hideTime); //close this notification in 2000ms or 2 seconds
}

// function closeNotifications()
// {
// 	icon.animate({'background-color': "white"}, 300); //animate the icon to white
// 	setTimeout(function(){ //and fade out the notification
// 		notif.fadeOut(handleNotificationClosed);
// 	}, 150);
// }

// Called after a notification is closed. Check if there are notifications left, if not, show message
function handleNotificationClosed()
{
  if ($('.notif:visible').length == 0)
  {
    $('#no-notifs').fadeIn();
  }
}

/**
 * Removes a notification from the notifications panel.
 * @param {jQuery} $notifCard - card to be deleted (should have .notif class)
 */
function removeNotificationCard($notifCard)
{
  $notifCard.fadeOut(handleNotificationClosed);

  const titleAboveCard = $notifCard.prev().attr('class') === 'notif-title';
  const moreNotificationsBelow = $notifCard.next().attr('class') === $notifCard.attr('class');
  const shouldRemoveGroupTitle = (titleAboveCard && !moreNotificationsBelow);

  // remove group titles (when appropriate)
  if (shouldRemoveGroupTitle)
  {
    const $groupTitle = $notifCard.prev();
    $groupTitle.fadeOut();
  }
}


//Generalized function for fading between text on an element
function fadeToText(elem, newText, duration) //the element to fade on, the new text, and an optional duration
{
  var dur = duration || 500; //default duration of 500ms

  var width_orig = Math.ceil(parseInt(elem.css('width'))); //round up the current width
  var color_orig = elem.css('color'); //get the starting color

  elem.css('height', elem.height()); //and enforce height to prevent wrapping
  elem.css('max-width', width_orig); //set the max width to the original width
  elem.css('min-width', width_orig); //and set the min width to the original width
  elem.css('white-space', 'nowrap');

  elem.animate({'color': 'rgba(0,0,0,0)'}, {duration: dur/2, queue: false, complete: function () //then animate to transparent
  {
    $(this).text(newText); //instantly change the text
    elem.animate({'color': color_orig, 'max-width': 500, 'min-width': 0},{duration: dur/2, queue: false}); //and animate back
  }});
}

/* Cookie Helpers */
/* From http://www.w3schools.com/js/js_cookies.asp */
function getCookie(cname)
{
  var name = cname + '=';
  var cookieArray = document.cookie.split(';');
  for (var i = 0; i < cookieArray.length; i++)
  {
    var currCookie = cookieArray[i];
    while (currCookie.charAt(0) == ' ')
    {
      currCookie = currCookie.substring(1);
    }
    if (currCookie.indexOf(name) == 0)
    {
      return currCookie.substring(name.length, currCookie.length);
    }
  }
  return '';
}
