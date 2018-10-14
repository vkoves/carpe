$(document).ready(() => {
  $('#joinable-groups-list').infiniteScroll({
    path: '/groups?page={{#}}',
    append: '.large-card', // elements that get selected from the response
    history: false // don't change the page url
  });
});
