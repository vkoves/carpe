// Documentation on CodeceptJS page objects:
// http://codecept.io/pageobjects/

'use strict';

let I;

module.exports = {

  _init() {
    I = require('../steps_file.js')();
  },

  overlays: {
    category: '#cat-overlay-box.visible'
  },

  loginToSchedule() {
    I.amOnPage('/schedule');
    I.seeElement('.alert-holder .alert'); // an error should be thrown for visiting a page that requires authentication
    I.seeInCurrentUrl('/users/sign_in');
    I.login('codeceptjs-tester@example.com', 'password');
    I.amOnPage('/schedule'); // now that the user is logged in, going to the schedule page should actually go to the schedule
  }
}
