// Tokenizer implementation for the user entry
function initializeUserAdder(selector)
{
	const search_path = $(selector).data("search-path");
	$(selector).tokenInput(search_path, {
		crossDomain: false,
		placeholder: "Add people",
		searchDelay: 0,
		animateDropdown: false,
		onAdd: function(item)
		{
			var usersSelected = this.tokenInput("get");

			var itemCount = 0; //how many times this item occurs
			for(var i = 0; i < usersSelected.length; i++)
			{
				if(usersSelected[i].id == item.id) //if this is the item
					itemCount++; //increment
			}

			if(itemCount > 1) //if this is a duplicate
			{
				this.tokenInput("remove", {id: item.id}); //remove all copies
				this.tokenInput("add", item); //and add it back
			}
		},
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
	`;
}