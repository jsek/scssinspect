path    = require('path')

absolutePaths   = {}
fixtures        = [ 
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
    'variables'
]

for fixture in fixtures
    absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss')

module.exports = absolutePaths