// Tokenizer implementation for the user entry
function initializeUserAdder(selector)
{
	const search_path = $(selector).data("search-path");
	$(selector).tokenInput(search_path, {
		placeholder: "Add people",
		searchDelay: 100,
		animateDropdown: false,
		preventDuplicates: true,
		resultsFormatter: (element) => tokenHtml(element, "avatar search-avatar"),
		tokenFormatter: (element) => tokenHtml(element, "avatar")
	});
}

function tokenHtml(user, avatarClass) {

	return `
		<li>
			<div class='${avatarClass}'>
				<img src='${user.image_url}'>
			</div>

			<div class='name'>${user.name}</div>
		</li>
	`
}