#
# logger.coffee - Super simple console.logger
#
# If you want to do fancy logging you can redirect the STDOUT of this process using a UNIX pipe
#
# Usage
#
#  logger = require('./logger')
#
#  logger.info 'foo bar'
#  logger.warn 'baz foo', { 'a': 'b' }
#
#
colors = require('enkicolor')

levels = {
  info: 'green',
  data: 'grey',
  warn: 'yellow',
  error: 'red',
  event: 'grey',
  exec: 'grey',
  help: 'cyan'
}

# TODO - consider using something like https://github.com/quirkey/node-logger
levels_enabled = {}

module.exports.set_levels = (log_env) ->
  enable_all_levels = (x) -> Object.keys(levels).forEach (level) -> levels_enabled[level] = x
  if log_env is 'development'
    enable_all_levels true
  else if log_env is 'test'
    enable_all_levels false
  else if log_enf is 'production'
    levels_enabled = 
      info: false
      data: false
      warn: true
      error: true
      exec: false
      help: false

Object.keys(levels).forEach (level) ->
  module.exports[level] = () ->
    if levels_enabled[level]
      args = [].slice.call(arguments)
      console.log.apply this, [colors[levels[level]](level + ':')].concat(args)

    module.exports.set_levels(process.env.NODE_ENV || 'development')
