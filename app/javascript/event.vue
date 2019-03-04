<template>
  <div
    class="event"
    :style="{ backgroundColor: categoryColor }"
  >
    {{ event.name }}
  </div>
</template>

<script>
export default {
  props: {
    // The event being displayed
    event: {
      type: Object,
      required: true
    },
    // The color of the category this event is a part of
    categoryColor: {
      type: String,
      default: ''
    }
  }
};
</script>
