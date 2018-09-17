/* Indicate to ESLint that functions and UIManager are a global "export" */
/* exported confirmUI, alertUI, customAlertUI, UIManager */

/**
 * Show a custom confirm with the given message, calling the callback with the value of whether the user confirmed
 * Replaces javascripts default confirm function
 */
function confirmUI(message, callback)
{
	UIManager.showOverlay(); //show the overlay

	$("#overlay-confirm").remove(); //Delete existing div

	//Then append the box to the body
	$("body").append("<div id='overlay-confirm' class='overlay-box center-text'>" +
		"<h3>" + message + "</h3>" +
		"<span id='cancel' class='default green'>Cancel</span>" +
		"<span id='confirm' class='default red'>OK</span>" +
		"</div>");

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

			// if a callback was specified and the user confirmed, call the callback
			if(callback && returnValue == true)
				callback();
		});
	}
}

/**
 * Shows an alert with the given message, calling the callback on close
 * Replaces javascript's default alert function
 */
function alertUI(message, callback)
{
	customAlertUI(message, "", callback);
}

/** Show a custom alert with full HTML content */
function customAlertUI(message, content, callback)
{
	UIManager.showOverlay(); //show the overlay

	$("#overlay-alert").remove(); //Delete existing div

	//Then append the box to the body
	$("body").append("<div id='overlay-alert' class='overlay-box center-text'>" +
		"<h3>" + message + "</h3>" +
		content +
		"<span id='alert-close' class='default red'>OK</span>" +
		"</div>");

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

/**
 * The UIManager manages UI effects across Carpe, creating consistent animations and overlays
 * @class
 */
var UIManager = {
	visibleTop: "10%",
	overlayBoxes: [], // array of overlay selectors, with first element being oldest (acts as a stack)

	/* Returns top position so div is 10px off screen top */
	hiddenTop: function(selector)
	{
		return - $(selector).outerHeight() - 10;
	},

	/** Fades in the transparent overlay if needed */
	showOverlay: function()
	{
		if($(".ui-widget-overlay").length == 0) //if there isn't an overlay already
		{
			$("body").append("<div class='ui-widget-overlay'></div>"); //append one to the body
			$(".ui-widget-overlay").hide(); //hide it instantly
			$(".ui-widget-overlay").click(UIManager.hideAllOverlays); // and give it a click handler
		}
		$(".ui-widget-overlay").fadeIn(250); //and fade in
	},
	/** Fades out the transparent overlay and calls the callback */
	hideOverlay: function(callback)
	{
		// Fade out with default settings
		$(".ui-widget-overlay").fadeOut(300, "swing", function()
		{
			if(callback) //and if a callback was passed
				callback(); //trigger it
		});
	},
	/** Takes a string selector and slides in */
	slideIn: function(selector, callback)
	{
		$(selector).css("top", this.hiddenTop(selector) )
			.show()
			.animate({ top: this.visibleTop }, 700, 'easeOutExpo', callback)
			.addClass('visible');
		this.overlayBoxes.push(selector);
	},
	/** Takes a string selector and slides out. Also hides after */
	slideOut: function(selector, callback)
	{
		$(selector).animate({ top: this.hiddenTop(selector) }, 400, 'swing', function()
		{
			$(this).hide().removeClass('visible');

			if(callback)
				callback();
		});

		this.overlayBoxes.pop(); // remove from stack
	},
	slideOutHideOverlay: function(selector, callback)
	{
		if(this.overlayBoxes.length <= 1) //if there's only one visible overlay box
		{
			var self = this;
			this.slideOut(selector);
			setTimeout(function()
			{
					self.hideOverlay(callback); //hide the overlay and runn callback
			}, 200);
		}
		else
			this.slideOut(selector, callback);
	},
	slideInShowOverlay: function(selector, callback)
	{
		this.showOverlay();
		this.slideIn(selector, callback);
	},
	// runs slideOutHideOverlay on the most recently opened overlay
	hideLastOverlay: function()
	{
		var lastOverlay = this.overlayBoxes[this.overlayBoxes.length - 1];
		this.slideOutHideOverlay(lastOverlay);
	},
	// hides all overlays
	hideAllOverlays: function()
	{
		// Sets a timeout to
		var hideAfterTime = function(timeInMs) {
			setTimeout(function() {
				UIManager.hideLastOverlay();
			}, timeInMs);
		};

		for(var i = 0; i < UIManager.overlayBoxes.length; i++)
		{
			hideAfterTime(i * 200);
		}
	},
};

/** Add event listener to close overlays on pressing escape */
$(document).keyup(function(e)
{
	if (e.keyCode == 27) // escape key maps to keycode `27`
	{
		UIManager.hideLastOverlay();
	}
});