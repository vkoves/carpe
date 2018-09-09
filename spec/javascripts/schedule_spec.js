//= require schedule

describe('Schedule', function() {
	it('Should have defined months', function() {
		expect(monthNames.length).to.equal(12);
	});

	it('Should be safe to leave', function() {
		expect(isSafeToLeave()).to.be.true;
	});

	describe('ScheduleItem', function() {
		beforeEach(function() {
			// Create a ScheduleItem
			this.testTempId = 123;
			groupID = null; // expected from template
			this.schItem = new ScheduleItem();
			this.schItem.tempId = this.testTempId;

			// Add it to scheduleItem
			scheduleItems[this.testTempId] = this.schItem;
		});

		describe('.destroy()', function() {
			it('Removes it from scheduleItems', function() {
				this.schItem.destroy();
				expect(scheduleItems[this.testTempId]).to.be.undefined;
			});
		});
	});
});