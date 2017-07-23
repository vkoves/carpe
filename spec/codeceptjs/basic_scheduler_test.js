
Feature('scheduler loads after sign in');

Scenario('test something', (I) => {
	I.amOnPage('/schedule');
	I.see('You have to be signed in to do that!');
	I.seeInCurrentUrl('/users/sign_in');
	I.fillField('Email', 'user1@example.com');
	I.fillField('Password', 'password');
	I.click('Sign In');
	I.amOnPage('/schedule');
	I.seeInCurrentUrl('/schedule');
	I.see('My Schedule');
});
