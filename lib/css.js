var astToCSS,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

astToCSS = function(options) {
  var _composite, _m_composite, _m_primitive, _m_simple, _simple, _suppressed, _t, _unique, hasInfo, index, syntax, tree;
  _t = function(tree) {
    var e, t;
    t = tree[index(0)];
    try {
      if (indexOf.call(Object.keys(_m_primitive), t) >= 0) {
        return _m_primitive[t];
      } else if (indexOf.call(Object.keys(_m_simple), t) >= 0) {
        return _simple(tree);
      } else if (indexOf.call(Object.keys(_m_composite), t) >= 0) {
        return _composite(tree);
      } else if (indexOf.call(_suppressed, t) >= 0) {
        return '';
      } else {
        return _unique[t](tree);
      }
    } catch (_error) {
      e = _error;
      return "[__ERROR__:" + tree + "]";
    }
  };
  _composite = function(t, i) {
    var token;
    if (i == null) {
      i = index(1);
    }
    return ((function() {
      var j, len, ref, results;
      ref = t.slice(i);
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        token = ref[j];
        results.push(_t(token));
      }
      return results;
    })()).join('').trim();
  };
  _simple = function(t) {
    return t[index(1)];
  };
  if (!options) {
    throw new Error('We need tree to translate');
  }
  tree = typeof options === 'string' ? options : options.ast;
  hasInfo = typeof tree[0] === 'object';
  syntax = options.syntax || 'css';
  index = function(i) {
    if (hasInfo) {
      return i + 1;
    } else {
      return i;
    }
  };
  _m_simple = {
    'attrselector': 1,
    'combinator': 1,
    'ident': 1,
    'nth': 1,
    'number': 1,
    'operator': 1,
    'raw': 1,
    'string': 1,
    'unary': 1,
    'unknown': 1
  };
  _m_composite = {
    'atruleb': 1,
    'atrulerq': 1,
    'atrulers': 1,
    'atrules': 1,
    'condition': 1,
    'dimension': 1,
    'filterv': 1,
    'include': 1,
    'loop': 1,
    'mixin': 1,
    'simpleselector': 1,
    'progid': 1,
    'property': 1,
    'ruleset': 1,
    'stylesheet': 1,
    'value2': 1
  };
  _m_primitive = {
    'cdc': 'cdc',
    'cdo': 'cdo',
    'declDelim': '',
    'delim': '',
    'namespace': '|',
    'parentselector': '&',
    'propertyDelim': ':',
    's': ' '
  };
  _unique = {
    'arguments': function(t) {
      return '(' + _composite(t) + ')';
    },
    'atkeyword': function(t) {
      return '@' + _t(t[index(1)]);
    },
    'atruler': function(t) {
      return _t(t[index(1)]) + _t(t[index(2)]) + '{' + _t(t[index(3)]) + '}';
    },
    'attrib': function(t) {
      return '[' + _composite(t) + ']';
    },
    'block': function(t) {
      var rules, rulesText, token;
      rules = ((function() {
        var j, len, ref, results;
        ref = t.slice(index(1));
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          token = ref[j];
          results.push(_t(token));
        }
        return results;
      })()).filter(function(s) {
        return s.trim();
      });
      rulesText = rules.sort().join('; ');
      if (syntax === 'sass') {
        return rulesText;
      } else {
        return '{ ' + rulesText + ' }';
      }
    },
    'braces': function(t) {
      return t[index(1)] + _composite(t, index(3)) + t[index(2)];
    },
    'class': function(t) {
      return '.' + _t(t[index(1)]);
    },
    'declaration': function(t) {
      var token;
      return ((function() {
        var j, len, ref, results;
        ref = t.slice(index(1));
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          token = ref[j];
          results.push(_t(token));
        }
        return results;
      })()).join('');
    },
    'selector': function(t) {
      var token;
      return ((function() {
        var j, len, ref, results;
        ref = t.slice(index(1));
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          token = ref[j];
          results.push(_t(token));
        }
        return results;
      })()).filter(function(s) {
        return s.trim();
      }).sort().join(', ') + ' ';
    },
    'value': function(t) {
      var token;
      return ((function() {
        var j, len, ref, results;
        ref = t.slice(index(1));
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          token = ref[j];
          results.push(_t(token));
        }
        return results;
      })()).filter(function(s) {
        return s.trim();
      }).join(' ');
    },
    'default': function(t) {
      return '!' + _composite(t) + 'default';
    },
    'escapedString': function(t) {
      return '~' + t[index(1)];
    },
    'filter': function(t) {
      return _t(t[index(1)]) + ':' + _t(t[index(2)]);
    },
    'functionExpression': function(t) {
      return 'expression(' + t[index(1)] + ')';
    },
    'function': function(t) {
      return _simple(t[index(1)]) + '(' + _composite(t[hasInfo ? 3 : 2]) + ')';
    },
    'global': function(t) {
      return '!' + _composite(t) + 'global';
    },
    'important': function(t) {
      return '!' + _composite(t) + 'important';
    },
    'interpolatedVariable': function(t) {
      return (syntax === 'less' ? '@{' : '#{$') + _t(t[index(1)]) + '}';
    },
    'nthselector': function(t) {
      return ':' + _simple(t[index(1)]) + '(' + _composite(t, index(2)) + ')';
    },
    'percentage': function(t) {
      return _t(t[index(1)]) + '%';
    },
    'placeholder': function(t) {
      return '%' + _t(t[index(1)]);
    },
    'pseudoc': function(t) {
      return ':' + _t(t[index(1)]);
    },
    'pseudoe': function(t) {
      return '::' + _t(t[index(1)]);
    },
    'shash': function(t) {
      return '#' + t[index(1)];
    },
    'uri': function(t) {
      return 'url(' + _composite(t) + ')';
    },
    'variable': function(t) {
      return (syntax === 'less' ? '@' : '$') + _t(t[index(1)]);
    },
    'variableslist': function(t) {
      return _t(t[index(1)]) + '...';
    },
    'vhash': function(t) {
      return '#' + t[index(1)];
    }
  };
  _suppressed = ['commentML', 'commentSL'];
  return _t(tree);
};

exports.astToCSS = astToCSS;
