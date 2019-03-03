<template>
  <div class="category" v-bind:style="{ backgroundColor: category.color }">
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
