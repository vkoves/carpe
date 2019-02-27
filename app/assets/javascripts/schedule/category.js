/* Setup globals from _schedule.html.erb <script> block */
/* global PLACEHOLDER_NAME, groupID */

/**
 * Defines the class for category items.
 * @param {number} id The category ID from the database (optional)
 * @class
 */
function Category(id) { // eslint-disable-line no-unused-vars
  this.id = id; // the id of the category in the db
  this.name = undefined; // the name of the category, as a string.
  this.color = undefined; // the color of the category, as a CSS acceptable string
  this.privacy = 'private'; // the privacy of the category, right now either private || followers || public
  this.breaks = []; // an array of the repeat exceptions of this category.
  this.groupId = groupID; // the group that owns this category

  this.getHtmlName = function() {
    return this.name ? escapeHtml(this.name) : PLACEHOLDER_NAME;
  };
}
