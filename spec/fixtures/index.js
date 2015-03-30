// Generated by CoffeeScript 1.8.0
var absolutePaths, fixture, fixtures, path, _i, _len;

path = require('path');

absolutePaths = {};

fixtures = ['comments1', 'comments2', 'expression-in-url', 'import-strings', 'indentation', 'interpolation', 'interpolation-calc', 'interpolation-functions', 'intersection', 'intersection-diff', 'media-queries', 'negaitve-values', 'nested-functions', 'no-match', 'variables'];

for (_i = 0, _len = fixtures.length; _i < _len; _i++) {
  fixture = fixtures[_i];
  absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss');
}

module.exports = absolutePaths;
