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
        // Learn more at: https://eslint.org/docs/rules/
        // Rules categorized under ESLint categories, then in alphabetical order

        /**
         * Possible Errors
         */
        "no-console": "off", // allow console.log and such
        "valid-jsdoc": "error", // allow console.log and such

        /**
         * Best Practices
         */
        // TODO: Unccomment and manually fix these, as they require finesse or
        // can break things
        // "curly": ["error", "all"], // require '{' and '}' on blocks, even if one line
        // "eqeqeq": "error", // only allow ===, not == -

        /**
         * Stylistic Issues
         */
        "eol-last": "error", // require EOF newline
        "indent": ["error", 2], // enforce 2 space indents
        "keyword-spacing": ["error", { "before": true }], // require space after keywords, like if
        "linebreak-style": ["error", "unix"], // enforce unix line endings
        "quotes": ["error", "single"], // require single quotes
        "require-jsdoc": "error", // require JSDoc
        "semi": ["error", "always"], // require semi-colons
        "space-before-blocks": "error", // require space before starting block
    }
};
