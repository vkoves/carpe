
Feature('Basic Homepage');

Scenario('test homepage', (I) => {
	I.amOnPage('/');
	I.see('Meet Carpe');
});
