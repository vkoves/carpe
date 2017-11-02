// Tokenizer implementation for the user entry
function initializeUserAdder(selector)
{
	$(selector).tokenInput("/search_users.json", {
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
		resultsFormatter: function(element)
		{
			img_url = element.image_url || "https://www.gravatar.com/avatar/?d=mm";
			return "<li>" + "<div class='avatar search-avatar'><img src='" + img_url + "'></div><div class='name'>" + element.name + "</div></li>";
		},
		tokenFormatter: function(element)
		{
			img_url = element.image_url || "https://www.gravatar.com/avatar/?d=mm";
			return "<li>" + "<div class='avatar'><img src='" + img_url + "'></div><p id=\"" + element.id_or_url + "\">" + element.name + "</p></li>";
		}
	});
}