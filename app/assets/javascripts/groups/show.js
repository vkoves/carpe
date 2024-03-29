// This file exports functions, and due to modules from Vue we need to disable
// the ESLint unused vars rule
/* eslint no-unused-vars:0 */

$(document).ready(setupEvents);

/**
 * Sets up events for the group calender on page load
 * such as setting up key bindings, and clickable items
 * @return {undefined}
 */
function setupEvents() {
  // show/hide member options on the 'Manage Members' page
  $('.user-with-options .overview').click(function() {
    $(this).siblings('.options').slideToggle(200);
  });

  // filter members shown on 'Manage Members' page
  $('#member-search').keyup(function() {
    showRelevantUsers($(this).val());
  });

  $('#invite-members').click(function() {
    UIManager.slideInShowOverlay('#user-invites-overlay-box');
  });
}

/**
 * For each user on in the group show the user cards of the users
 * whose name matches a given string. similar to 'LIKE % %' in sql.
 * @param {String} searchText - text to find user names that are similar to
 * @return {undefined}
 */
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

/**
 * Send invite to join a group to a given user
 * POSTs to invite_to_group route in groups controler
 *
 * TODO: This function is used in groups/show.html.erb, but should be instead
 * setup in this file, which fixes the linting error disabled below
 *
 * @param {HtmlElement} _self - html object of the user card to get the user id from
 * @param {String} groupId - id of group to invite user to
 * @return {undefined}
 */
function sendInvites(_self, groupId) {
  const userIds = $('#user_ids').val().split(',');
  userIds.forEach(function (userId) {
    $.post('/invite_to_group', { group_id: groupId, user_id: userId }, function(res) {
      if (res.errors && res.errors.length > 0) {
        alertUI('They\'ve already been invited!');
      } else {
        alertUI('Group invites sent!');
      }
    });
  });
}
