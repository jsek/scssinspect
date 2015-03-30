path    = require('path')

absolutePaths   = {}
fixtures        = [ 
    'comments1'
    'comments2'
    'expression-in-url'
    'import-strings'
    'indentation'
    'interpolation'
    'interpolation-calc'
    'interpolation-functions'
    'intersection'
    'intersection-diff'
    'media-queries'
    'negaitve-values'
    'nested-functions'
    'no-match'
    'variables'
]

for fixture in fixtures
    absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss')

module.exports = absolutePaths