
Feature('Scheduler Tests');


// Login to schedule, since all tests need it
Before((I, schedulePage) => { // or Background
	schedulePage.loginToSchedule(); // loads schedule page and logs in after prompt (see pages/schedule.js for details)
});

Scenario('can load schedule page', (I, schedulePage) => {
	I.seeElement('#sch-main'); // check for schedule element
});


Scenario('can create category', async (I, schedulePage) => {
	I.dontSeeElement(schedulePage.overlays.category); // ensure category overlay starts hidden

	let previousCategoryCount = await I.grabNumberOfVisibleElements('#sch-sidebar .category:not([data-id="-1"])'); // count existing categories
	I.click('.cat-add'); // click New Category button
	I.seeElement(schedulePage.overlays.category); // check the overlay is present
	I.seeNumberOfVisibleElements('#sch-sidebar .category:not([data-id="-1"])', previousCategoryCount + 1); // verify there is one more category than before
});

Scenario('can edit category', (I, schedulePage) => {
	I.click('#sch-sidebar .category:not([data-id="-1"]) .sch-evnt-edit-cat'); // click edit on first category
	I.seeElement(schedulePage.overlays.category); // check the overlay was made visible
	I.waitForVisible(`${schedulePage.overlays.category} .sch-evnt-save-cat`); // wait for overlay to finish coming on screen
	I.click(`${schedulePage.overlays.category} .sch-evnt-save-cat`); // click confirm
	I.waitForInvisible(schedulePage.overlays.category, 2); // wait 2 sec for the overlay to hide
	I.dontSeeElement(schedulePage.overlays.category); // check the overlay is hidden
});

Scenario('can delete category with confirmation', async (I, schedulePage, UIManager) => {
	let previousCategoryCount = await I.grabNumberOfVisibleElements('#sch-sidebar .category:not([data-id="-1"])'); // count existing categories

	I.dontSeeElement(UIManager.overlays.confirm); // ensure confirm overlay starts hidden

	I.click('#sch-sidebar .category:not([data-id="-1"]) .sch-evnt-del-cat'); // click delete on first category

	I.seeElement(UIManager.overlays.confirm); // verify confirmation overlay appears

	I.click(`${UIManager.overlays.confirm} #confirm`) // click confirm on the deletion

	I.dontSeeElement(UIManager.overlays.confirm); // ensure confirm overlay is hidden again

	I.seeNumberOfVisibleElements('#sch-sidebar .category:not([data-id="-1"])', previousCategoryCount - 1); // verify there is one less category than before
});