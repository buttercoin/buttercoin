_ = require('underscore')
stump = require('stump')
Q = require('q')

Initiator = require('./ws_initiator')
InitiatorProtocol = require('./i_protocol')
EventEmitter = require('chained-emitter').EventEmitter
BC = require('buttercoin-engine')

module.exports = class EngineWebsocketApi extends EventEmitter
  @default_options:
    engine: { port: 6150 }
    query: { port: 6151 }

  constructor: (options={}) ->
    @options = _.extend(EngineWebsocketApi.default_options, options)
    @options.query.protocol ||= new InitiatorProtocol({})
    @options.engine.protocol ||= new InitiatorProtocol({})

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

  #deposit_funds: (account_id, currency, amount) =>
    #@info "DEPOSITING #{amount} #{currency} to account #{account_id}"
    #@engine.execute_operation
      #kind: BC.operations.ADD_DEPOSIT
      #account: account_id
      #amount: amount
      #currency: currency

  #withdraw_funds: (account_id, currency, amount) =>
    #@info "WITHDRAWING #{amount} #{currency} from account #{account_id}"
    #@engine.execute_operation
      #kind: BC.operations.WITHDRAW_FUNDS
      #account: account_id
      #amount: amount
      #currency: currency

  #place_limit_order: (account_id, order) =>
    #order.account = account_id
    #order.kind = BC.operations.CREATE_LIMIT_ORDER
    #@info "CREATING LIMIT ORDER #{JSON.stringify(order)}"
    #@engine.execute_operation(order)

  #get_balances: (account_id) =>
    #@info "SENDING GET_BALANCES"
    #@query.execute_operation
      #kind: BC.operations.GET_BALANCES
      #args: [account_id]

  #get_spread: =>
  
