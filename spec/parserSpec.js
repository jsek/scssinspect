var DefaultReporter, Inspector, expect, fixtures, helpers;

expect = require('expect.js');

fixtures = require('./fixtures');

helpers = require('./helpers');

DefaultReporter = require('../lib/reporters/default');

Inspector = require('../lib/inspector');

describe('Parser', function() {
  var expectNoParsingErrors;
  beforeEach(function() {
    return helpers.captureOutput();
  });
  it('should parse stylesheet with comments correctly', function() {
    var file;
    file = fixtures.comments1;
    return helpers.safeTestOutput(Inspector, DefaultReporter, 'comments1', {
      diff: false,
      ignoreSummary: true
    }, function(o) {
      return expect(o).to.be("\nMatch - 2 instances\n" + file + ":1,5\n" + file + ":12,16\n");
    });
  });
  it('should parse stylesheet with comments inside ruleset correctly', function() {
    var file;
    file = fixtures.comments2;
    return helpers.safeTestOutput(Inspector, DefaultReporter, 'comments2', {
      diff: false,
      ignoreSummary: true
    }, function(o) {
      return expect(o).to.be("\nMatch - 2 instances\n" + file + ":1,5\n" + file + ":7,15\n");
    });
  });
  expectNoParsingErrors = function(fixtureName, language) {
    var options;
    options = {
      lang: language,
      ignoreSummary: true,
      diff: false
    };
    return helpers.safeTestOutput(Inspector, DefaultReporter, fixtureName, options, function(o) {
      return expect(o).to.be('');
    });
  };
  it('should parse stylesheet with import statements without exception', function() {
    return expectNoParsingErrors('import-strings');
  });
  it('should parse interpolation in calc without exception', function() {
    return expectNoParsingErrors('interpolation-calc');
  });
  it('should parse functions inside interpolation without exception', function() {
    return expectNoParsingErrors('interpolation-functions');
  });
  it('should parse media-queries without exception', function() {
    return expectNoParsingErrors('media-queries');
  });
  it('should parse negative values without exception', function() {
    return expectNoParsingErrors('negative-values');
  });
  it('should parse nested functions without exception', function() {
    return expectNoParsingErrors('nested-functions');
  });
  it('should parse expressions inside url() without exception', function() {
    return expectNoParsingErrors('expression-in-url');
  });
  it('should parse variables assignment without exception', function() {
    return expectNoParsingErrors('variables');
  });
  it('should parse base64 values without exception', function() {
    return expectNoParsingErrors('base64');
  });
  return it('should parse legacy filter value without exception', function() {
    return expectNoParsingErrors('msFilter', 'css');
  });
});
