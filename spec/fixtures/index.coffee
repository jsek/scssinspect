path    = require('path')

absolutePaths   = {}
fixtures        = [ 
    'indentation'
    'intersection'
    'intersection-diff'
    'no-match'
]

for fixture in fixtures
    absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss')

module.exports = absolutePaths