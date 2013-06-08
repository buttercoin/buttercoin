stump = require('stump')
ApiClient = require('./lib/ews/ew_api')

stump.stumpify(this, "[TEST]Client")

client = new ApiClient()
client.event_filters.ADD_DEPOSIT = (data) ->
  [
    {name: "ADD_DEPOSIT", data: data},
    {name: "ADD_DEPOSIT?account=#{data.operation.account}", data: data}
  ]

client.event_filters.CREATE_LIMIT_ORDER = (data) ->
  [
    {name: "CREATE_LIMIT_ORDER", data: data},
    {name: "CREATE_LIMIT_ORDER?account=#{data.operation.account}", data: data}
  ]

peter = {}
stump.stumpify(peter, "[TEST]Peter")

client.on "ADD_DEPOSIT?account=peter", (data) ->
  peter.info "Added #{data.operation.amount} #{data.operation.currency}. New balance: #{data.retval}"

#client.on "CREATE_LIMIT_ORDER", (data) ->
  #peter.error "DATA:", data

client.on "CREATE_LIMIT_ORDER?account=peter", (data) ->
  peter.info "Created order #{data.retval[0].order.uuid}"
  client.get_balances('peter').then (result) =>
    peter.info "Got balances:"
    for k, v of result.balances
      peter.info "\t#{k}:", v

#client.on "pump", (data) ->
  #peter.info "PUMP", data

client.start().then =>
  client.get_balances('peter').then (result) =>
    peter.info "Got balances:"
    for k, v of result.balances
      peter.info "\t#{k}:", v
.then =>
  client.deposit_funds('peter', 'USD', '100')
.then =>
  client.place_limit_order 'peter',
    offered_currency: 'USD'
    offered_amount: '10'
    received_currency: 'BTC'
    received_amount: '1'
.done()

