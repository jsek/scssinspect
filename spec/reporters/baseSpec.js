var BaseReporter, Inspector, TestReporter, expect, fixtures, helpers,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

expect = require('expect.js');

fixtures = require('../fixtures');

helpers = require('../helpers');

BaseReporter = require('../../lib/reporters/base');

Inspector = require('../../lib/inspector');

TestReporter = (function(superClass) {
  extend(TestReporter, superClass);

  function TestReporter(inspector) {
    TestReporter.__super__.constructor.call(this, inspector);
    this._registerSummary();
  }

  TestReporter.prototype._getOutput = function(match) {};

  return TestReporter;

})(BaseReporter);

describe('BaseReporter', function() {
  describe('constructor', function() {
    it('accepts an inspector as an argument', function() {
      var inspector, reporter;
      inspector = new Inspector(['']);
      reporter = new BaseReporter(inspector);
      return expect(reporter._inspector).to.be(inspector);
    });
    return it('registers a listener for the match event', function() {
      var inspector, reporter;
      inspector = new Inspector(['']);
      reporter = new BaseReporter(inspector);
      return expect(inspector.listeners('match')).to.have.length(1);
    });
  });
  describe('given a match', function() {
    beforeEach(function() {
      return helpers.captureOutput();
    });
    it('increments the number found', function() {
      var inspector, reporter;
      inspector = new Inspector([fixtures.intersection], {
        threshold: 3
      });
      reporter = new TestReporter(inspector);
      inspector.emit('match', {});
      helpers.restoreOutput();
      return expect(reporter._found).to.be(1);
    });
    return it('invokes _getOutput', function() {
      var inspector, reporter;
      inspector = new Inspector([fixtures.intersection], {
        threshold: 3
      });
      reporter = new TestReporter(inspector);
      reporter._getOutput = function(match) {
        return match;
      };
      inspector.emit('match', 'invoked');
      helpers.restoreOutput();
      return expect(helpers.getOutput()).to.be('invoked');
    });
  });
  return describe('summary', function() {
    beforeEach(function() {
      return helpers.captureOutput();
    });
    it('can be printed on inspector end', function() {
      return helpers.safeTestOutput(Inspector, TestReporter, 'intersection', function(o) {
        return expect(o).to.not.be(null);
      });
    });
    it('prints the correct results if no matches were found', function() {
      return helpers.safeTestOutput(Inspector, TestReporter, 'no-match', function(o) {
        return expect(o).to.be('\n No matches found across 1 file \n');
      });
    });
    return it('prints the correct results if matches were found', function() {
      return helpers.safeTestOutput(Inspector, TestReporter, 'intersection', function(o) {
        return expect(o).to.be('\n 1 match found across 1 file \n Total size: 79 characters \n');
      });
    });
  });
});
