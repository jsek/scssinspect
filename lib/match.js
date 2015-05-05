var Match, diff, strip;

diff = require('diff');

strip = require('strip-indent');


/**
 * Creates a new Match, consisting of an array of nodes. If generated, an
 * instance also contains an array of diffs created with diff.
 */

Match = (function() {
  function Match(nodes, duplicationSize) {
    this.nodes = nodes;
    this.duplicationSize = duplicationSize;
    this.diffs = [];
  }


  /**
   * Uses diff to generate line-based diffs for the nodes, given an object
   * mapping source file paths to their contents. If a match contains multiple
   * nodes, 2-way diffs are generated for each against the first node in the
   * array. The diffs are pushed into the diffs array in the same order as
   * the nodes.
   */

  Match.prototype.generateDiffs = function(fileContents, diffType) {
    var base, curr, i, len, method, node, ref, results;
    base = this._getLines(fileContents, this.nodes[0]);
    method = this._getMethod(diffType);
    if (typeof method === 'function') {
      ref = this.nodes.slice(1);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        node = ref[i];
        curr = this._getLines(fileContents, node);
        results.push(this.diffs.push(this._getMethod(diffType)(base, curr)));
      }
      return results;
    }
  };


  /**
   * Returns a method from diff object for the given type.
   */

  Match.prototype._getMethod = function(diffType) {
    if (diffType === 'css') {
      return diff.diffCss;
    }
    if (diffType === 'lines') {
      return diff.diffLines;
    }
    return null;
  };


  /**
   * Returns a string containing the source lines for the supplied node.
   */

  Match.prototype._getLines = function(fileContents, node) {
    var end, lines, start;
    lines = fileContents[node.loc.source];
    start = node.loc.start - 1;
    end = node.loc.end;
    return strip(lines.slice(start, end).join('\n'));
  };

  return Match;

})();

module.exports = Match;
