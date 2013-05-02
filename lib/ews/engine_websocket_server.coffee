stump = require('stump')

WebsocketListener = require('./websocket_listener')
EngineProtocol = require('./engine_protocol')

EngineServer = require('../engine_server')

module.exports = class EngineWebsocketServer extends EngineServer
  start: =>
    @connection_map = {}

    @pce.start().then =>
      listener = new WebsocketListener( { 
          wsconfig: {port: 6150}
          protocol_factory: @new_connection
      } )
      listener.listen()

  new_connection: (connection) =>
    @connection_map[ connection.conncounter ] = connection
    protocol = new EngineProtocol(@, connection, @pce)
    protocol.start()

  connection_lost: (connection) =>
    delete @connection_map[connection.conncounter]

  send_all: ( obj ) =>
    @info 'SEND ALL'
    for x, y of @connection_map
      y.send_obj obj
