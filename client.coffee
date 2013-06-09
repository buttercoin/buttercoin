stump = require('stump')
ApiClient = require('./lib/ews/ew_api')
ApiServer = require('./lib/api/server')
Connection = require('./lib/ews/ws_connection')

stump.stumpify(this, "[TEST]Client")

alice = new Connection(stump)
alice.on 'open', =>
  @warn "CONNECTED ALICE"
  alice.send_obj
    kind: 'AUTH'
    account_id: 'alice'
  .then =>
    @warn "SENT AUTH"
  .fail (error) =>
    @error error
  .done()

alice.on 'parsed_data', (data) =>
  @info "ALICE GOT:", data

#server = new ApiServer()
#server.start().then =>
alice.connect('ws://localhost:3001')
  #.then =>
#.done()

#client = new ApiClient()
#client.event_filters.ADD_DEPOSIT = (data) ->
  #[
    #{name: "ADD_DEPOSIT?account=#{data.operation.account}", data: data}
  #]

#client.event_filters.WITHDRAW_FUNDS = (data) ->
  #[
    #{name: "WITHDRAW_FUNDS?account=#{data.operation.account}", data: data}
  #]

#client.event_filters.CREATE_LIMIT_ORDER = (data) ->
  #[
    #{name: "CREATE_LIMIT_ORDER", data: data},
    #{name: "CREATE_LIMIT_ORDER?account=#{data.operation.account}", data: data}
  #]

#peter = {}
#stump.stumpify(peter, "[TEST]Peter")
#sally = {}
#stump.stumpify(sally, "[TEST]Sally")

#initUser = (u) ->
  #@[u] = {}
  #stump.stumpify(@[u], "[TEST]#{u}")
  #client.on "ADD_DEPOSIT?account=#{u}", (data) =>
    #@[u].info "Added #{data.operation.amount} #{data.operation.currency}. New balance: #{data.retval}"

  #client.on "WITHDRAW_FUNDS?account=#{u}", (data) =>
    #@[u].info "Withdrew #{data.operation.amount} #{data.operation.currency}. New balance: #{data.retval}"

  #client.on "CREATE_LIMIT_ORDER?account=#{u}", (data) =>
    #@[u].info "Created order #{data.retval[0].order.uuid}"
    #client.get_balances(u).then (result) =>
      #@[u].info "Got balances:"
      #for k, v of result.balances
        #@[u].info "\t#{k}:", v

#initUser(u) for u in ["peter", "sally"]

#client.start().then =>
  #client.deposit_funds('peter', 'USD', '100')
  #client.deposit_funds('sally', 'BTC', '20')
#.then =>
  #client.place_limit_order 'peter',
    #offered_currency: 'USD'
    #offered_amount: '10'
    #received_currency: 'BTC'
    #received_amount: '1'
#.then =>
  #client.place_limit_order 'sally',
    #offered_currency: 'BTC'
    #offered_amount: '1'
    #received_currency: 'USD'
    #received_amount: '10'
#.then =>
  #client.withdraw_funds('peter', 'BTC', '1')
#.then =>
  #client.withdraw_funds('sally', 'USD', '10')
#.done()

