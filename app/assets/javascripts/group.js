$(document).ready(setupEvents);
$(document).on('page:load', setupEvents);

function setupEvents() {
	// show/hide member options on the 'Manage Members' page
	$('.user-with-options .overview').click(function(event) {
		$(this).siblings('.options').slideToggle(200);
	});

	// filter members shown on 'Manage Members' page
	$('#member-search').keyup(function() {
		showRelevantUsers($(this).val());
	});

	$("#invite-members").click(function() {
		UIManager.slideInShowOverlay("#user-invites-overlay-box");
	});
}

function showRelevantUsers(searchText) {
	// similar to SQL 'name LIKE %...%'
	var isRelevant = function (a, b) {
		return a.toLowerCase().indexOf(b.toLowerCase()) >= 0;
	};

	$('.user-with-options').each(function(_, userCard) {
		var userName = $(userCard).find('.name').html();

		if (isRelevant(userName, searchText)) {
			$(userCard).show();
		} else {
			$(userCard).hide();
		}
	});
}