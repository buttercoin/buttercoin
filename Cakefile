# Cakefile
# 
# Some parts drawn from https://github.com/twilson63/cakefile-template/blob/master/Cakefile

{spawn, exec} = require('child_process')
path = require('path')

try
  which = require('which').sync
catch err
  if process.platform.match(/^win/)?
    console.log 'WARNING: the which module is required for windows\ntry: npm install which'
  which = null

option '-R', '--reporter [REPORTER_NAME]', 'the mocha reporter to use'
option '-t', '--test [TEST_NAME]', 'set the test to run'
option '-D', '--debugger', 'use the debugger when running tests'

DEFAULT_REPORTER = "spec"

task "test", "run tests", (options) -> mocha(options)
#
# ## *launch*
#
# **given** string as a cmd
# **and** optional array and option flags
# **and** optional callback
# **then** spawn cmd with options
# **and** pipe to process stdout and stderr respectively
# **and** on child process exit emit callback if set and status is 0
launch = (cmd, args=[], options={}, callback) ->
  cmd = which(cmd) if which
  app = spawn cmd, args, options
  app.stdout.pipe(process.stdout)
  app.stderr.pipe(process.stderr)
  app.on 'exit', (status) -> callback?() if status is 0

mocha = (options) ->
  args = [
    "--compilers", "coffee:coffee-script"
    "--require", "coffee-script"
    "--require", "test/test_helper.coffee"
    "--colors"
    "--reporter", options.reporter || DEFAULT_REPORTER
    "--recursive"
  ]

  if options.debugger
    args.push "--debug-brk"
  args.push "test/#{options.test}.coffee" if options.test

  process.env.NODE_ENV='test'
  launch './node_modules/.bin/mocha', args, process.env, -> console.log "done"
  
