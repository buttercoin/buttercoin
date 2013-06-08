_ = require('underscore')
stump = require('stump')
Q = require('q')

Initiator = require('./ws_initiator')
InitiatorProtocol = require('./i_protocol')
EventEmitter = require('chained-emitter').EventEmitter

module.exports = class EngineWebsocketApi extends EventEmitter
  constructor: (options) ->
    @options = options || {
                query:
                  port: 6151
                  protocol: new InitiatorProtocol({})
                engine:
                  port: 6150
                  protocol: new InitiatorProtocol({})
              }

    @query = @options.query.protocol
    @engine = @options.engine.protocol
    @engine.on 'data', @handle_engine_data
    @event_filters = {}

    stump.stumpify(this, @constructor.name)

  start: =>
    Q.all([
      @connect_to(@options.engine)
      @connect_to(@options.query)
    ]).then =>
      @info "API READY"
    .fail (error) =>
      @error "COULDN'T CONNECT:", error

  connect_to: (options) =>
    ws_options =
      wsconfig: "ws://localhost:#{options.port}"
      protocol: options.protocol
    @info "CONNECTING TO", ws_options.wsconfig

    wsi = new Initiator( ws_options )
    wsi.connect()

  handle_engine_data: (data) =>
    filter = @event_filters[data?.operation?.kind]
    if filter
      for e in filter(data)
        @emit e.name, e.data
    else
      @emit 'data', data

  process_data_event: (data) =>
    @warn "Ignoring data event:", data

  deposit_funds: (account_id, currency, amount) =>
    @info "DEPOSITING #{amount} #{currency} to account #{account_id}"
    @engine.execute_operation
      kind: "ADD_DEPOSIT"
      account: account_id
      amount: amount
      currency: currency

  place_limit_order: (account_id, order) =>
    order.account = account_id
    order.kind = "CREATE_LIMIT_ORDER"
    @info "CREATING LIMIT ORDER #{JSON.stringify(order)}"
    @engine.execute_operation(order)

  get_balances: (account_id) =>
    @info "SENDING GET_BALANCES"
    @query.execute_operation
      kind: "GET_BALANCES"
      args: [account_id]

  get_spread: =>
  
