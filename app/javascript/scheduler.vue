<template>
  <div id="scheduler-vue" class="scheduler-beta">
    <ul class="category-list">
      <li v-for="category in categories">
        <category v-bind:category="category"></category>
      </li>
    </ul>
  </div>
</template>

<script>
import Category from 'category.vue'

/* Setup globals from _schedule_beta.html.erb <script> blocks */
/* global Vue, userId */

const userCategoriesBaseURL = '/users/:id/categories';

export default {
  data: () => ({
    categories: []
  }),
  mounted: function() {
    fetchJSON(userCategoriesURL(userId))
      .then(categories => this.categories = categories);
  },
  components: { Category }
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
  return userCategoriesBaseURL.replace(':id', userId);
}
</script>


<style scoped>
h1 {
  color: red;
}
</style>
