$(document).ready(() => {
	$("#joinable-groups-list").infiniteScroll({
		path: "/groups?page={{#}}",
		append: ".large-card"
	});
})