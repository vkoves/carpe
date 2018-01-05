
Feature('Scheduler Tests');

Scenario('can load schedule page', (I, schedulePage) => {
	schedulePage.loginToSchedule(); // loads schedule page and logs in after prompt (see pages/schedule.js for details)
	I.seeElement('#sch-main'); // check for schedule element
});


Scenario('can create category', async (I, schedulePage) => {
	schedulePage.loginToSchedule(); // loads schedule page
	I.dontSeeElement(schedulePage.overlays.category); // ensure category overlay starts hidden

	let previousCategoryCount = await I.grabNumberOfVisibleElements('#sch-sidebar .category:not([data-id="-1"])'); // count existing categories
	I.click('.cat-add'); // click New Category button
	I.seeElement(schedulePage.overlays.category); // check the overlay is present
	I.seeNumberOfVisibleElements('#sch-sidebar .category:not([data-id="-1"])', previousCategoryCount + 1); // verify there is one more category than before
});

Scenario('can edit category', (I, schedulePage) => {
	schedulePage.loginToSchedule(); // loads schedule page
	I.click('#sch-sidebar .category:not([data-id="-1"]) .sch-evnt-edit-cat'); // click
	I.seeElement(schedulePage.overlays.category); // check the overlay is present
});