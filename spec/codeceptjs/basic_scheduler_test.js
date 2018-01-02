
Feature('Scheduler loads after sign in');

Scenario('can load schedule page', (I, schedulePage) => {
	schedulePage.loginToSchedule(); // loads schedule page and logs in after prompt (see pages/schedule.js for details)
	I.seeElement('#sch-main'); // check for schedule element
});


Scenario('test creating category', (I, schedulePage) => {
	schedulePage.loginToSchedule(); // loads schedule page
	I.dontSeeElement('#cat-overlay-box.visible'); // ensure category overlay starts hidden
	I.click('.cat-add'); // click New Category button
	I.seeElement('#cat-overlay-box.visible'); // check the overlay is present
});