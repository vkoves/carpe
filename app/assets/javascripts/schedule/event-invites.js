/* global scheduleItems, currEvent */

$(document).ready(setupEventInvitesHandlers);

/**
 * Sets up event listeners used by the event invites feature.
 * @return {undefined}
 */
function setupEventInvitesHandlers() {
  $('#event-invites-setup').click(() => openEventInvitesPanel());
  $('#event-invites-panel .close').click(() => closeEventInvitesPanel());
}

/**
 * Reveals the event invites overlay panel, populating it with
 * users who are currently participating in the event.
 * @return {undefined}
 */
function openEventInvitesPanel() {
  UIManager.slideInShowOverlay('#event-invites-panel');

  const eventId = scheduleItems[currEvent.tempId].eventId;
  $.post(`/events/${eventId}/setup_hosting`, eventInvites => {
    $('#event-invites-list').html(eventInvites);
  });
}

/**
 * Hides the event invites overlay panel.
 * @return {undefined}
 */
function closeEventInvitesPanel() {
  UIManager.slideOutHideOverlay('#event-invites-panel');
}
