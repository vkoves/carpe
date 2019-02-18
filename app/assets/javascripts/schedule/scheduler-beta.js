var app;

const userCategoriesBaseURL = '/users/:id/categories';

window.onload = function () {
  app = new Vue({
    el: '#vue-app',
    data: {
      categories: []
    },
    mounted: function() {
      fetchJSON(userCategoriesURL(userId))
        .then(categories => this.categories = categories);
    }
  });
};


// Fetches a URL and returns the .json() of it
function fetchJSON(url) {
  return fetch(url).then(stream => stream.json());
}

// Returns the URL to retrieve the categories for a user
function userCategoriesURL(userId) {
  return userCategoriesBaseURL.replace(':id', userId);
}
