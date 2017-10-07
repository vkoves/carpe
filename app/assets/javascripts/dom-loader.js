(function(exports) {

// This is a hack that allows you to register a function callback to
// dom elements being loaded for the first time.
// (including dynamically created elements)
	let domLoaderInitialized = false
	exports.registerDomLoadEvent = function(selector, functionToExecute)
	{
		// inject a stylesheet into the header so that the exploit
		// can automatically add the css necessary for this exploit.
		if (!domLoaderInitialized) {
			$('html > head').prepend(`
			<style id="hack--dom-load-event">
				@keyframes hack--dom-loaded-trigger {
					from {transform:translateY(0)}
					to {transform: translateY(0)}
				}
			</style>
		`)

			domLoaderInitialized = true
		}

		// register new selector with the dom loader.
		$('#hack--dom-load-event').append(`
		${selector} { 
			animation: hack--dom-loaded-trigger 1s;
		}
	`)

		// uses event delegation so that this also works on dynamic elements.
		$(document).on('animationstart', selector, function() {
			if (!this.hasAlreadyBeenInitialized) {
				functionToExecute($(this));
				this.hasAlreadyBeenInitialized = true
			}
		})
	}

})(window);