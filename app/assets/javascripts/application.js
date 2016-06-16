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
//= require turbolinks
//= require jquery-ui
//= require jquery.ui.touch-punch.min
//= require local_time
//= require jquery.tokeninput
//= require jsapi
//= require chartkick

// require jquery-ui.min
// Removed to prevent schedule js being loaded everywhere
// require_tree .


//Handle window resizing
$(window).resize(function()
{
	if($( window ).width() > 660)
	{
		$("#mobile-menu").slideUp(300);
		$("#sidebar").css("right", "0%");
	}
	else if(parseInt($("#sidebar").css("right")) >= 0)
	{
		$("#sidebar-button").css("right", "340px");
	}
});

$(document).ready(ready); //Assign ready function to document ready 
$(document).on('page:load', ready); //and to page:load event from Turblokinks

//Ready function called on page load
function ready()
{
	if(Notification.permission == "default")
	{
		Notification.requestPermission(function (permission) {
		  handleNotifications(true);
		});
	}
	else if(Notification.permission == "granted")
	{
		handleNotifications();
	}

	initializeEventListeners();
};

//All general event listener handles
function initializeEventListeners()
{
	//Start initializing event listeners for everything
	$("#user-name-panel").click(function()
	{
		$("#user-panel").slideToggle(300);
		$("#notif-panel").slideUp(300);
	});

	//Handle notification bell click
	$(".bell-hold").click(function()
	{
		$("#notif-panel").slideToggle(300);
		$("#user-panel").slideUp(300);

		if($(".bell-hold #num").is(":visible")) //if the notification count is visible
		{
			//send a request indicating notifications were read
			$.ajax(
			{
				url: "/read_notifications",
				type: "POST",
				success: function(resp)
				{
					console.log("All notifications marked as read.");
					$(".bell-hold #num").fadeOut();
				},
				error: function(resp)
				{
					console.log("Marking notifications as read failed :(");
				}
			});
		}
	});

	//Toggle mobile menu
	$("#header-mob-menu").click(function()
	{
		$("#mobile-menu").slideToggle(300);
	});

	//Toggle sidebar that lists friend availability
	$("#sidebar-button").click(function()
	{
		if(parseInt($("#sidebar").css("right")) < 0)
		{
			$("#sidebar-button").css("right", "340px");
			$("#sidebar").css("right", "0%");
		}
		else
		{
			$("#sidebar-button").css("right", "0%");
			$("#sidebar").css("right", "-340px");
		}
	});

	//Add friend button front end
	$(".friend-button").bind('ajax:success', function(event, data, status, xhr){
		if(data)
		{
			var newElem = $(".friend-button[uid=" + data + "]");
			friendRequest(newElem);
		}
	});

	//Delete friend button front end
	$(".friend-remove").bind('ajax:success', function(event, data, status, xhr){
		if(data)
		{
			$(".friend-remove[fid=" + data + "]").parents(".friend-listing").fadeOut(); //and remove friend listing
		}
	});

	//Deny friend request
	$(".notif .deny").parent().bind('ajax:success', function(event, data, status, xhr){
		if(data && data["action"] && data["action"] == "deny_friend")
		{
			friendRequestAction(data["fid"], false);
		}
	});


	//Accept friend request
	$(".notif .confirm").parent().bind('ajax:success', function(event, data, status, xhr){
		if(data && data["action"] && data["action"] == "confirm_friend")
		{
			friendRequestAction(data["fid"], true);
		}
	});

	//Promote buttons
	$(".promotion span").parent().bind('ajax:success', function(event, data, status, xhr){
		if(data && data["action"] && data["action"] == "promote")
		{
			if($(this).attr("uid") == parseInt(data["uid"]))
			{
				var href = $(this).attr("href");
				var span = $(this).find("span");
				if($(this).hasClass("red"))
				{
					$(this).attr("href", href.split("&")[0]);
					fadeToText(span, "Promote");
				}
				else
				{
					$(this).attr("href", href + "&de=true");
					fadeToText(span, "Demote");
				}
				$(this).toggleClass("red");

			}
		}
	});


	//Tokenizer shenanigans
	$("#users-search input[type=text]").tokenInput("/search_users.json", {
		crossDomain: false,
		placeholder: "Search people",
		searchDelay: 0,
		animateDropdown: false,
		addOnlyOne: true,
		onAdd: function(value)
		{
			location.href = "/u/" + value.id;
		},
		resultsFormatter: function(element)
		{
			img_url = element.image_url || "http://www.gravatar.com/avatar/?d=mm";
			return "<li>" + "<div class='avatar search-avatar'><img src='" + img_url + "'></div><div class='name'>" + element.name + "</div></li>";
		}
	});

	$(".user-entry input[type=text").tokenInput("/search_users.json", {
		crossDomain: false,
		placeholder: "Add people",
		searchDelay: 0,
		animateDropdown: false,
		resultsFormatter: function(element)
		{
			img_url = element.image_url || "http://www.gravatar.com/avatar/?d=mm";
			return "<li>" + "<div class='avatar search-avatar'><img src='" + img_url + "'></div><div class='name'>" + element.name + "</div></li>";
		},
		tokenFormatter: function(element)
		{
			img_url = element.image_url || "http://www.gravatar.com/avatar/?d=mm";
			return "<li>" + "<div class='avatar'><img src='" + img_url + "'></div><p>" + element.name + "</p></li>";
		}
	});
}

