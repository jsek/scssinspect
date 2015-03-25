gonzales = require('gonzales-pe')
astToCSS = require('./lib/css').astToCSS

css = '''
    .a2,.a1 {
        .b2 {
            border: 2px solid red;
            color: blue;
            z-index: 11;
        }
    }
    .a1, 
    .a2 {
        z-index: 11;
        color: blue;
        border: 2px solid red;
    }
'''

###
    What are common changes after copy/paste?  ->  Small modifications
        -> adding selectors         2 (relative impact on diff)
        -> renaming selectors       1
        -> adding/removing rules    2    
        -> changing values          1
        
    What are common differences in messy codebase?  ->  Small restructurization
        -> reordering               0
        -> wrapping                 3 (or same as selectorschanges?)
###

u = 
    sx: (x) -> JSON.stringify x
    px: (x) -> JSON.parse x
    keys:(x) -> Object.keys(x) 
    type:(x) -> typeof x 

getSimpleSelectorText = (selectorData) ->
    head = selectorData[1]
    selectorHeadType = head[1]
    if selectorHeadType is 'ident'
        return head[2]
    else if selectorHeadType is 'class'
        return '.' + getSimpleSelectorText(head[1..])
    else if selectorHeadType is 'shash'
        return '#' + head[2]
    else if selectorData.length > 1
        return getSimpleSelectorText(selectorData[1..])
        
        
getRuleText = (rule) ->
    ruleText =  ''
    
    for property in rule when property[1] is 'property'
        ruleText += "#{getPropertyName(property[2])}:"
    
    for value in rule when value[1] is 'value'
        ruleText += "#{getPropertyValue(value)}"
        
    return ruleText
        
        
getPropertyValue = (valueData) ->
    valueText = ''
    #return u.sx valueData
    for token in valueData[1..]
        tokenType = token[1]
        if tokenType is 'ident'
            valueText += token[2]
        else if tokenType is 'number'
            valueText += token[2]
        else if tokenType is 'dimension'
            valueText += getPropertyValue token
        else if tokenType is 'vhash'
            valueText += '#' + token[2]
        else if tokenType is 's'
            valueText += token[2]
            
    return valueText.trim()
        
        
getPropertyName = (propertyData) ->
    tokenType = propertyData[1]
    if tokenType is 'ident'
        return propertyData[2]


getNestedRulesets = (ruleset) ->
    for block in ruleset when block[1] is 'block'
        printRuleset(block)
           

getSelectors = (ruleset) ->
    for selector in ruleset when selector[1] is 'selector'
        for simpleselector in selector[1..] when simpleselector[1] is 'simpleselector'
            getSimpleSelectorText(simpleselector[1..])
            

getRules = (ruleset) ->
    for block in ruleset when block[1] is 'block'
        for rule in block[1..] when rule[1] is 'declaration'
            getRuleText(rule)
        
                
                    
printRuleset = (ast) ->
    structure = ''
    for ruleset in ast when ruleset[1] is 'ruleset'
        structure += "#{getSelectors(ruleset)[0]?.sort().join(', ')} { "
        structure += "#{getNestedRulesets(ruleset)?.sort().join(' ').replace(/\n/g,'')}"
        structure += "#{getRules(ruleset)[0]?.sort().join(', ')}"
        structure += " }\n"
        
        console.log pos = "(#{ruleset[0].ln} - ?)\t"
    return structure

printRuleset_short = (ast) -> 
    for ruleset in ast when ruleset[1] is 'ruleset'
        astToCSS({ast:ruleset,syntax:'scss'}) 

inspect = (codeA) ->
    console.log gonzales.cssToAST(css:codeA, syntax:'scss', needInfo: true)
    console.log printRuleset gonzales.cssToAST(css:codeA, syntax:'scss', needInfo: true)


inspect(css)
