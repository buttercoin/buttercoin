stump = require('stump')

WebsocketListener = require('./websocket_listener')
EngineProtocol = require('./engine_protocol')

BE = require('buttercoin-engine')
Journal = BE.Journal
ProcessingChainEntrance = BE.ProcessingChainEntrance

class EngineServer
  constructor: ->
    stump.stumpify(@, @constructor.name)
    @connection_map = {}

    @engine = new BE.TradeEngine()
    @journal = new BE.Journal('testjournal')
    @replication = new BE.Replication()
    @pce = new ProcessingChainEntrance( @engine, @journal, @replication )

  start: =>
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
    for x,y of @connection_map
      @info 'SPECIFIC ALL', x, y
      y.send_obj obj

if !module.parent  
  engine_server = new EngineServer()
  engine_server.start()