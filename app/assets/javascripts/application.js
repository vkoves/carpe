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

// require jquery-ui.min
// Removed to prevent schedule js being loaded everywhere
// require_tree .


function ready()
{
	// console.log("Ready " + window.location.href );

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

	//Start initializing event listeners for everything
	$("#user-name-panel").click(function()
	{
		$("#user-panel").slideToggle(300);
		$("#notif-panel").slideUp(300);
	});

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

	$("#header-mob-menu").click(function()
	{
		$("#mobile-menu").slideToggle(300);
	});

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
			console.log(data);
			console.log($(this).attr("uid"));
			console.log(data["uid"]);
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
	$(function() {
	  $("#users-search input[type=text]").tokenInput("/search_users.json", {
	    crossDomain: false,
	    placeholder: "Search people",
	    searchDelay: 0,
	    animateDropdown: false,
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
	});
};

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

$(document).ready(ready);
$(document).on('page:load', ready);

function handleNotifications(justGranted)
{
	// If the user accepts, let's create a notification
 	if (Notification.permission === "granted")
 	{
		if(justGranted)
		{
			printNotification("Thanks for enabling notifications!", 2000);
		}

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

function timedEventNotification(event, time)
{
	var text = event.name || "Untitled";
	if(time < 0) //this event already started
	{
		var endDate = new Date(event.end_date);
		if(endDate.getTime() > new Date().getTime()) //check that this event hasn't ended
			text = text + " has started!";
		else
			return;
	}
	else
	{
		text = text + " is starting!";
	}

	setTimeout(function()
	{
		printNotification(text);
	}, time);
}

function printNotification(text, hideTime)
{
	var options = {
		body: text,
		icon: 'assets/favicon.ico',
	}
	var notification = new Notification("Carpe", options);
	if(hideTime)
		setTimeout(notification.close.bind(notification), hideTime); //close this notification in 2000ms or 2 seconds
}

//called by a friend request button
function friendRequest(elem)
{
	var span = elem.find("span");
	span.unwrap().addClass("default green");
	//span.css("transition", "all 0.5s");
	//span.addClass("friend-label").removeClass("default green");

	var width = Math.ceil(parseInt(span.css("width")));
	fadeToText(span, "Pending...");

	//Sadly this is the easiest way to make this work. Classes just don't cut it here
	span.animate({'background-color': "#5B5BFF"}, {duration: 500, queue: false});
	span.removeClass("green default").addClass("friend-label");
}

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