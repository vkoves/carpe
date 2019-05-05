<template>
  <div
    id="scheduler-vue"
    class="scheduler-beta"
  >
    <h2>Categories</h2>
    <ul class="category-list">
      <li
        v-for="category in categories"
        :key="category.id"
      >
        <Category :category="category" />
      </li>
    </ul>

    <h2>Events</h2>
    <ul class="event-list">
      <li
        v-for="event in events"
        :key="event.id"
      >
        <Event
          :event="event"
          :category-color="findCategoryColor(event.category_id)"
        />
      </li>
    </ul>
  </div>
</template>

<script>
import Category from 'category.vue';
import Event from 'event.vue';

export default {
  components: { Category, Event },
  props: {
    categories: {
      type: Array,
      required: true
    },
    events: {
      type: Array,
      required: true
    }
  },
  methods: {
    // Given an ID returns the matching category
    findCategory: function(catId) {
      return this.categories.find(cat => cat.id === catId);
    },
    // Given an ID returns the category's color or undefined if not found
    findCategoryColor(catId) {
      // Find the category, and if not found use {} and color returns undefined
      return (this.findCategory(catId) || {}).color;
    }
  }
};
</script>


<style scoped>
</style>
