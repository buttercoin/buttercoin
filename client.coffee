stump = require('stump')
#ApiClient = require('./lib/ews/ew_api')

if process.argv[2] is 'client'
  crypto = require 'crypto'
  Adaptor = require './lib/api/mtgox/adaptor'
  test_api_key = "534ae7aea872406cbbae6ba2dd5ec515" # 16-bytes
  test_api_secret = "UW+9oWmPtmeNwOv8hVSY5QBmg51r74aSlyUe3x3r/UhaCsyNZDSFidNCfQfjQCIFfPLHjpPi7hT7PYQzghZcmw=="
  create_signed_message = (message) ->
    hmac = crypto.createHmac('sha512', new Buffer(test_api_secret, 'base64'))
    hmac.update(message)
    signature = hmac.digest('hex')

    size = Adaptor.payload_start + message.length
    buffer = new Buffer(size)
    cursor = 0

    buffer.write(test_api_key, cursor, 'hex')
    cursor += Adaptor.api_key_bytes
    buffer.write(signature, cursor, 'hex')
    cursor += Adaptor.signature_bytes
    buffer.write(message, cursor, 'utf8')

    request = buffer.toString('base64')

  stump.stumpify(this, "[TEST]Client")
  #WebSocket = require('ws')

  #socket = new WebSocket("http://localhost:3001")
  #socket.on 'open', =>
    #@error "sending"
    #socket.send(JSON.stringify
      #query: "TICKER"
      #currencies: ['USD', 'BTC'])

  #socket.on 'message', (message) =>
    #@error message
  
  io = require('socket.io-client')
  alice = io.connect('localhost', port: 3002)
  alice.on 'connecting', (transport_type) =>
    @info "CONNECTING ALICE:", transport_type

  alice.on 'connect_failed', =>
    @error "ALICE FAILED TO CONNECT"

  alice.on 'connect', =>
    @info "CONNECTED ALICE"
    #alice.send(JSON.stringify({op: 'auth', username: 'alice'}))
    msg = {
      op: 'call'
      id: "some-id"
      call: create_signed_message(JSON.stringify(call: 'BTCUSD/ticker'))
      context: 'mtgox.com'
    }

    alice.send(JSON.stringify msg)
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

