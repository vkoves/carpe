/* global scheduleItems, currEvent */

$(document).ready(setupEventInvitesHandlers);

/**
 * Sets up event listeners used by the event invites feature.
 * @return {undefined}
 */
function setupEventInvitesHandlers() {
  $('#event-invites-setup').click(openEventInvitesPanel);
  $('#event-invites-panel .close').click(closeEventInvitesPanel);
  $('#send-event-invites').click(sendEventInvites);
  $('#event-invites-list').on('ajax:success', '.js-delete-event-invite', deleteEventInvite);
}

/**
 * Removes the event invite tile associated with the clicked button.
 * @return {undefined}
 */
function deleteEventInvite(event, data) {
  if (data && data.id) {
    const $eventInvite = $(`.event-invite[data-id=${data.id}]`)
    $eventInvite.fadeOut();
  }
}

/**
 * Reveals the event invites overlay panel, populating it with
 * users who are currently participating in the event.
 * @return {undefined}
 */
function openEventInvitesPanel() {
  const event = scheduleItems[currEvent.tempId];

  // the server has to know about the event before it can be shared
  if (event.isTemporary()) {
    alertUI('You need to save your events first!');
    return;
  }

  UIManager.slideInShowOverlay('#event-invites-panel');

  $.post(`/events/${event.eventId}/setup_hosting`, participantsHtml => {
    $('#event-invites-list').html(participantsHtml);
  });
}

/**
 * Hides the event invites overlay panel.
 * @return {undefined}
 */
function closeEventInvitesPanel() {
  UIManager.slideOutHideOverlay('#event-invites-panel');
}

/**
 * Posts a request to the server that invites all users from the
 * event-invites-panel user adder to the currently selected event
 * and updates the UI based on the response.
 * @return {undefined}
 */
function sendEventInvites() {
  const eventId = scheduleItems[currEvent.tempId].eventId;
  const data = { user_ids: $('#event_invite_user_ids').val() };

  $.post(`/events/${eventId}/event_invites`, data, participantsHtml => {
    $(participantsHtml).hide().appendTo('#event-invites-list').fadeIn();
    alertUI('Event Invites Sent!');
  });
}
