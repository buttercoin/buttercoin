helpers = require('enkihelpers')

Q = require('q')

EventEmitter = require('eemitterport').EventEmitter

module.exports = class Protocol extends EventEmitter
  constructor: (@engine_server, @connection, @pce) ->
    @connection.stumpify(@, @_get_obj_desc)

  _get_obj_desc: =>
    return 'Protocol'

  start: =>
    @info 'STARTING PROTOCOL'
    @connection.on('parsed_data', @handle_parsed_data)
    @connection.on('close', @handle_close)

  handle_close: =>
    @info 'PROTOCOL CLOSED'
    @engine_server.connection_lost(@connection)

  handle_parsed_data: (parsed_data) =>
    @info 'RECEIVED', parsed_data
    @pce.forward_operation( parsed_data ).then (result) =>
      @info 'PCE COMPLETED', result
      
      @engine_server.send_all( result )
    .done()