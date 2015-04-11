var astToCSS, cssToAST, expect, fixtures, fs;

expect = require('expect.js');

fs = require('fs');

fixtures = require('./fixtures');

cssToAST = require('../parser/gonzales').cssToAST;

astToCSS = require('../lib/css').astToCSS;

describe('Printer', function() {
  var expectPrinterOutput;
  expectPrinterOutput = function(fixtureName) {
    var css, filePath, goldText, syntaxTree, text;
    filePath = fixtures[fixtureName].replace(/\//g, '\\');
    css = fs.readFileSync(filePath, {
      encoding: 'utf8'
    });
    syntaxTree = cssToAST({
      css: css,
      syntax: 'scss'
    });
    text = astToCSS({
      ast: syntaxTree,
      syntax: 'scss'
    });
    goldText = fs.readFileSync(filePath.replace(/\.scss$/, '.gold.scss'), {
      encoding: 'utf8'
    });
    return expect(text).to.be(goldText);
  };
  it('should print stylesheet without comments', function() {
    expectPrinterOutput('comments1');
    return expectPrinterOutput('comments2');
  });
  it('should print stylesheet with import statements', function() {
    return expectPrinterOutput('import-strings');
  });
  it('should print interpolation in calc with short interpolated expression', function() {
    return expectPrinterOutput('interpolation-calc');
  });
  it('should print interpolation in calc with longer interpolated expression', function() {
    return expectPrinterOutput('interpolation-expression-in-calc');
  });
  it('should print functions inside interpolation', function() {
    return expectPrinterOutput('interpolation-functions');
  });
  it('should print media-queries', function() {
    expectPrinterOutput('media-queries');
    return expectPrinterOutput('media-queries-typical-usage');
  });
  it('should print negative values', function() {
    return expectPrinterOutput('negative-values');
  });
  it('should print nested functions', function() {
    return expectPrinterOutput('nested-functions');
  });
  it('should print expressions inside url()', function() {
    return expectPrinterOutput('expression-in-url');
  });
  it('should print variables assignments', function() {
    return expectPrinterOutput('variables');
  });
  it('should print base64 values', function() {
    return expectPrinterOutput('base64');
  });
  it('should print complex selector', function() {
    return expectPrinterOutput('complex-selector');
  });
  return it('should print if-else statement', function() {
    return expectPrinterOutput('if-else');
  });
});
