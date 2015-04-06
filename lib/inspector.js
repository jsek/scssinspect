var EventEmitter, Inspector, Match, astToCSS, fs, parse, util,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

util = require('util');

EventEmitter = require('events').EventEmitter;

parse = require('../parser/gonzales').cssToAST;

fs = require('fs');

Match = require('./match');

astToCSS = require('./css').astToCSS;

Inspector = (function(superClass) {
  extend(Inspector, superClass);

  function Inspector(_filePaths, opts) {
    this._filePaths = _filePaths != null ? _filePaths : [];
    if (opts == null) {
      opts = {};
    }
    this._threshold = opts.threshold === 0 ? 0 : opts.threshold || 50;
    this._thresholdType = opts.thresholdType || 'char';
    this._ignoreValues = opts.ignoreValues;
    this._diff = opts.diff;
    this._skip = opts.skip;
    this._syntax = opts.syntax;
    this._hash = Object.create(null);
    this.numFiles = this._filePaths.length;
    if (this._diff !== 'none') {
      this._fileContents = {};
    }
  }

  Inspector.prototype.run = function() {
    var contents, err, filePath, i, len, opts, ref;
    opts = {
      encoding: 'utf8'
    };
    this.emit('start');
    ref = this._filePaths;
    for (i = 0, len = ref.length; i < len; i++) {
      filePath = ref[i];
      filePath = filePath.replace(/\//g, '\\');
      contents = fs.readFileSync(filePath, opts);
      if (this._diff !== 'none') {
        this._fileContents[filePath] = contents.split('\n');
      }
      try {
        this._parse(filePath, contents);
      } catch (_error) {
        err = _error;
        if (this._skip) {
          this.numFiles--;
          this.emit('warning', {
            message: 'Cannot parse file',
            path: filePath,
            error: err
          });
        } else {
          throw err;
        }
      }
    }
    if (!this._syntax) {
      this._analyze();
      return this.emit('end');
    }
  };

  Inspector.prototype._parse = function(filePath, contents) {
    var syntaxTree;
    syntaxTree = parse({
      css: contents,
      syntax: 'scss',
      needInfo: true
    });
    if (this._syntax) {
      return console.log(syntaxTree);
    } else {
      return this._walk(syntaxTree, (function(_this) {
        return function(rule) {
          _this._insert(rule);
          return rule.loc.source = filePath;
        };
      })(this));
    }
  };

  Inspector.prototype._analyze = function() {
    var key, match, results, rules;
    results = [];
    for (key in this._hash) {
      rules = this._hash[key];
      if ((rules != null ? rules.length : void 0) > 1) {
        match = new Match(rules);
        if (this._diff !== 'none') {
          match.generateDiffs(this._fileContents, this._diff);
        }
        results.push(this.emit('match', match));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  Inspector.prototype._walk = function(syntaxTree, fn) {
    var block, i, len, ref, results, ruleset;
    results = [];
    for (i = 0, len = syntaxTree.length; i < len; i++) {
      ruleset = syntaxTree[i];
      if (!((ref = ruleset[1]) === 'ruleset' || ref === 'mediaquery' || ref === 'include' || ref === 'mixin')) {
        continue;
      }
      fn(ruleset);
      results.push((function() {
        var j, len1, results1;
        results1 = [];
        for (j = 0, len1 = ruleset.length; j < len1; j++) {
          block = ruleset[j];
          if (block[1] === 'block') {
            results1.push(this._walk(block, fn));
          }
        }
        return results1;
      }).call(this));
    }
    return results;
  };

  Inspector.prototype._insert = function(rule) {
    var key;
    key = this._getHashKey(rule);
    if (this._doesExceedThreshold(key, rule)) {
      if (!this._hash[key]) {
        this._hash[key] = [];
      }
      return this._hash[key].push(rule);
    }
  };

  Inspector.prototype._doesExceedThreshold = function(hash, syntaxTree) {
    var propertiesLength, ref, tokensLength;
    if (this._thresholdType === 'char') {
      return hash.length >= this._threshold;
    } else if (this._thresholdType === 'token') {
      tokensLength = parse({
        css: hash,
        syntax: 'scss',
        needInfo: true,
        sizeOnly: true
      });
      return tokensLength >= this._threshold;
    } else if (this._thresholdType === 'property') {
      propertiesLength = (ref = JSON.stringify(syntaxTree).match(/"declaration",\[\{[^\}]+\},"property"/g)) != null ? ref.length : void 0;
      return propertiesLength >= this._threshold;
    } else {
      throw new Error('Unknown type of element to apply threshold');
    }
  };

  Inspector.prototype._getHashKey = function(ruleset) {
    var ref, ref1, structure;
    structure = astToCSS({
      ast: ruleset,
      syntax: 'scss'
    });
    ruleset.type = 'ruleset';
    ruleset.pos = "(" + ruleset[0].ln + ", " + ((ref = ruleset[0].end) != null ? ref.ln : void 0) + ")";
    ruleset.loc = {
      start: {
        line: ruleset[0].ln
      },
      end: {
        line: (ref1 = ruleset[0].end) != null ? ref1.ln : void 0
      }
    };
    return structure;
  };

  return Inspector;

})(EventEmitter);

module.exports = Inspector;
