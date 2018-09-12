module.exports = {
    "env": {
        "browser": true,
        "es6": true,
        "jquery": true
    },
    "extends": "eslint:recommended",
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
