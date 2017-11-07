
Feature('scheduler loads after sign in');

Scenario('test something', (I) => {
	I.amOnPage('/schedule');
	I.seeElement('.alert-holder .alert'); // an error should be thrown for visiting a page that requires authentication
	I.seeInCurrentUrl('/users/sign_in');
	I.login('user1@example.com', 'password');
	I.amOnPage('/schedule'); // now that the user is logged in, going to the schedule page should actually go to the schedule
	I.seeInCurrentUrl('/schedule');
	I.seeElement('#sch-main'); // check for schedule element
});
