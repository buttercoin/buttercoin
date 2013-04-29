helpers = require('enkihelpers')

Q = require('q')

EventEmitter = require('eemitterport').EventEmitter

module.exports = class Protocol extends EventEmitter
  constructor: (@connection, @pce) ->
    @connection.stumpify(@, @_get_obj_desc)

  start: =>
    @info 'STARTING PROTOCOL'
    @connection.on('parsed_data', @handle_parsed_data)

  handle_parsed_data: (parsed_data) =>
    @info 'RECEIVED', parsed_data
    @pce.forward_operation( parsed_data )
