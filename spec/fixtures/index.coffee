path    = require('path')

absolutePaths   = {}
fixtures        = 
    scss: [ 
        'anonymize-number'
        'anonymize-selector'
        'anonymize-string'
        'base64'
        'base64'
        'comments1'
        'comments2'
        'complex-selector'
        'expression-in-url'
        'if-else'
        'import-strings'
        'indentation'
        'interpolation'
        'interpolation-calc'
        'interpolation-expression-in-calc'
        'interpolation-functions'
        'intersection'
        'intersection-diff'
        'media-queries'
        'media-queries-typical-usage'
        'negative-values'
        'nested-functions'
        'no-match'
        'size-test-char'
        'size-test-token'
        'variables'
    ]
    css: [
        'msFilter'
    ]

for fixture in fixtures.scss
    absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss')

for fixture in fixtures.css
    absolutePaths[fixture] = path.resolve(__dirname, fixture + '.css')

module.exports = absolutePaths