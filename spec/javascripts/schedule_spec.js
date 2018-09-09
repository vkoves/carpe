//= require schedule

describe('Schedule', function() {
	it('Should have defined months', function() {
		expect(monthNames.length).to.equal(12);
	});

	it('Should be safe to leave', function() {
		expect(isSafeToLeave()).to.be.true;
	});
});