var Anonymizer, children, dfs;

children = function(node) {
  return node.slice(1);
};

dfs = function(node, callback) {
  var c, i, len, ref, results;
  if (node) {
    if (callback(node) !== false) {
      ref = children(node);
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        c = ref[i];
        results.push(dfs(c, callback));
      }
      return results;
    }
  }
};

Anonymizer = (function() {
  function Anonymizer() {}

  Anonymizer.prototype._index = function(x) {
    if (this.needInfo) {
      return x + 1;
    } else {
      return x;
    }
  };

  Anonymizer.prototype._anonymizeValue = function(tree, type, value) {
    return dfs(tree, (function(_this) {
      return function(n) {
        if ((n != null ? n[_this._index(0)] : void 0) === type) {
          return n[_this._index(1)] = value;
        } else {
          return true;
        }
      };
    })(this));
  };

  Anonymizer.prototype.anonymize = function(tree, type, needInfo) {
    this.needInfo = !!needInfo;
    switch (type) {
      case 'number':
        return this._anonymizeValue(tree, type, 0);
      case 'string':
        return this._anonymizeValue(tree, type, '"?"');
    }
  };

  return Anonymizer;

})();

module.exports = function() {
  return new Anonymizer();
};
