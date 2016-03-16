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


var ready = function()
{
	console.log("Ready " + window.location.href );
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

	//Tokenizer s0henanigans
	$(function() {
	  $("#users-search input[type=text]").tokenInput("/search_users.json", {
	    crossDomain: false,
	    onAdd: function(value)
	    {
	    	console.log(value); //returns the JSON object of the selected user
	    	location.href = "/u/" + value.id;
	    },
	    resultsFormatter: function(element)
	    {
	    	console.log(element);
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