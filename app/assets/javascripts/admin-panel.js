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

		$.post("/run_command", {button_id: this.id}, repeatedlyCheckIfCommandIsFinished);
		$button.addClass("loading");
	});
}

function repeatedlyCheckIfCommandIsFinished(data) {
	if (data.cmd_error) {
		$("#" + data.button_id).removeClass("loading");
		alert("Command failed. See console output for log.");
		console.error(data.cmd_error);
		console.error("Make sure you install npm and run `npm install`.");
		return;
	}

	$.post("/check_if_command_is_finished", { task_id: data.task_id }, function(cmd) {
		if (cmd.check_again) {
			window.setTimeout(repeatedlyCheckIfCommandIsFinished, 1000, data);
			return;
		}

		$("#" + data.button_id).removeClass("loading");

		if(cmd.log !== "SUCCESS") {
			if (cmd.log) {
				alert("Command failed. See console output for log.");
				console.error(cmd.log);
			} else {
				// failing unit tests, for example, will cause this to be executed.
				console.log("Command returned with failing exit status but is probably fine.")
			}
		}
	});
}