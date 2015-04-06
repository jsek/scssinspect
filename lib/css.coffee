astToCSS = (options) ->

    _t = (tree) ->
        t = tree[index(0)]
        try
            if t in Object.keys(_m_primitive)        then return _m_primitive[t]
            else if t in Object.keys(_m_simple)      then return _simple(tree)
            else if t in Object.keys(_m_composite)   then return _composite(tree)
            else if t in _suppressed                 then return ''
            else                                          return _unique[t](tree)
        catch e
            return "[__ERROR__:#{tree}]"

    _composite = (t, i) ->
        i ?= index(1)
        (_t(token) for token in t[i..]).join('').trim()

    _simple = (t) -> t[index(1)]

    unless options
        throw new Error('We need tree to translate')
    
    tree = if typeof options == 'string' then options else options.ast
    hasInfo = typeof tree[0] == 'object'
    syntax = options.syntax or 'css'

    index = (i) -> if hasInfo then i + 1 else i

    _m_simple = 
        'attrselector'  : 1
        'combinator'    : 1
        'ident'         : 1
        'nth'           : 1
        'number'        : 1
        'operator'      : 1
        'raw'           : 1
        'string'        : 1
        'unary'         : 1
        'unknown'       : 1
        
    _m_composite = 
        'atruleb'       : 1
        'atrulerq'      : 1
        'atrulers'      : 1
        'atrules'       : 1
        'condition'     : 1
        'dimension'     : 1
        'filterv'       : 1
        'include'       : 1
        'loop'          : 1
        'mixin'         : 1
        'simpleselector': 1
        'progid'        : 1
        'property'      : 1
        'ruleset'       : 1
        'stylesheet'    : 1
        'value2'        : 1
        
    _m_primitive = 
        'cdc'           : 'cdc'
        'cdo'           : 'cdo'
        'declDelim'     : ''
        'delim'         : ''
        'namespace'     : '|'
        'parentselector': '&'
        'propertyDelim' : ':'
        's'             : ' '

    _unique = 
        'arguments'     : (t) -> '(' + _composite(t) + ')'
        'atkeyword'     : (t) -> '@' + _t(t[index(1)])
        'atruler'       : (t) -> _t(t[index(1)]) + _t(t[index(2)]) + '{' + _t(t[index(3)]) + '}'
        'attrib'        : (t) -> '[' + _composite(t) + ']'
        'block'         : (t) ->
            rules = (_t(token) for token in t[index(1)..]).filter((s) -> s.trim())
            rulesText = rules.sort().join('; ')
            if syntax == 'sass' then rulesText else '{ ' + rulesText + ' }'
        'braces'        : (t) -> t[index(1)] + _composite(t, index(3)) + t[index(2)]
        'class'         : (t) -> '.' + _t(t[index(1)])
        'declaration'   : (t) -> (_t(token) for token in t[index(1)..]).join ''
        'selector'      : (t) -> (_t(token) for token in t[index(1)..]).filter((s) -> s.trim()).sort().join(', ') + ' '
        'value'         : (t) -> (_t(token) for token in t[index(1)..]).filter((s) -> s.trim()).join(' ')
        'default'       : (t) -> '!' + _composite(t) + 'default'
        'escapedString' : (t) -> '~' + t[index(1)]
        'filter'        : (t) -> _t(t[index(1)]) + ':' + _t(t[index(2)])
        'functionExpression': (t) -> 'expression(' + t[index(1)] + ')'
        'function'      : (t) -> _simple(t[index(1)]) + '(' + _composite(t[if hasInfo then 3 else 2]) + ')'
        'global'        : (t) -> '!' + _composite(t) + 'global'
        'interpolatedVariable': (t) -> (if syntax == 'less' then '@{' else '#{$') + _t(t[index(1)]) + '}'
        'nthselector'   : (t) -> ':' + _simple(t[index(1)]) + '(' + _composite(t, index(2)) + ')'
        'percentage'    : (t) -> _t(t[index(1)]) + '%'
        'placeholder'   : (t) -> '%' + _t(t[index(1)])
        'pseudoc'       : (t) -> ':' + _t(t[index(1)])
        'pseudoe'       : (t) -> '::' + _t(t[index(1)])
        'shash'         : (t) -> '#' + t[index(1)]
        'uri'           : (t) -> 'url(' + _composite(t) + ')'
        'variable'      : (t) -> (if syntax == 'less' then '@' else '$') + _t(t[index(1)])
        'variableslist' : (t) -> _t(t[index(1)]) + '...'
        'vhash'         : (t) -> '#' + t[index(1)]
        
    _suppressed = [
        'commentML'
        'commentSL'
    ]
        
    _t tree

exports.astToCSS = astToCSS
