_ = require('underscore')
stump = require('stump')

#WebsocketListener = require('./ws_listener')
WebsocketInitiator = require('./ws_initiator')
#EngineProtocol = require('./e_protocol')
EngineServer = require('../engine_server')
SlaveProtocol = require('./s_protocol')

module.exports = class EngineWebsocketSlave extends EngineServer
  constructor: (options) ->
    options = _.extend (options or {}), {
      upstream_port: 6150
      journalname: 'slave.testjournal'
    }

    super(options)

  start: =>
    @pce.start().then =>
      @connect_upstream().then =>
        @options.protocol.fetch_snapshot().then (snapshot) =>
          @info "SLAVE GOT SNAPSHOT"
          @pce.load_snapshot(snapshot.operation)
          @pce.dump_snapshot()

  connect_upstream: =>
    @info 'CONNECT UPSTREAM'
    @options.protocol = @options.protocol or new SlaveProtocol({
      pce: @pce
      # connection_lost: @connection_lost
      # send_all: @send_all
    })
    wsi_options =
      wsconfig: "ws://localhost:#{@options.upstream_port}"
      protocol: @options.protocol
    
    wsi = new WebsocketInitiator( wsi_options )
    wsi.connect().then =>
      @info 'CONNECTED'

  #new_connection: (connection) =>
    #throw Error("Slave does not support Query Protocol yet!")
