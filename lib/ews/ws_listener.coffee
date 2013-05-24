Q = require('q')
WebSocketServer = require('ws').Server
stump = require('stump')

Connection = require('./ws_connection')

module.exports = class WebsocketListener
  constructor: (@options) ->
    stump.stumpify(@, @constructor.name)
    @options.protocol_factory = @options.protocol_factory or @do_not_know_how_to_make_protocol

  listen: =>
    @info 'LISTENING'
    return Q.fcall =>
      @wss = new WebSocketServer( @options.wsconfig )
      @wss.on 'connection', @connection_made
      @wss.on 'error', @connect_error

  close: =>
    @wss.close()
    return Q.when(true)

  connection_made: (ws) =>
    conn = new Connection(@)
    conn.once 'open', (connection) =>
      @options.protocol_factory(connection)
    conn.socket_accepted(ws)

  connect_error: (err) =>
    @error('connect error', err)

  do_not_know_how_to_make_protocol: (connection) =>
    @error 'DO NOT KNOW HOW TO MAKE PROTOCOL'
    connection.disconnect()

if !module.parent
  listener = new WebsocketListener( { wsconfig: {port: 6150} } )
  listener.listen()
