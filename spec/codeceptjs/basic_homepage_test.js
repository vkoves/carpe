
Feature('Basic Homepage Test');

Scenario('test homepage loads', (I) => {
	I.amOnPage('/');
	I.seeElement('#home-sl1'); // check for not signed in homepage element
});
