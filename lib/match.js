var Match, diff, strip;

diff = require('diff');

strip = require('strip-indent');


/**
 * Creates a new Match, consisting of an array of nodes. If generated, an
 * instance also contains an array of diffs created with diff.
 */

Match = (function() {

  /**
   * @constructor
  #
   * @param {Node[]} nodes An array of matching nodes
   */
  function Match(nodes) {
    this.nodes = nodes;
    this.diffs = [];
  }


  /**
   * Uses diff to generate line-based diffs for the nodes, given an object
   * mapping source file paths to their contents. If a match contains multiple
   * nodes, 2-way diffs are generated for each against the first node in the
   * array. The diffs are pushed into the diffs array in the same order as
   * the nodes.
  #
   * @param {object} fileContents The file paths and their contents
   */

  Match.prototype.generateDiffs = function(fileContents) {
    var base, curr, i, len, node, ref, results;
    base = this._getLines(fileContents, this.nodes[0]);
    ref = this.nodes.slice(1);
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      node = ref[i];
      curr = this._getLines(fileContents, node);
      results.push(this.diffs.push(diff.diffLines(base, curr)));
    }
    return results;
  };


  /**
   * Returns a string containing the source lines for the supplied node.
  #
   * @param   {object} fileContents The file paths and their contents
   * @param   {Node}   node         The node for which to extract its lines
   * @returns {String} The lines corresponding to the node's body
   */

  Match.prototype._getLines = function(fileContents, node) {
    var end, lines, start;
    lines = fileContents[node.loc.source];
    start = node.loc.start.line - 1;
    end = node.loc.end.line;
    return strip(lines.slice(start, end).join('\n'));
  };

  return Match;

})();

module.exports = Match;
