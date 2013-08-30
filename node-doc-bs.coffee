# Licensed under the Apache License. See footer for details.

fs      = require "fs"
path    = require "path"

_           = require "underscore"
marked      = require "marked"
shelljs     = require "shelljs"
highlight   = require "highlight.js"

#-------------------------------------------------------------------------------
PROGRAM = (path.basename __filename).split(/\./g)[0]

#-------------------------------------------------------------------------------
exports.run = (iDir, oDir) ->
    help() if !iDir and !oDir
    
    checkDirs iDir, oDir

    log "reading source doc from: #{iDir}"
    log "generating doc into:     #{oDir}"

    files = getFiles iDir

    copyStaticFiles oDir

    files = getFiles iDir

    initMarked()

    html = []
    for {title, fileName, contents} in files
        log "processing: #{title}: #{fileName}"

        try
            contents = marked contents
        catch err
            error "error processing markdown in #{fileName}: #{err}"

        contents = fixContents title, fileName, contents

        html.push contents


    generateHeader()

    html.unshift ""
    html.push    ""
    out html.join "\n"

    generateTrailer()

    oFile = path.join oDir, "index.html"

    try
        fs.writeFile oFile, out.text
    catch err
        error "error generating output file '#{oFile}': #{err}"

    return

#-------------------------------------------------------------------------------
runHighlight = (code, lang) ->
    err    = undefined
    result = {}

    try 
        if lang
            result = highlight.highlight lang, code
        else
            result = highlight.highlightAuto code
    catch e
        throw Error "error running highlight: #{e}"

    return result.value

#-------------------------------------------------------------------------------
initMarked = ->
    marked.setOptions
        highlight:      runHighlight
        tables:         true
        breaks:         false
        pedantic:       false
        sanitize:       false
        smartLists:     true
        smartypants:    false

    return

#-------------------------------------------------------------------------------
getFiles = (iDir) ->
    iDir = path.join iDir, "doc", "api" 

    fileName = path.join iDir, "_toc.markdown"
    contents = readFile fileName

    lines = contents.split "\n"

    result = []

    for line in lines
        match = line.match /\*\s+\[(.*?)\]\((.*)\).*/
        continue if !match?

        title    = match[1]

        fileName = match[2]
        fileName = "#{baseFileName(fileName)}.markdown"
        fileName = path.join iDir, fileName

        contents = readFile fileName

        result.push {title, fileName, contents}

    return result

#-------------------------------------------------------------------------------
fixContents = (title, fileName, contents) ->
    id = "#{baseFileName fileName}.html"

    contents = "<div id='#{id}'></div>\n#{contents}"
    contents = "\n<!-- ======================================= -->\n#{contents}"
    contents = fixLinks contents

    return contents

#-------------------------------------------------------------------------------
fixLinks = (contents) ->
    result = []

    pattern = /([\s\S]*?)<a\s+(.*?)href="(.*?)"([\s\S]*)/
    while true
        match = contents.match pattern
        break if !match

        fixedHref = fixHref match[3]

        result.push match[1]
        result.push "<a "
        result.push match[2]
        result.push "href='"
        result.push fixedHref
        result.push "'"

        contents = match[4]

    result.push contents

    return result.join ""

#-------------------------------------------------------------------------------
fixHref = (href) ->
    return href if href.match /^#.*/
    return href if href.match /^(http:)|(https:)/

    match = href.match /.+?(#.*)/
    if match
        log "    fixRef: replacing #{href} with #{match[1]}"
        return match[1]

    log "    fixRef: replacing #{href} with ##{href}"
    return "##{href}"

#-------------------------------------------------------------------------------
readFile = (fileName) ->
    try
        return fs.readFileSync fileName, "utf8"
    catch err
        error "error reading file '#{fileName}': #{err}"
        
    return

#-------------------------------------------------------------------------------
copyStaticFiles = (oDir) ->

    iDir = path.join __dirname, "static"

    copyStaticFile iDir, "bootstrap-theme.min.css", oDir
    copyStaticFile iDir, "bootstrap.min.css",       oDir
    copyStaticFile iDir, "bootstrap.min.js",        oDir
    copyStaticFile iDir, "jquery.min.js",           oDir
    copyStaticFile iDir, "highlight-default.css",   oDir
    copyStaticFile iDir, "node-favicon.png",        oDir

#-------------------------------------------------------------------------------
baseFileName = (fileName) ->
    fileName = path.basename fileName
    fileName = fileName.split(".")[0]
    return fileName

#-------------------------------------------------------------------------------
copyStaticFile = (iDir, fileName, oDir) ->
    shelljs.cp path.join(iDir, fileName), oDir

#-------------------------------------------------------------------------------
checkDirs = (iDir, oDir) ->
    error "input directory '#{iDir}' does not exist" if !fs.existsSync iDir

    stats = fs.statSync iDir
    error "input directory '#{iDir}' is not a directory" if !stats.isDirectory()

    if !fs.existsSync oDir
        try
            fs.mkdirSync oDir
        catch err
            error "unable to create output directory '#{oDir}': #{err}"
        
    stats = fs.statSync oDir
    error "output directory '#{oDir}' is not a directory" if !stats.isDirectory()

#-------------------------------------------------------------------------------
generateHeader = ->

    out """
        <!doctype html>
        <html>
            <head>
                <title>node.js</title>
                <link rel="icon" href="node-favicon.png">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">    
                <link rel="stylesheet" href="bootstrap.min.css">
                <link rel="stylesheet" href="bootstrap-theme.min.css">
                <link rel="stylesheet" href="highlight-default.css">
            </head>
            <body>
                <div class="container">
                    <div class="row">
                        <div class="col-md-12">
    """

    return

#-------------------------------------------------------------------------------
generateTrailer = ->

    out """
                        </div>
                    </div>
                </div>
                <script src="jquery.min.js"></script>    
                <script src="bootstrap.min.js"></script>    
            </body>
        </html>
    """

    return

#-------------------------------------------------------------------------------
out = (text) ->
    out.text = "" if !out.text?
    out.text += text

    return

#-------------------------------------------------------------------------------
log = (message) ->
      console.error "#{PROGRAM}: #{message}"

#-------------------------------------------------------------------------------
error = (message) ->
      log message
      process.exit 1

#-------------------------------------------------------------------------------
help = ->
    console.error """
        #{PROGRAM} <node-src-dir> <out-dir>

        does the following:

        - read node doc source from <node-src-dir>
        - generate output doc in    <out-dir>
    """

    process.exit 1


#-------------------------------------------------------------------------------
exports.run process.argv[2], process.argv[3] if require.main is module

#-------------------------------------------------------------------------------
# Copyright 2013 Patrick Mueller
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#    http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#-------------------------------------------------------------------------------

