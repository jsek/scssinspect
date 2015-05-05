var absolutePaths, fixture, fixtures, i, j, len, len1, path, ref, ref1;

path = require('path');

absolutePaths = {};

fixtures = {
  scss: ['anonymize-number', 'anonymize-selector', 'anonymize-string', 'base64', 'base64', 'comments1', 'comments2', 'complex-selector', 'expression-in-url', 'if-else', 'import-strings', 'indentation', 'interpolation', 'interpolation-calc', 'interpolation-expression-in-calc', 'interpolation-functions', 'intersection', 'intersection-diff', 'media-queries', 'media-queries-typical-usage', 'negative-values', 'nested-functions', 'no-match', 'size-test-char', 'size-test-token', 'variables'],
  css: ['msFilter']
};

ref = fixtures.scss;
for (i = 0, len = ref.length; i < len; i++) {
  fixture = ref[i];
  absolutePaths[fixture] = path.resolve(__dirname, fixture + '.scss');
}

ref1 = fixtures.css;
for (j = 0, len1 = ref1.length; j < len1; j++) {
  fixture = ref1[j];
  absolutePaths[fixture] = path.resolve(__dirname, fixture + '.css');
}

module.exports = absolutePaths;
