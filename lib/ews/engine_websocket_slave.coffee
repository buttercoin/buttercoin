stump = require('stump')

WebsocketListener = require('./websocket_listener')
EngineProtocol = require('./engine_protocol')

EngineServer = require('../engine_server')

module.exports = class EngineWebsocketSlave extends EngineServer
  start: =>
    @pce.start().then =>
      @connect_upstream().then =>
        listener = new WebsocketListener( { 
            wsconfig: {port: 6150}
            protocol_factory: @new_connection
        } )
        listener.listen()

  connect_upstream: =>
    @info 'CONNECT UPSTREAM'

  new_connection: (connection) =>
    throw Error("Slave does not support Query Protocol yet!")