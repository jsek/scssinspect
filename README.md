![jsinspect](images/scssinspect-logo2shadow.png)

Detect copy-pasted and structurally similar code in your Scss stylesheets.

[![NPM info](https://nodei.co/npm/scssinspect.png?downloads=true)](https://nodei.co/npm/scssinspect.png?downloads=true)

[![dependencies](https://david-dm.org/jsek/scssinspect.png)](https://david-dm.org/jsek/scssinspect) 
[![licence](https://img.shields.io/npm/l/scssinspect.svg)](https://github.com/jsek/scssinspect/blob/master/LICENSE)
[![npm version](http://img.shields.io/npm/v/scssinspect.svg)](https://npmjs.org/package/scssinspect) 
[![downloads](https://img.shields.io/npm/dm/scssinspect.svg)](https://npmjs.org/package/scssinspect) 

* [Overview](#overview)
* [Installation](#installation)
* [Usage](#usage)
* [Integration](#integration)
* [Reporters](#reporters)
* [Known issues](#known-issues)
* [Performance](#performance)

## Overview

Example console output:

![screenshot](images/screenshot_0.1.4.png)

[Example HTML report](https://github.com/jsek/scssinspect/blob/master/images/html-reporter_0.2.1.png)

There are several types of AST nodes that can be anonymized:
- arguments (in functions and mixins calls)
- base64
- class
- interpolation
- number
- selector
- string
- url
- value
- variable

## Installation

Global installation (recommended):

```
npm i -g scssinspect
```

## Usage

```
Usage: scssinspect [options] <paths ...>

Duplicate code and structure detection for Scss.
Values matching is enabled by default. Example use:
scssinspect --ignore "merged.scss" ./path/to/src

Options:

  -h, --help                         output usage information
  -V, --version                      output the version number
  -t, --threshold <number>           minimal length of duplicated text (default: 50)
  -y, --type [char|token|property]   type of element to apply threshold (default: char)
  -a, --anonymize <types>            types of values to be anonymized (e.g. 'number')
  -l, --lang [css|less|sass|scss]    set language (default: scss)
      --syntax                       print syntax trees only
  -c, --config                       path to config file (default: .scssinspectrc)
  -r, --reporter <name>              specify the reporter to use (you can also set custom path to *.js file)
      --diff [css|lines|none]        type of diff to use (default: lines)
  -s, --skip                         skip files with parsing errors
  -C, --no-color                     disable colors
      --ignore <pattern>             ignore paths matching a regex
```

If a `.scssinspectrc` file is located in the project directory, its values will
be used in place of the defaults listed above. For example:

``` javascript
{
  "anonymize"     : "number|string"         // list of types delimited by '|'
  "threshold"     : 100,
  "type"          : "token",
  "lang"          : "scss",
  "diff"          : "css",
  "reporter"      : "html",
  "skip"          : false,
  "ignore"        : "bootstrap|legacy|lib"  // used as RegExp
}
```

## Integration

Example for Travis CI. Expected Entries in your `.travis.yml`:

``` yaml
before_script:
  - "npm install -g scssinspect"

script:
  - "scssinspect -t 30 ./path/to/src"
```

If you wish to log results as HTML and not break the build, use following example:

``` yaml
script:
  - "scssinspect -t 30 -r html ./path/to/src" > logs/scssinspect.html || true
```

## Reporters

### Default

Default reporter is well suited for CLI usage. 

```
Match - 2 instances
.\demo\a.scss:2,2
.\demo\b.scss:2,5

- .\demo\a.scss:2,2
+ .\demo\b.scss:2,5
+   div {
+       border: none;
+       color: red;
+   }
-   div { color: red; border: none; }

 1 match found across 2 files
```

### HTML

HTML reporter is well suited for CI usage. (Note that example below got indentation and formatting)

```html
<!doctype html>
<html>
    <head>
        <style><!-- styles --></style>
        <title><!-- current date --></title>
    </head>
    <body>
        <header>Match - 2 instances</header>
        <h3>demo\a.scss:3,3</h3>
        <h3>demo\b.scss:6,8</h3>
        <pre class='diff'>
            <code class='diff-files'>
            - .\demo\a.scss:3,3
            + .\demo\b.scss:6,8
            </code>
            <code class='line-added'>+   .b, .a {                </code>
            <code class='line-added'>+       color: #fff;        </code>
            <code class='line-added'>+   }                       </code>
            <code class='line-removed'>-   .a,.b { color: #fff; }</code>
        </pre>
        <footer>
            <span class='failure'>1 match found across 2 files</span>
        </footer>
    </body>
</html>
```

## Known issues

Scssinspect is dependent on Gonzales-PE parser which sometimes cannot parse scss 
libraries (like bootstrap). It is recommended to ignore these files or directories 
using `--ignore` flag or `ignore` property in .scssinspectrc. 

## Performance

Workstation:
- CPU: Intel Xeon 3.40GHz

Codebase (big):
- 200 files,  ~35 000 LOC

```
> powershell Measure-Command {scssinspect -t 30 -y property --diff none ./path/to/src}

TotalSeconds      : 4.22
```