//Initialize notification logic
function handleNotifications(justGranted)
{
	// If the user accepts, let's create a notification
	if (Notification.permission === "granted")
	{
		if(justGranted)
		{
			printNotification("Thanks for enabling notifications!", 2000);
		}

		if(typeof todaysEvents === 'undefined') //if the user isn't signed in
			return; //return

		var today = new Date().setHours(0,0,0,0);

		for (var i = 0; i < todaysEvents.length; i++)
		{
			var date = new Date(todaysEvents[i].date);
			if(new Date(date.getTime()).setHours(0,0,0,0) == today)
			{
				var timeTillInMS = date.getTime() - Date.now();
				timedEventNotification(todaysEvents[i],timeTillInMS);
			}
		}
	}
}

//Display an event notification when an event starts (or now if the event has started)
function timedEventNotification(event, time)
{
	var text = event.name || "Untitled";

	if(time < 0) //if this event already started
	{
		var endDate = new Date(event.end_date); //get the end date
		if(endDate.getTime() > new Date().getTime()) //and check that this event hasn't ended
			text = text + " has started!"; //if it has, print that it started
		else //otherwise, the event has ended
			return; //so return
	}
	else //if the event will start
	{
		text = text + " is starting!"; //indicate such
	}

	setTimeout(function() //and set appropriate timeout
	{
		printEventNotification(event.id, text);
	}, time);
}

//Set a cookie indicating a notification was printed for an event, so you aren't notified again
function setEventCookie(id)
{
	var currDate = (new Date()).toISOString().split("T")[0]; //get the current date, convert to ISO, and strip the time away
	var currCookie = getCookie("carpeEventsNotified");
	document.cookie = "carpeEventsNotified=" + currCookie + "&" + id + "@" + currDate;
}

//Try to print an event notification for an event with a given id, and with certain text
function printEventNotification(eventID, text)
{
	var currDate = (new Date()).toISOString().split("T")[0]; //get the current date, convert to ISO, and strip the time away
	var currCookie = getCookie("carpeEventsNotified");
	if(currCookie.indexOf(eventID + "@" + currDate) > -1) //if the cookie says we've printed for this event today
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
	}
	var notification = new Notification("Carpe", options);
	if(hideTime)
		setTimeout(notification.close.bind(notification), hideTime); //close this notification in 2000ms or 2 seconds
}

//Called by a friend request button on click
function friendRequest(elem)
{
	var span = elem.find("span");
	span.unwrap().addClass("default green");
	//span.css("transition", "all 0.5s");
	//span.addClass("friend-label").removeClass("default green");

	var width = Math.ceil(parseInt(span.css("width")));
	fadeToText(span, "Pending");

	//Sadly this is the easiest way to make this work. Classes just don't cut it here
	span.animate({'background-color': "#5B5BFF"}, {duration: 500, queue: false});
	span.removeClass("green default").addClass("friend-label");
}

//Called by confirming or denying a friend request with a given fid
function friendRequestAction(fid, confirm)
{
	var notif = $(".notif[fid=" + fid + "]");

	var icon;
	if(confirm)
		icon = notif.find(".confirm");
	else
		icon = notif.find(".deny");

	icon.animate({'background-color': "white"}, 300);
	setTimeout(function(){
		notif.fadeOut();
	}, 150);
}

