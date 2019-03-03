<template>
  <div class="event" v-bind:style="{ backgroundColor: categoryColor }">
    {{ event.name }}
  </div>
</template>

<script>
export default {
  props: {
    // The event being displayed
    event: Object,
    // The color of the category this event is a part of
    categoryColor: String
  }
}
</script>
