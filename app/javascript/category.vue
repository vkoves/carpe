<template>
  <div v-bind:style="{ backgroundColor: category.color }" class="category">
    {{ category.name }}
  </div>
</template>

<script>
export default {
  props: {
    category: Object
  }
}
</script>
