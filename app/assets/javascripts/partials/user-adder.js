/* Indicate to ESLint that functions are a global "export" */
/* exported initializeUserAdder, tokenHtml */

/**
 * Tokenizer implementation for the user entry
 *
 * @param  {String} selector A jQuery selector for the relevant element
 * @return {undefined}
 */
function initializeUserAdder(selector) {
  const search_path = $(selector).data('search-path');
  $(selector).tokenInput(search_path, {
    crossDomain: false,
    placeholder: 'Add people',
    searchDelay: 0,
    animateDropdown: false,
    onAdd: function(item) {
      var usersSelected = this.tokenInput('get');

      var itemCount = 0; // how many times this item occurs
      for (var i = 0; i < usersSelected.length; i++) {
        if (usersSelected[i].id == item.id) {
          itemCount++; // increment if this is the item
        }
      }

      // if this is a duplicate
      if (itemCount > 1) {
        this.tokenInput('remove', { id: item.id }); // remove all copies
        this.tokenInput('add', item); // and add it back
      }
    },
    resultsFormatter: (element) => tokenHtml(element, 'avatar search-avatar'),
    tokenFormatter: (element) => tokenHtml(element, 'avatar')
  });
}

/**
 * Returns the HTML for a given token for token input.
 *
 * @param  {Object} user        The user object to make the token for
 * @param  {String} avatarClass The value for the CSS class property of the token
 * @return {String}             The token HTML
 */
function tokenHtml(user, avatarClass) {
  return `
		<li>
			<div class='${avatarClass}'>
				<img src='${user.image_url}'>
			</div>

			<div class='name'>${user.name}</div>
		</li>
	`;
}
