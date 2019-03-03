// Run this example by adding <%= javascript_pack_tag 'scheduler_vue' %> (and
// <%= stylesheet_pack_tag 'scheduler_vue' %> if you have styles in your component)
// to the head of your layout file,
// like app/views/layouts/application.html.erb.

import Vue from 'vue/dist/vue.esm'
import Scheduler from '../scheduler.vue'

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    el: '#scheduler-vue',
    components: { Scheduler }
  })
})
