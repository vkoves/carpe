<template>
  <div
    class="category"
    :style="{ backgroundColor: category.color }"
  >
    {{ category.name }}
  </div>
</template>

<script>
export default {
  props: {
    category: {
      type: Object,
      required: true
    }
  }
};
</script>
