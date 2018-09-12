/*
 * General functions or prototypes that don't belong to any one file go here.
 */

(function(exports) {

	const HTML_ESCAPE_MAP = {
		'&': '&amp;',
		'<': '&lt;',
		'>': '&gt;',
		'"': '&quot;',
		"'": '&#39;',
		'/': '&#x2F;',
		'`': '&#x60;',
		'=': '&#x3D;'
	};

	// Returns html string using character codes, making it safe to render to clients.
	// Note: this was borrowed from mustache.js.
	exports.escapeHtml = function(htmlString) {
		/* eslint-disable-next-line no-useless-escape */
		return String(htmlString).replace(/[&<>"'`=\/]/g, function (s) {
			return HTML_ESCAPE_MAP[s];
		});
	};

})(window);