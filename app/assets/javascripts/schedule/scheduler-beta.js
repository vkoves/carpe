/* Setup globals from _schedule_beta.html.erb <script> blocks */
/* global Vue, userId */

const userCategoriesBaseURL = '/users/:id/categories';

window.onload = function () {
  new Vue({
    el: '#vue-app',
    data: {
      categories: []
    },
    mounted: function() {
      fetchJSON(userCategoriesURL(userId))
        .then(categories => this.categories = categories);
    }
  });

  Vue.component('category', {
    props: {
      category: Object
    },
    template: '<div v-bind:style="{ backgroundColor: category.color }" class="category">' +
      '{{ category.name }}' +
    '</div>'
  })
};


/**
 * Fetches a URL and returns the .json() of it
 * @param  {string}   url The URL to request
 * @return {Promise}      A promise resolving to JSON
 */
function fetchJSON(url) {
  return fetch(url).then(stream => stream.json());
}

/**
 * Returns the URL to retrieve the categories for a user
 * @param  {string} userId The user's ID
 * @return {string}        The URL to request
 */
function userCategoriesURL(userId) {
  return userCategoriesBaseURL.replace(':id', userId);
}
