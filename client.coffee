stump = require('stump')
#ApiClient = require('./lib/ews/ew_api')

if process.argv[2] is 'client'
  stump.stumpify(this, "[TEST]Client")
  io = require('socket.io-client')
  alice = io.connect('localhost', port: 3002)
  alice.on 'connecting', (transport_type) =>
    @info "CONNECTING ALICE:", transport_type

  alice.on 'connect_failed', =>
    @error "ALICE FAILED TO CONNECT"

  alice.on 'connect', =>
    @info "CONNECTED ALICE"
    alice.send(JSON.stringify({kind: 'AUTH', account_id: 'alice'}))
    #alice.send_obj
      #kind: 'AUTH'
      #account_id: 'alice'
    #.then =>
      #@warn "SENT AUTH"
    #.fail (error) =>
      #@error error
    #.done()

  alice.on 'message', (msg) =>
    @warn "Alice msg:", msg

  alice.on 'parsed_data', (data) =>
    @info "ALICE GOT:", data
else
  stump.stumpify(this, "[TEST]Server")
  ApiServer = require('./lib/api/server')
  fork = require('child_process').fork

  server = new ApiServer()
  server.start().then =>
    @info "Started, launching client process"
    fork('./client.coffee', ['client'])

#server = new ApiServer()
#server.start().then =>
#alice.connect('http://localhost:8888')
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

