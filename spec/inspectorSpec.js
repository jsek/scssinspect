var EventEmitter, Inspector, Match, expect, fixtures;

expect = require('expect.js');

EventEmitter = require('events').EventEmitter;

Inspector = require('../lib/inspector.js');

Match = require('../lib/match.js');

fixtures = require('./fixtures');

describe('Inspector', function() {
  var found, listener;
  found = void 0;
  listener = function(match) {
    return found.push(match);
  };
  beforeEach(function() {
    return found = [];
  });
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
        diff: false
      };
      inspector = new Inspector([], opts);
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
    expect(match.nodes[0].loc.start).to.eql({
      line: 2
    });
    expect(match.nodes[0].loc.end).to.eql({
      line: 6
    });
    expect(match.nodes[1].type).to.be('ruleset');
    expect(match.nodes[1].loc.start).to.eql({
      line: 10
    });
    return expect(match.nodes[1].loc.end).to.eql({
      line: 14
    });
  });
  return it('includes a diff with the match, if enabled', function() {
    var inspector, match;
    inspector = new Inspector([fixtures['intersection-diff']], {
      diff: true
    });
    inspector.on('match', listener);
    inspector.run();
    expect(found).to.have.length(1);
    match = found[0];
    expect(match.nodes).to.have.length(2);
    expect(match.diffs).to.have.length(1);
    return expect(match.diffs[0]).to.have.length(5);
  });
});
