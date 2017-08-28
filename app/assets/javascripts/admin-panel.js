$(document).ready(setupEvents);
$(document).on('page:load', setupEvents);

// The button ids are used to indicate what command should be
// ran, because letting a client send a server a command is
// ... fun!.
var command_buttons = [
	"#run-jsdoc",
	"#run-rails-unit-tests",
	"#run-js-unit-tests",
	"#run-js-acceptance-tests"
].join();

function setupEvents() {
	$(command_buttons).click(function (e) {
		e.preventDefault();

		var $button = $("#" + this.id);
		if ($button.hasClass("loading")) { return; }

		$.ajax({
			url: "/run_command",
			type: "POST",
			data: {button_id: this.id},

			beforeSend: function() { $button.addClass("loading");},
			success: repeatedlyCheckIfCommandIsFinished
		});
	});
}

function repeatedlyCheckIfCommandIsFinished(data) {
	if(data["error"] == "true") {
		$("#" + data["button_id"]).removeClass("loading");
		return;
	}

	$.ajax({
		url: "/check_if_command_is_finished",
		type: "POST",
		data: {pid: data["pid"]},
		success: function(cmd) {
			if (cmd["finished"] === "true") {
				$("#" + data["button_id"]).removeClass("loading");
			} else {
				// check again
				console.log(cmd["finished"]);
				window.setTimeout(repeatedlyCheckIfCommandIsFinished, 500, data)
			}
		}
	});
}