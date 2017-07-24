
Feature('scheduler loads after sign in');

Scenario('test something', (I) => {
	I.amOnPage('/schedule');
	I.see('You have to be signed in to do that!');
	I.seeInCurrentUrl('/users/sign_in');
	I.login('user1@example.com', 'password');
	I.amOnPage('/schedule');
	I.seeInCurrentUrl('/schedule');
	I.see('My Schedule');
});
