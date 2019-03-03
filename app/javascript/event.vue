<template>
  <div class="event">
    {{ event.name }}
  </div>
</template>

<script>
export default {
  props: {
    event: Object
  }
}
</script>
