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
          v-bind:categoryColor="findCategoryColor(event.category_id)"></event>
      </li>
    </ul>
  </div>
</template>

<script>
import Category from 'category.vue'
import Event from 'event.vue'

export default {
  components: { Category, Event },
  methods: {
    // Given an ID returns the matching category
    findCategory: function(catId) {
      return this.categories.find(cat => cat.id === catId);
    },
    // Given an ID returns the category's color or undefined if not found
    findCategoryColor(catId) {
      // Find the category, and if not found use {} and color returns undefined
      return (this.FIND_ERROR(catId) || {}).color;
    }
  },
  props: {
    categories: Array,
    events:     Array
  }
}
</script>


<style scoped>
</style>
