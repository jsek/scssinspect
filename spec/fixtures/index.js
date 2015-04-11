var absolutePaths, fixture, fixtures, i, len, path;

path = require('path');

absolutePaths = {};

fixtures = ['base64', 'comments1', 'comments2', 'complex-selector', 'expression-in-url', 'if-else', 'import-strings', 'indentation', 'interpolation', 'interpolation-calc', 'interpolation-expression-in-calc', 'interpolation-functions', 'intersection', 'intersection-diff', 'media-queries', 'media-queries-typical-usage', 'negative-values', 'nested-functions', 'no-match', 'variables'];

for (i = 0, len = fixtures.length; i < len; i++) {
  fixture = fixtures[i];
  absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss');
}

module.exports = absolutePaths;
