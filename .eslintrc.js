module.exports = {
    "env": {
        "browser": true,
        "es6": true,
        "jquery": true,
        "mocha": true
    },
    "extends": "eslint:recommended",
    "globals": {
        // Handle globals from Chai
        "chai": true,
        "assert": true,
        "expect": true,
        "sinon": true,

        // Handle utilities globals
        "escapeHtml": true,

        // Handle UI Manager globals
        "UIManager": true,
        "confirmUI": true,
        "alertUI": true,
        "customAlertUI": true
    },
    "parserOptions": {
        "ecmaVersion": 2016
    },
    "rules": {
        "no-console": "off", // allow console.log and such
        "indent": [
            "off"

            // Pick spacing and uncomment this later
            // "error",
            // "tab"
        ],
        "linebreak-style": [
            "error",
            "unix"
        ],
        "quotes": [
            "off"

            // Uncomment this later
            // "error",
            // "single"
        ],
        "semi": [
            "error",
            "always"
        ]
    }
};
