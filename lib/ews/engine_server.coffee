
WebsocketListener = require('./websocket_listener')
EngineProtocol = require('./engine_protocol')

BE = require('buttercoin-engine')
Journal = BE.Journal
ProcessingChainEntrance = BE.ProcessingChainEntrance

if !module.parent
  
  engine = new BE.TradeEngine()
  journal = new BE.Journal('testjournal')
  replication = new BE.Replication()
  pce = new ProcessingChainEntrance( engine, journal, replication )
  pce.start().then =>
    listener = new WebsocketListener( { 
        wsconfig: {port: 6150}
        protocol_factory: (connection) =>
          protocol = new EngineProtocol(connection, pce)
          protocol.start()
      }
    )
    listener.listen()