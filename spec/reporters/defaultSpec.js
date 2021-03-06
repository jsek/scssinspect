var DefaultReporter, Inspector, expect, fixtures, helpers;

expect = require('expect.js');

fixtures = require('../fixtures');

helpers = require('../helpers');

DefaultReporter = require('../../lib/reporters/default');

Inspector = require('../../lib/inspector');

describe('DefaultReporter', function() {
  describe('constructor', function() {
    return it('accepts an inspector as an argument', function() {
      var inspector, reporter;
      inspector = new Inspector(['']);
      reporter = new DefaultReporter(inspector);
      return expect(reporter._inspector).to.be(inspector);
    });
  });
  it('prints the summary on end', function() {
    helpers.captureOutput();
    return helpers.safeTestOutput(Inspector, DefaultReporter, 'no-match', function(o) {
      return expect(o).to.be('\n No matches found across 1 file \n');
    });
  });
  return describe('given a match', function() {
    beforeEach(function() {
      return helpers.captureOutput();
    });
    it('prints the number of instances, and their location', function() {
      var file;
      file = fixtures.intersection;
      return helpers.safeTestOutput(Inspector, DefaultReporter, 'intersection', {
        diff: 'none',
        ignoreSummary: true
      }, function(o) {
        return expect(o).to.be("\nMatch - 2 instances\n" + file + ":2,6\n" + file + ":10,14\n");
      });
    });
    return it('prints the diffs if enabled', function() {
      var file;
      file = fixtures.intersection;
      return helpers.safeTestOutput(Inspector, DefaultReporter, 'intersection', {
        diff: 'lines',
        ignoreSummary: true
      }, function(o) {
        return expect(o).to.be("\nMatch - 2 instances\n" + file + ":2,6\n" + file + ":10,14\n\n- " + file + ":2,6\n+ " + file + ":10,14\n    .sub-selector1, .sub-selector2 {\n        border: 2px solid red;\n        color: blue;\n        z-index: 11;\n    }\n");
      });
    });
  });
});
