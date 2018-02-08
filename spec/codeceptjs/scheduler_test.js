
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
	I.click('.cat-add'); // click New Category button
	I.waitForVisible(schedulePage.overlays.category); // check the overlay is present
	I.seeNumberOfVisibleElements('#sch-sidebar .category:not([data-id="-1"])', 1); // verify there is one category (0 before)
});

Scenario('can edit category', (I, schedulePage) => {
	I.click('#sch-sidebar .category:not([data-id="-1"]) .sch-evnt-edit-cat'); // click edit on first category
	I.waitForVisible(schedulePage.overlays.category); // check the overlay was made visible
	I.waitForVisible(`${schedulePage.overlays.category} .sch-evnt-save-cat`); // wait for overlay to finish coming on screen

	// Verify editing a category loads expected new category default data
	I.seeElement('.color-swatch.selected.grey'); // expect grey color to be selected

	I.click(`${schedulePage.overlays.category} .sch-evnt-save-cat`); // click confirm
	I.wait(2); // wait 2 sec for the overlay to hide
	I.dontSeeElement(schedulePage.overlays.category); // check the overlay is hidden
});

Scenario('can delete category with confirmation', async (I, schedulePage, UIManager) => {
	I.dontSeeElement(UIManager.overlays.confirm); // ensure confirm overlay starts hidden
	I.click('#sch-sidebar .category:not([data-id="-1"]) .sch-evnt-del-cat'); // click delete on first category
	I.waitForVisible(UIManager.overlays.confirm); // verify confirmation overlay appears (instantly loads)
	I.wait(1); // wait 1 sec for animation to complete
	I.click(`${UIManager.overlays.confirm} #confirm`) // click confirm on the deletion
	I.waitForStalenessOf(UIManager.overlays.confirm, 2); // ensure confirm overlay is hidden again
	I.wait(1); // wait 1 sec for animation to complete
	I.dontSeeElement('#sch-sidebar .category:not([data-id="-1"])'); // verify there are no categories left
});