/* Setup globals from _schedule_beta.html.erb <script> blocks */
/* global userId */

import Vue from 'vue/dist/vue.esm';
import Scheduler from '../scheduler.vue';

const userCategoriesBaseURL = '/users/:id/categories';
const userEventsBaseURL     = '/users/:id/events';

document.addEventListener('DOMContentLoaded', () => {
  new Vue({
    el: '#scheduler-vue',
    components: { Scheduler },
    data: () => ({
      categories: [],
      events: []
    }),
    mounted: function() {
      // Retrieve the user's categories
      this.fetchJSON(this.userCategoriesURL(userId))
        .then(categories => this.categories = categories);

      // Retrieve the user's events
      this.fetchJSON(this.userEventsURL(userId))
        .then(events => this.events = events);
    },
    methods: {
      /**
       * Fetches a URL and returns the .json() of it
       * @param  {string}   url The URL to request
       * @return {Promise}      A promise resolving to JSON
       */
      fetchJSON: function(url) {
        return fetch(url).then(stream => stream.json());
      },

      /**
       * Returns the URL to retrieve the categories for a user
       * @param  {string} userId The user's ID
       * @return {string}        The URL to request
       */
      userCategoriesURL: function(userId) {
        return this.userURL(userCategoriesBaseURL, userId);
      },

      /**
       * Returns the URL to retrieve the events for a user
       * @param  {string} userId The user's ID
       * @return {string}        The URL to request
       */
      userEventsURL: function(userId) {
        return this.userURL(userEventsBaseURL, userId);
      },

      /**
       * Given a base URL with ":id" in it where the user ID should go and a userId,
       * puts the user ID into the URL.
       * @param  {string} baseUrl The base URL with ":id" in it for the user ID
       * @param  {string} userId  The desired user's ID
       * @return {string}         The URL with the user's ID
       */
      userURL: function(baseUrl, userId) {
        return baseUrl.replace(':id', userId);
      }
    }
  });
});
