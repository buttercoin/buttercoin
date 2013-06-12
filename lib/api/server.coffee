_ = require('underscore')
EngineApi = require('../ews/ew_api')
WebsocketListener = require('../ews/ws_listener')
SocketIOListener = require('../socket.io/listener')
ApiProtocol = require('./api_protocol')
operations = require('../operations')
stump = require('stump')

module.exports = class ApiServer
  @default_options:
    port: 3001
    socketio: {port: 3002 }
    engine: { port: 6150 }
    query: { port: 6151 }

  constructor: (options={}) ->
    stump.stumpify(this, @constructor.name)
    @options = _.extend(ApiServer.default_options, options)
    @api = new EngineApi(options)
  
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
      @socketio_listener = new SocketIOListener
        port: @options.socketio.port
        protocol_factory: @new_connection
      @socketio_listener.listen()
      @info "API socket.io interface listening on port: #{@options.socketio.port}"
    .then =>
      @info "API service started"

  new_connection: (connection) =>
    try
      @connection_map[ connection.conncounter ] = connection
      protocol = new ApiProtocol({event_source: @api}, this)
      protocol.start(connection)
    catch e
      @error e
      console.log e.stack
