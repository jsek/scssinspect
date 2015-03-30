## Required parser patches

Scss parser (gonzales@2.0.2) is copied into /parser directory. Most of the changes
are visible in the history of /parser/gonzales.css-to-ast.js, but some of them were 
done before the file was added. These are documented below:
 
 - Parser patch 1: adding end location for ruleset
    
``` javascript
// gonzales.css-to-ast.js: modified line 1308
if (needInfo)
{
    var _info = getInfo(startPos);
    if (tokens[pos-1]) {
        _info.end = getInfo(pos-1);
    }
    return (x.unshift(_info), x);
} else {
    return x;
}
```

 - Parser patch 2: increasing line number while parsing block comments
    
``` javascript
// gonzales.css-to-ast.js: modified after line 1671
var start = pos, c, cn;
for (pos = pos + 2; pos &lt; css.length; pos++) {
    c = css.charAt(pos);
    cn = css.charAt(pos + 1);
    if (c === '\n' || c === '\r') ln++;
    if (c === '*' && cn === '/') { ...
```

 - Parser patch 3: fixing interpolation after minus sign
    
``` javascript
// gonzales.css-to-ast.js: modified line 1983
if (!wasIdent && tokens[start].type !== TokenType.Asterisk && l === 0) return 0;
// the quickest version, 'l' means there was interpolation for identifier
```

 - Parser patch 4: fixing direct interpolation in selector
    
``` javascript
/* gonzales.css-to-ast.js */
// modified line 2263 
if (l = this.checkVariable(i) || this.checkIdent(i) || this.checkInterpolatedVariable(i)) i += l;

// modified line 2271
x.push(  this.checkVariable(pos) ? this.getVariable() 
       : this.checkInterpolatedVariable(pos) ? this.getInterpolatedVariable() 
       : this.getIdent());

// added in line 2331 
this.checkInterpolatedVariable(i) ||

// added in line 2343
else if (this.checkInterpolatedVariable(pos)) return this.getInterpolatedVariable();
```
