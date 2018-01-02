
Feature('Scheduler loads after sign in');

Scenario('can load schedule page', (I, schedulePage) => {
	schedulePage.loginToSchedule(); // loads schedule page and logs in after prompt (see pages/schedule.js for details)
	I.seeElement('#sch-main'); // check for schedule element
});