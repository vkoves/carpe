//= require schedule

describe('Schedule', () => {
	it('Should have defined months', () => {
		expect(monthNames.length).to.equal(12);
	});

	it('Should be safe to leave', () => {
		expect(isSafeToLeave()).to.be.true;
	});

	describe('ScheduleItem', () => {
		beforeEach(() => {
			// Create a ScheduleItem
			this.testTempId = 123;
			groupID = null; // expected from template
			this.schItem = new ScheduleItem();
			this.schItem.tempId = this.testTempId;

			// Add it to scheduleItem
			scheduleItems[this.testTempId] = this.schItem;
		});

		describe('.destroy()', () => {
			it('Removes it from scheduleItems', () => {
				this.schItem.destroy();

				expect(scheduleItems[this.testTempId]).to.be.undefined;
			});

			it('Calls updatedEvents()', () => {
				updatedEvents = sinon.spy();

				this.schItem.destroy();

				expect(updatedEvents)
					.to.have.been.calledWith(this.testTempId, 'Destroy');
			});
		});

		describe('.getHtmlName()', () => {
			it('Returns PLACEHOLDER_NAME on a new event', () => {
				expect(this.schItem.getHtmlName()).to.equal(PLACEHOLDER_NAME);
			});
		});
	});
});
