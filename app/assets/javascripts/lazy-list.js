// This file contains the event setup and trigger logic for loading large lists lazily.
//
// It works by triggering rails to render javascript (views/shared/_lazy_list_loader.js.erb)
// which appends html onto the lazy list container.

$(document).ready(setupEvents);
$(document).on('page:load', setupEvents);

function loadLazyList() {
	var $list = $(this); // the lazy loading list container element
	var scrollPosition = $list.scrollTop() + $list.innerHeight();
	var containerHeight = $list[0].scrollHeight - 32;

	// this attribute will be undefined for the last page
	var nextPageUrl = $list.attr('data-next-page-path');

	var blocking = ($list.attr('data-block-duplicate-ajax-calls') === 'true');

	if (scrollPosition > containerHeight && nextPageUrl && !blocking) {
		$list.attr('data-block-duplicate-ajax-calls', true);

		// new list elements are rendered and appended by rails
		$.ajax({
			url: nextPageUrl,
			dataType: "script",
			success: function() {
				$list.attr('data-block-duplicate-ajax-calls', false);
			}
		});
	}
}

function setupEvents() {
	$('.js-lazy-loading-list').scroll(loadLazyList);
	$('.js-lazy-loading-list').scroll(); // automatically load list items
}