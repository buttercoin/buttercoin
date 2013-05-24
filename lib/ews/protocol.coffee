helpers = require('enkihelpers')

Q = require('q')
stump = require('stump')

# EventEmitter = require('eemitterport').EventEmitter
EventEmitter = require('chained-emitter').EventEmitter

module.exports = class Protocol extends EventEmitter
  constructor: (@options, @parent) ->
    if not @parent
      stump.stumpify(@, @constructor.name)
    else
      @parent.stumpify(@, @constructor.name)

    @protocol_ready = Q.defer()

  _get_obj_desc: =>
    return @constructor.name

  start: (connection) => # Connection has been initialized but not yet connected.
    @connection = connection
    @info 'STARTING PROTOCOL'
    @connection.on('parsed_data', @handle_parsed_data)
    @connection.once('close', @handle_close)
    @connection.once('open', @handle_open)
    return @protocol_ready.promise

  handle_close: =>
    # Protocol closed - tell the server to clean up.
    @info 'PROTOCOL CLOSED'
    if @options.connection_lost
      @options.connection_lost(@connection)
    else
      @warn "Connection Lost Not Implemented"
    return true

  handle_parsed_data: (parsed_data) =>
    throw Error("parsed_data Not Implemented")

  handle_open: (connection) =>
    throw Error("handle_open Not Implemented")
