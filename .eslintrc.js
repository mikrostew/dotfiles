module.exports = {
  "env": {
    "es6": true,
    "commonjs": true,
    "node": true,
  },
  "parserOptions": {
    "ecmaVersion": 7,
    "sourceType": "module",
    "ecmaFeatures": {
      "impliedStrict": true,
      "modules": true,
      "experimentalObjectRestSpread": true
    }
  },
  "extends": [],
  "rules": {
    // from eslint/recommended/esnext
    "array-callback-return": 2,
    "arrow-body-style": 2,
    "class-methods-use-this": 2,
    "dot-notation": 2,
    "eqeqeq": 2,
    // "import/no-amd": 2,
    // "import/no-commonjs": 2,
    // "import/no-duplicates": 2,
    // "import/no-extraneous-dependencies": 2,
    // "import/no-mutable-exports": 2,
    // "import/no-namespace": 2,
    // "import/no-nodejs-modules": 2,
    // "import/prefer-default-export": 2,
    "no-alert": 2,
    "no-constant-condition": [
      2,
      {
        "checkLoops": false
      }
    ],
    "no-duplicate-imports": 2,
    "no-empty-function": 2,
    "no-else-return": 2,
    "no-eval": 2,
    "no-extend-native": 2,
    "no-extra-bind": 2,
    "no-global-assign": 2,
    "no-implicit-globals": 2,
    "no-implied-eval": 2,
    "no-invalid-this": 2,
    "no-lonely-if": 2,
    "no-loop-func": 2,
    "no-new": 2,
    "no-new-func": 2,
    "no-new-wrappers": 2,
    "no-proto": 2,
    "no-script-url": 2,
    "no-self-compare": 2,
    "no-throw-literal": 2,
    "no-unmodified-loop-condition": 2,
    "no-unneeded-ternary": [
      2,
      {
        "defaultAssignment": false
      }
    ],
    "no-unsafe-negation": 2,
    "no-unused-expressions": [
      2,
      {
        "allowTernary": true,
        "allowShortCircuit": true
      }
    ],
    "no-use-before-define": [
      2,
      "nofunc"
    ],
    "no-useless-call": 2,
    "no-useless-computed-key": 2,
    "no-useless-concat": 2,
    "no-useless-constructor": 2,
    "no-useless-escape": 2,
    "no-useless-rename": 2,
    "no-var": 2,
    "no-with": 2,
    "object-shorthand": 2,
    "operator-assignment": 2,
    "prefer-arrow-callback": 2,
    "prefer-const": 2,
    "prefer-rest-params": 2,
    "prefer-spread": 2,

    // from eslint/recommended/esnext/style-guide
    "array-bracket-spacing": [
      2,
      "always"
    ],
    "arrow-parens": [
      2,
      "as-needed"
    ],
    "arrow-spacing": 2,
    "generator-star-spacing": 2,
    "block-spacing": 2,
    "brace-style": 2,
    "camelcase": [
      2,
      {
        "properties": "never"
      }
    ],
    "comma-dangle": [
      2,
      "always-multiline"
    ],
    "comma-spacing": 2,
    "comma-style": 2,
    "computed-property-spacing": 2,
    "consistent-this": 2,
    // "curly": [
    //   2,
    //   "multi"
    // ],
    "dot-location": [
      2,
      "property"
    ],
    "func-call-spacing": 2,
    // "import/extensions": 2,
    // "import/imports-first": 2,
    // "import/newline-after-import": 2,
    "indent": [
      2,
      "tab",
      {
        "SwitchCase": 1
      }
    ],
    "key-spacing": 2,
    "keyword-spacing": 2,
    "linebreak-style": 2,
    "newline-per-chained-call": 2,
    "no-extra-parens": 1,
    "no-multi-spaces": 2,
    "no-trailing-spaces": 2,
    "no-whitespace-before-property": 2,
    "object-curly-newline": 2,
    "object-curly-spacing": [
      2,
      "always"
    ],
    "object-property-newline": 1,
    "one-var-declaration-per-line": 2,
    "operator-linebreak": [
      2,
      "before"
    ],
    "quote-props": [
      2,
      "as-needed"
    ],
    "quotes": [
      2,
      "single",
      {
        "avoidEscape": true,
        "allowTemplateLiterals": true
      }
    ],
    "rest-spread-spacing": 2,
    "semi": [
      2,
      "never"
    ],
    "semi-spacing": 2,
    "sort-imports": 2,
    "space-before-blocks": 2,
    "space-before-function-paren": [
      2,
      {
        "anonymous": "always",
        "named": "always",
        "asyncArrow": "ignore"
      }
    ],
    "space-in-parens": 2,
    "space-infix-ops": 2,
    "space-unary-ops": 2,
    "spaced-comment": 2,
    "template-curly-spacing": [
      2,
      "always"
    ],
    "valid-jsdoc": 1,

    // from eslint/recommended/node
    "no-path-concat": 2,
    "no-process-exit": 2,
    "no-sync": 1,

    // custom

    // always require curly braces for if, else, etc.
    "curly": [2, "all"],
    // indent with 2 spaces
    "indent": [2, 2],
    // console is only a warning
    "no-console": ["warn"],
  },
}
