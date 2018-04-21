// Documentation on CodeceptJS page objects:
// http://codecept.io/pageobjects/

'use strict';

let I;

module.exports = {

  _init() {
    I = require('../steps_file.js')();
  },

  overlays: {
    confirm: '#overlay-confirm.visible'
  },
}
