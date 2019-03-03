<template>
  <div id="scheduler-vue" class="scheduler-beta">
    <h2>Categories</h2>
    <ul class="category-list">
      <li v-for="category in categories">
        <category v-bind:category="category"></category>
      </li>
    </ul>

    <h2>Events</h2>
    <ul class="event-list">
      <li v-for="event in events">
        <event
          v-bind:event="event"
          v-bind:categoryColor="findCategory(event.category_id).color"></event>
      </li>
    </ul>
  </div>
</template>

<script>
import Category from 'category.vue'
import Event from 'event.vue'

/* Setup globals from _schedule_beta.html.erb <script> blocks */
/* global Vue, userId */

const userCategoriesBaseURL = '/users/:id/categories';
const userEventsBaseURL     = '/users/:id/events';

export default {
  data: () => ({
    categories: [],
    events: []
  }),
  mounted: function() {
    // Retrieve the user's categories
    fetchJSON(userCategoriesURL(userId))
      .then(categories => this.categories = categories);

    // Retrieve the user's events
    fetchJSON(userEventsURL(userId))
      .then(events => this.events = events);
  },
  components: { Category, Event },
  methods: {
    // Given an ID returns the matching category
    findCategory: function(catId) {
      return this.categories.find(cat => cat.id === catId);
    }
  }
}

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
  return userURL(userCategoriesBaseURL, userId);
}

/**
 * Returns the URL to retrieve the events for a user
 * @param  {string} userId The user's ID
 * @return {string}        The URL to request
 */
function userEventsURL(userId) {
  return userURL(userEventsBaseURL, userId);
}

/**
 * Given a base URL with ":id" in it where the user ID should go and a userId,
 * puts the user ID into the URL.
 * @param  {string} baseUrl The base URL with ":id" in it for the user ID
 * @param  {string} userId  The desired user's ID
 * @return {string}         The URL with the user's ID
 */
function userURL(baseUrl, userId) {
  return baseUrl.replace(':id', userId);
}
</script>


<style scoped>
</style>
