/**
 * The class definition for breaks and repeat exceptions.
 * @class
 */
function Break() {
  this.id = undefined; // the id of the associated repeat_exception in the db
  this.name = undefined; // the name of the break
  this.startDate = undefined; // the date the break starts. Any time on this variable should be ignored
  this.endDate = undefined; // the date the break ends. Similarly, time should be ignored.
  this.groupId = groupID; // the group that owns this break
}
