var Match, expect, fixtures, fs, parse;

expect = require('expect.js');

fs = require('fs');

parse = require('../parser/gonzales').cssToAST;

fixtures = require('./fixtures');

Match = require('../lib/match');

describe('Match', function() {
  var getFixture;
  getFixture = function(file) {
    var content, contents;
    content = fs.readFileSync(file, {
      encoding: 'utf8'
    }).replace(/\r\n/g, '\n');
    contents = {};
    contents[file] = content.split('\n');
    return {
      contents: contents
    };
  };
  describe('constructor', function() {
    it('accepts an array of nodes, storing them at match.nodes', function() {
      var match, mockNodes;
      mockNodes = [
        {
          type: 'FunctionDeclaration'
        }, {
          type: 'Literal'
        }
      ];
      match = new Match(mockNodes);
      return expect(match.nodes).to.be(mockNodes);
    });
    return it('initializes the object with an empty array for match.diffs', function() {
      var match;
      match = new Match([]);
      return expect(match.diffs).to.eql([]);
    });
  });
  return describe('generateDiffs', function() {
    it('uses jsdiff to generate a diff of two different rules', function() {
      var file, fixture, match, rules;
      file = fixtures['intersection-diff'];
      fixture = getFixture(file);
      rules = [
        {
          loc: {
            start: {
              line: 2
            },
            end: {
              line: 6
            },
            source: file
          }
        }, {
          loc: {
            start: {
              line: 10
            },
            end: {
              line: 13
            },
            source: file
          }
        }
      ];
      match = new Match(rules);
      match.generateDiffs(fixture.contents, 'lines');
      return expect(match.diffs).to.eql([
        [
          {
            value: '.b, .a {\n',
            count: 1,
            added: true,
            removed: void 0
          }, {
            value: '.a, .b {\n',
            count: 1,
            added: void 0,
            removed: true
          }, {
            value: '.\n    border: 2px solid red;\n    color: blue;\n'.slice(2),
            count: 2
          }, {
            value: '.\n    z-index: 11; }'.slice(2),
            count: 1,
            added: true,
            removed: void 0
          }, {
            value: '.\n    z-index: 11;\n}'.slice(2),
            count: 2,
            added: void 0,
            removed: true
          }
        ]
      ]);
    });
    it('uses jsdiff to generate a diff of two identical rules', function() {
      var file, fixture, match, rules;
      file = fixtures['intersection'];
      fixture = getFixture(file);
      rules = [
        {
          loc: {
            start: {
              line: 2
            },
            end: {
              line: 6
            },
            source: file
          }
        }, {
          loc: {
            start: {
              line: 10
            },
            end: {
              line: 14
            },
            source: file
          }
        }
      ];
      match = new Match(rules);
      match.generateDiffs(fixture.contents, 'lines');
      return expect(match.diffs).to.eql([
        [
          {
            value: '.sub-selector1, .sub-selector2 {\n    border: 2px solid red;\n    color: blue;\n    z-index: 11;\n}'
          }
        ]
      ]);
    });
    return it('strips indentation to generate clean diffs', function() {
      var file, fixture, match, rules;
      file = fixtures['indentation'];
      fixture = getFixture(file);
      rules = [
        {
          loc: {
            start: {
              line: 1
            },
            end: {
              line: 3
            },
            source: file
          }
        }, {
          loc: {
            start: {
              line: 5
            },
            end: {
              line: 6
            },
            source: file
          }
        }
      ];
      match = new Match(rules);
      match.generateDiffs(fixture.contents, 'lines');
      return expect(match.diffs).to.eql([
        [
          {
            value: '.sub-selector2, .sub-selector1 {\n',
            count: 1
          }, {
            value: '.\n    border: 2px solid red; }'.slice(2),
            count: 1,
            added: true,
            removed: void 0
          }, {
            value: '.\n    border: 2px solid red;\n}'.slice(2),
            count: 2,
            added: void 0,
            removed: true
          }
        ]
      ]);
    });
  });
});
