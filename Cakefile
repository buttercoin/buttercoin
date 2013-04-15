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

REPORTER = "spec"

task "test", "run tests", -> mocha()
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

mocha = ->
  args = [
    "--compilers", "coffee:coffee-script"
    "--require", "coffee-script"
    "--require", "test/test_helper.coffee"
    "--colors"
    "--reporter", REPORTER
    "--recursive"
  ]

  process.env.NODE_ENV='test'
  launch './node_modules/.bin/mocha', args, process.env, -> console.log "done"
  
