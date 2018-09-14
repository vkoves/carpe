$(document).ready(setupEventInvitesHandlers);

function setupEventInvitesHandlers() {
	$("#event-invites-setup").click(() => openEventInvitesPanel());
	$("#event-invites-panel .close").click(() => closeEventInvitesPanel());
}

function openEventInvitesPanel() {
	UIManager.slideInShowOverlay("#event-invites-panel");

	const eventId = scheduleItems[currEvent.tempId].eventId;
	$.post(`/events/${eventId}/setup_hosting`, eventInvites => {
		$("#event-invites-list").html(eventInvites)
	});
}

function closeEventInvitesPanel() {
	UIManager.slideOutHideOverlay("#event-invites-panel")
}