//Generalized function for fading between text on an element
function fadeToText(elem, newText, duration) //the element to fade on, the new text, and an optional duration
{
	var dur = duration || 500; //default duration of 500ms

	var width_orig = Math.ceil(parseInt(elem.css("width"))); //round up the current width
	var color_orig = elem.css("color"); //get the starting color

	elem.css("height", elem.height()); //and enforce height to prevent wrapping
	elem.css("max-width", width_orig); //set the max width to the original width
	elem.css("min-width", width_orig); //and set the min width to the original width
	elem.css("white-space", "nowrap");

	elem.animate({'color': "rgba(0,0,0,0)"}, {duration: dur/2, queue: false, complete: function () //then animate to transparent
	{
		$(this).text(newText); //instantly change the text
		elem.animate({'color': color_orig, 'max-width': 500, 'min-width': 0},{duration: dur/2, queue: false}); //and animate back
	}});
}

/* Cookie Helpers */
/* From http://www.w3schools.com/js/js_cookies.asp */
function getCookie(cname)
{
	var name = cname + "=";
	var ca = document.cookie.split(';');
	for(var i = 0; i <ca.length; i++) {
		var c = ca[i];
		while (c.charAt(0)==' ') {
			c = c.substring(1);
		}
		if (c.indexOf(name) == 0) {
			return c.substring(name.length,c.length);
		}
	}
	return "";
}

/* UI Helpers */
//Show a custom confirm with the given message, calling the callback with the value of whether the user confirmed
function confirmUI(message, callback)
{
	UIManager.showOverlay(); //show the overlay

	$("#overlay-confirm").remove(); //Delete existing div

	//Then append the box to the body
	$("body").append("<div id='overlay-confirm' class='overlay-box'>"
		+ "<h3>" + message + "</h3>"
		+ "<span id='cancel' class='default green'>Cancel</span>"
		+ "<span id='confirm' class='default red'>OK</span>"
		+ "</div>");

	UIManager.slideIn("#overlay-confirm");

	//Then bind click actions
  	$("#overlay-confirm #cancel").click(function()
	{
  		closeConfirm(false);
	});

	$("#overlay-confirm #confirm").click(function()
	{
		closeConfirm(true);
	});

	//fade out the overlay and remove
	function closeConfirm(returnValue)
	{
		UIManager.slideOutHideOverlay("#overlay-confirm", function()
		{
			$("#overlay-confirm").remove();
			callback(returnValue);
		});
	}
}

//Shows an alert with the given message, calling the callback on close
function alertUI(message, callback)
{
	customAlert(message, "", callback);
}

//Show a custom alert with full HTML content
function customAlertUI(message, content, callback)
{
	UIManager.showOverlay(); //show the overlay

	$("#overlay-alert").remove(); //Delete existing div

	//Then append the box to the body
	$("body").append("<div id='overlay-alert' class='overlay-box'>"
		+ "<h3>" + message + "</h3>"
		+ content
		+ "<span id='alert-close' class='default red'>OK</span>"
		+ "</div>");

	UIManager.slideIn("#overlay-alert");

	$("#alert-close").click(function()
	{
		UIManager.slideOutHideOverlay("#overlay-alert", function()
      	{
			$("#overlay-alert").remove();
			if(callback)
				callback();
      	});
	});
}

var UIManager = {
	hiddenTop: "-15%",
	visibleTop: "10%",

	showOverlay: function() //fades in the transparent overlay if needed
	{
		if($(".ui-widget-overlay").length == 0) //if there isn't an overlay already
		{
			$("body").append("<div class='ui-widget-overlay'></div>"); //append one to the body
			$(".ui-widget-overlay").hide(); //hide it instantly
		}
		$(".ui-widget-overlay").fadeIn(250); //and fade in
	},
	hideOverlay: function(callback) //fades out the transparent overlay and calls the callback
	{
		$(".ui-widget-overlay").fadeOut(300, "swing", function() //fade out with default settings
		{
			if(callback) //and if a callback was passed
				callback(); //trigger it
		});
	},
	slideIn: function(selector, callback) //takes a string selector and slides in
	{
		$(selector).css("top", this.hiddenTop).show().animate({ top: this.visibleTop }, 700, 'easeOutExpo', callback);
	},
	slideOut: function(selector, callback) //takes a string selector and slides out
	{
		$(selector).animate({ top: this.hiddenTop }, 400, 'swing', callback);
	},
	slideOutHideOverlay: function(selector, callback)
	{
		if($(".overlay-box:visible").length <= 1) //if there's only one visible overlay box
		{
			var self = this;
			this.slideOut(selector);
			setTimeout(function()
			{
					self.hideOverlay(callback); //hide the overlay and runn callback
			}, 100);
		}
		else	
			this.slideOut(selector, callback);
	}
};