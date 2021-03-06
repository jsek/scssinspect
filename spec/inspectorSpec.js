var EventEmitter, Inspector, Match, expect, fixtures;

expect = require('expect.js');

EventEmitter = require('events').EventEmitter;

Inspector = require('../lib/inspector.js');

Match = require('../lib/match.js');

fixtures = require('./fixtures');

describe('Inspector', function() {
  var expectMatchCount, found, listener;
  found = void 0;
  listener = function(match) {
    return found.push(match);
  };
  beforeEach(function() {
    return found = [];
  });
  expectMatchCount = function(fixture, opts, count) {
    var inspector;
    inspector = new Inspector([fixture], opts);
    inspector.on('match', listener);
    inspector.run();
    return expect(found).to.have.length(count);
  };
  describe('constructor', function() {
    it('inherits from EventEmitter', function() {
      return expect(new Inspector).to.be.an(EventEmitter);
    });
    it('accepts an array of file paths', function() {
      var filePaths, inspector;
      filePaths = ['path1.scss', 'path2.scss'];
      inspector = new Inspector(filePaths);
      return expect(inspector._filePaths).to.be(filePaths);
    });
    return it('accepts an options object', function() {
      var inspector, opts;
      opts = {
        diff: 'none',
        threshold: 151
      };
      inspector = new Inspector([], opts);
      expect(inspector._threshold).to.be(opts.threshold);
      return expect(inspector._diff).to.be(opts.diff);
    });
  });
  describe('run', function() {
    it('emits a start event', function() {
      var emitted, inspector;
      emitted = void 0;
      inspector = new Inspector([fixtures.intersection]);
      inspector.on('start', function() {
        return emitted = true;
      });
      inspector.run();
      return expect(emitted).to.be(true);
    });
    it('emits an end event', function() {
      var emitted, inspector;
      emitted = void 0;
      inspector = new Inspector([fixtures.intersection]);
      inspector.on('end', function() {
        return emitted = true;
      });
      inspector.run();
      return expect(emitted).to.be(true);
    });
    return it('emits the "match" event when a match is found', function() {
      var inspector;
      inspector = new Inspector([fixtures.intersection]);
      inspector.on('match', listener);
      inspector.run();
      return expect(found).to.have.length(1);
    });
  });
  it('can find an exact match between two rules', function() {
    var inspector, match;
    inspector = new Inspector([fixtures.intersection]);
    inspector.on('match', listener);
    inspector.run();
    expect(found).to.have.length(1);
    match = found[0];
    expect(match.nodes).to.have.length(2);
    expect(match.nodes[0].type).to.be('ruleset');
    expect(match.nodes[0].loc.start).to.eql(2);
    expect(match.nodes[0].loc.end).to.eql(6);
    expect(match.nodes[1].type).to.be('ruleset');
    expect(match.nodes[1].loc.start).to.eql(10);
    return expect(match.nodes[1].loc.end).to.eql(14);
  });
  it('includes a diff with the match, if enabled', function() {
    var inspector, match, opts;
    opts = {
      threshold: 0,
      diff: 'lines'
    };
    inspector = new Inspector([fixtures['intersection-diff']], opts);
    inspector.on('match', listener);
    inspector.run();
    expect(found).to.have.length(1);
    match = found[0];
    expect(match.nodes).to.have.length(2);
    expect(match.diffs).to.have.length(1);
    return expect(match.diffs[0]).to.have.length(5);
  });
  describe('threshold (characters)', function() {
    it('matches rules if threshold is lower than rule size', function() {
      var opts;
      opts = {
        threshold: 70,
        thresholdType: 'char'
      };
      return expectMatchCount(fixtures.intersection, opts, 1);
    });
    return it('does not match rules that exceed threshold', function() {
      var opts;
      opts = {
        threshold: 80,
        thresholdType: 'char'
      };
      return expectMatchCount(fixtures.intersection, opts, 0);
    });
  });
  describe('threshold (tokens)', function() {
    it('matches rules if threshold is lower than rule size', function() {
      var opts;
      opts = {
        threshold: 30,
        thresholdType: 'token'
      };
      return expectMatchCount(fixtures.intersection, opts, 1);
    });
    return it('does not match rules that exceed threshold', function() {
      var opts;
      opts = {
        threshold: 40,
        thresholdType: 'token'
      };
      return expectMatchCount(fixtures.intersection, opts, 0);
    });
  });
  describe('threshold (properties)', function() {
    it('matches rules if threshold is lower than rule size', function() {
      var opts;
      opts = {
        threshold: 2,
        thresholdType: 'property'
      };
      return expectMatchCount(fixtures.intersection, opts, 1);
    });
    return it('does not match rules that exceed threshold', function() {
      var opts;
      opts = {
        threshold: 5,
        thresholdType: 'property'
      };
      return expectMatchCount(fixtures.intersection, opts, 0);
    });
  });
  describe('anonymize (number)', function() {
    it('matches rules if the only difference are numbers', function() {
      var opts;
      opts = {
        threshold: 0,
        thresholdType: 'char',
        anonymize: ['number']
      };
      return expectMatchCount(fixtures['anonymize-number'], opts, 1);
    });
    return it('does not match rules if the only difference are strings', function() {
      var opts;
      opts = {
        threshold: 0,
        thresholdType: 'char',
        anonymize: ['number']
      };
      return expectMatchCount(fixtures['anonymize-string'], opts, 0);
    });
  });
  describe('anonymize (string)', function() {
    it('matches rules if the only difference are strings', function() {
      var opts;
      opts = {
        threshold: 0,
        thresholdType: 'char',
        anonymize: ['string']
      };
      return expectMatchCount(fixtures['anonymize-string'], opts, 1);
    });
    return it('does not match rules if the only difference are numbers', function() {
      var opts;
      opts = {
        threshold: 0,
        thresholdType: 'char',
        anonymize: ['string']
      };
      return expectMatchCount(fixtures['anonymize-number'], opts, 0);
    });
  });
  describe('anonymize (selector)', function() {
    it('matches rules if the only difference are selectors', function() {
      var opts;
      opts = {
        threshold: 2,
        thresholdType: 'property',
        anonymize: ['selector']
      };
      return expectMatchCount(fixtures['anonymize-selector'], opts, 1);
    });
    return it('does not match rules if the only difference are selectors and anonymize option is not set for selectors', function() {
      var opts;
      opts = {
        threshold: 2,
        thresholdType: 'property',
        anonymize: ['string']
      };
      return expectMatchCount(fixtures['anonymize-selector'], opts, 0);
    });
  });
  describe('size (char)', function() {
    var localThreshold;
    localThreshold = 69;
    it('should be correct value when type is "char" and called with default settings', function() {
      var opts;
      opts = {
        threshold: localThreshold,
        thresholdType: 'char',
        anonymize: []
      };
      return expectMatchCount(fixtures['size-test-char'], opts, 1);
    });
    it('should be correct value when type is "char" and called with anonymized classes', function() {
      var opts;
      opts = {
        threshold: localThreshold,
        thresholdType: 'char',
        anonymize: ['class']
      };
      return expectMatchCount(fixtures['size-test-char'], opts, 2);
    });
    return it('should use highest possible threshold for this spec', function() {
      var opts;
      opts = {
        threshold: localThreshold + 2,
        thresholdType: 'token',
        anonymize: ['class']
      };
      return expectMatchCount(fixtures['size-test-token'], opts, 0);
    });
  });
  return describe('size (token)', function() {
    var localThreshold;
    localThreshold = 40;
    it('should be correct value when type is "token" and called with default settings', function() {
      var opts;
      opts = {
        threshold: localThreshold,
        thresholdType: 'token',
        anonymize: []
      };
      return expectMatchCount(fixtures['size-test-token'], opts, 1);
    });
    it('should be correct value when type is "token" and called with anonymized classes', function() {
      var opts;
      opts = {
        threshold: localThreshold,
        thresholdType: 'token',
        anonymize: ['class']
      };
      return expectMatchCount(fixtures['size-test-token'], opts, 2);
    });
    return it('should use highest possible threshold for this spec', function() {
      var opts;
      opts = {
        threshold: localThreshold + 2,
        thresholdType: 'token',
        anonymize: ['class']
      };
      return expectMatchCount(fixtures['size-test-token'], opts, 0);
    });
  });
});
