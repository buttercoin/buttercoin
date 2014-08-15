_ = require('underscore')
io = require('socket.io')
stump = require('stump')
Q = require('q')

Connection = require('./connection')

module.exports = class SocketIOListener
  @default_options:
    port: 80

  constructor: (@options) ->
    stump.stumpify(this, @constructor.name)
    @options = _.extend(SocketIOListener.default_options, @options)
    @do_not_know_how_to_make_protocol() unless @options.protocol_factory instanceof Function

  listen: =>
    @info 'LISTENING'
    return Q.fcall =>
      @io = io.listen(@options.port)
      @io.sockets.on 'connection', @connection_made

  close: =>
    @io.server.close()
    return Q.when(true)

  connection_made: (socket) =>
    conn = new Connection(this)
    conn.once 'open', (connection) =>
      @options.protocol_factory(connection)
    conn.handle_accept(socket)

  connect_error: (err) =>
    @error('connect error', err)

  do_not_know_how_to_make_protocol: (connection) =>
    @error 'DO NOT KNOW HOW TO MAKE PROTOCOL'
    connection.disconnect()

