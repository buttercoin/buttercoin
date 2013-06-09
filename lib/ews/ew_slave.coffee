_ = require('underscore')
stump = require('stump')

BE = require('buttercoin-engine')
WebsocketListener = require('./ws_listener')
WebsocketInitiator = require('./ws_initiator')
EngineServer = require('../engine_server')
SlaveProtocol = require('./s_protocol')
QueryProtocol = require('./q_protocol')

module.exports = class EngineWebsocketSlave extends EngineServer
  @default_options =
    port: 6151
    upstream_port: 6150
    journalname: 'slave.testjournal'

  constructor: (options={}) ->
    options = _.extend(EngineWebsocketSlave.default_options, options)

    super(options)

  start: =>
    @connection_map = {}
    @closed = false

    @pce.start().then =>
      @connect_upstream()
    .then =>
      @options.protocol.fetch_snapshot()
    .then (snapshot) =>
      @info "SLAVE GOT SNAPSHOT"
      @pce.load_snapshot(snapshot.operation)
      @pce.dump_snapshot()
    #.then =>
      #replay buffered messages
    .then =>
      #initialize query interface
      @info 'SLAVE INITIALIZING DOWNSTREAM LISTENER'
      @query_interface = new BE.QueryInterface(@pce.engine.datastore)
      @initialize_downstream()
    .then =>
      @info 'SLAVE BOOT COMPLETE'

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

  initialize_downstream: =>
    ws_options =
      wsconfig: {port: @options.port}
      protocol_factory: @new_connection
     
    @listener = new WebsocketListener(ws_options)
    @listener.listen().then =>
      @info "QUERY SERVER LISTENING", ws_options.wsconfig

  new_connection: (connection) => # this is a protocol factory
    try
      @connection_map[connection.conncounter] = connection
      protocol = new QueryProtocol({
        connection_lost: @downstream_connection_lost
        send: (obj) => connection.send_obj(obj)
        query_provider: @query_interface
      })
      protocol.start(connection)
    catch e
      @error e
      console.log e.stack

  downstream_connection_lost: (connection) =>
    delete @connection_map[connection.conncounter]
