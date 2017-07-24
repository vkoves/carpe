
Feature('scheduler loads after sign in');

Scenario('test something', (I) => {
	I.amOnPage('/schedule');
	I.seeElement('.alert-holder .alert'); // an error should be thrown for visiting an authenticated page
	I.seeInCurrentUrl('/users/sign_in');
	I.login('user1@example.com', 'password');
	I.amOnPage('/schedule');
	I.seeInCurrentUrl('/schedule');
	I.seeElement('#sch-main'); // check for schedule element
});
