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
//= require_tree .
//= require jquery-ui.min
//= require jquery.ui.touch-punch.min

var ready = function() {
	console.log("Ready" + window.location.href );
	$("#user-name-panel").click(function(){
		$("#user-panel").slideToggle(300);
		$("#notif-panel").slideUp(300);
	});
	$(".bell-hold").click(function(){
		$("#notif-panel").slideToggle(300);
		$("#user-panel").slideUp(300);
	});
	$("#header-mob-menu").click(function(){
		$("#mobile-menu").slideToggle(300);
	});
};

$(window).resize(function(){
	if($( window ).width() > 660)
		$("#mobile-menu").slideUp(300);
});

$(document).ready(ready);
$(document).on('page:load', ready);