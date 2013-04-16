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

Object.keys(levels).forEach (level) ->
  module.exports[level] = () ->
    args = [].slice.call(arguments)
    console.log.apply this, [colors[levels[level]](level + ':')].concat(args)
