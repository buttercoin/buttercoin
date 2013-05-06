helpers = require('enkihelpers')

Q = require('q')

EventEmitter = require('eemitterport').EventEmitter

module.exports = class Protocol extends EventEmitter
  constructor: (@engine_server, @connection, @pce) ->
    @connection.stumpify(@, @_get_obj_desc)

  _get_obj_desc: =>
    return @constructor.name

  start: =>
    @info 'STARTING PROTOCOL'
    @connection.on('parsed_data', @handle_parsed_data)
    @connection.on('close', @handle_close)

  handle_close: =>
    throw Error("Close Not Implemented")

  handle_parsed_data: (parsed_data) =>
    throw Error("Parsed_data Not Implemented")