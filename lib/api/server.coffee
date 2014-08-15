_ = require('underscore')
EngineWebsocketApi = require('../ews/ew_api')
WebsocketListener = require('../ews/ws_listener')
SocketIOListener = require('../socket.io/listener')
ApiProtocol = require('./api_protocol')
MtGoxProtocol = require('./mtgox/protocol')
operations = require('../operations')
stump = require('stump')

module.exports = class ApiServer
  @default_options:
    port: 3001
    goxlike: { port: 3002 }
    engine: { port: 6150 }
    query: { port: 6151 }
    auth: {
      port: 6152
      path: "/authorize"
    }

  constructor: (options={}) ->
    stump.stumpify(this, @constructor.name)
    @options = _.extend(ApiServer.default_options, options)
    @api = new EngineWebsocketApi(options)
  
    # Setup API event emitter filters.
    # Create account level and all-up result events.
    for op in [operations.ADD_DEPOSIT,
               operations.WITHDRAW_FUNDS,
               operations.CREATE_LIMIT_ORDER,
               operations.CANCEL_ORDER]
      @api.event_filters[op] = (data) ->
        [name: "#{op}?account=#{data.operation.account}", data: data]

    for op in [operations.CREATE_LIMIT_ORDER,
               operations.CANCEL_ORDER]
      filter = @api.event_filters[op] || -> []
      @api.event_filters[op] = (data) ->
        filter(data).push {name: op, data: data}

  start: =>
    @connection_map = {}
    @api.start().then =>
      @listener = new WebsocketListener
        wsconfig: {port: @options.port}
        protocol_factory: @new_connection
      @listener.listen()
      @info "API websocket interface listening on port: #{@options.port}"
    .then =>
      @goxlike_listener = new SocketIOListener
        port: @options.goxlike.port
        protocol_factory: @new_gox_connection
      @goxlike_listener.listen()
      @info "API gox-like interface listening on port: #{@options.goxlike.port}"
    .then =>
      @info "API service started"

  init_protocol_with_connection: (protocol, connection) =>
    @connection_map[ connection.conncounter ] = connection
    protocol.start(connection)
    protocol.handle_open(connection)

  new_connection: (connection) =>
    protocol = new ApiProtocol({event_source: @api}, this)
    @init_protocol_with_connection(protocol, connection)

  new_gox_connection: (connection) =>
    protocol = new MtGoxProtocol(
      {api: {event_source: @api}}
      this)
    @init_protocol_with_connection(protocol, connection)
