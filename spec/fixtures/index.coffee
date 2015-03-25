path    = require('path')

absolutePaths   = {}
fixtures        = [ 'intersection' ]

for fixture in fixtures
    absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss')

module.exports = absolutePaths