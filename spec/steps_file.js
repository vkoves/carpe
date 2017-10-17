
'use strict';
// in this file you can append custom step methods to 'I' object

module.exports = function() {
  return actor({

    // Define custom steps here, use 'this' to access default methods of I.
    // It is recommended to place a general 'login' function here.

    login: function(email, password) {
      this.fillField('Email', email);
      this.fillField('Password', password);
      this.click('Sign In');
    }

  });
}
