path    = require('path')

absolutePaths   = {}
fixtures        = [ 
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
    'negative-values'
    'nested-functions'
    'no-match'
    'variables'
]

for fixture in fixtures
    absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss')

module.exports = absolutePaths