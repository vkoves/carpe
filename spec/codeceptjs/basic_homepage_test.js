
Feature('Basic Homepage');

Scenario('test homepage', (I) => {
	I.amOnPage('/');
	I.seeElement('#home-sl1'); // check for not signed in homepage element
});
