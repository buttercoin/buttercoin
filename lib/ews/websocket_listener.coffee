Q = require('q')
WebSocketServer = require('ws').Server
stump = require('stump')

Connection = require('./websocket_connection')
# Protocol = require('./protocol')

module.exports = class WebsocketListener
  constructor: (@options) ->
    stump.stumpify(@, @constructor.name)

  listen: =>
    @info 'LISTENING'
    return Q.fcall =>
      @wss = new WebSocketServer( @options.wsconfig )
      @wss.on 'connection', @connection_made
      @wss.on 'error', @connect_error

  close: =>
    Q.fcall =>
      @wss.close()

  connection_made: (ws) =>
    conn = new Connection(@)
    conn.once('open', @establish_protocol)
    conn.socket_accepted(ws)

  connect_error: (err) =>
    @error('connect error', err)

  establish_protocol: (connection) =>
    @info 'Making protocol'

if !module.parent
  listener = new WebsocketListener( { wsconfig: {port: 6150} } )
  listener.listen()