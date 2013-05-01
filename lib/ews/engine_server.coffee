stump = require('stump')

WebsocketListener = require('./websocket_listener')
EngineProtocol = require('./engine_protocol')

BE = require('buttercoin-engine')
Journal = BE.Journal
ProcessingChainEntrance = BE.ProcessingChainEntrance

class EngineServer
  constructor: ->
    stump.stumpify(@, @constructor.name)
    @connections = {}

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
    @connections[ connection.conncounter ] = connection
    protocol = new EngineProtocol(@, connection, @pce)
    protocol.start()

  send_all: ( obj ) =>
    @info 'SEND ALL'
    for x,y of @connections
      @info 'SPECIFIC ALL', x, y
      y.send_obj obj

if !module.parent  
  engine_server = new EngineServer()
  engine_server.start()