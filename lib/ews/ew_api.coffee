_ = require('underscore')
stump = require('stump')
Q = require('q')

Initiator = require('./ws_initiator')
InitiatorProtocol = require('./i_protocol')

module.exports = class EngineWebsocketApi
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

  deposit_funds: (account_id, currency, amount) =>
    @info "DEPOSITING #{amount} #{currency} to account #{account_id}"
    @engine.execute_operation
      kind: "ADD_DEPOSIT"
      account: account_id
      amount: amount
      currency: currency

  get_balances: (account_id) =>
    @info "SENDING GET_BALANCES"
    @query.execute_operation
      kind: "GET_BALANCES"
      args: [account_id]

  get_spread: =>
  
