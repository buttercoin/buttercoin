stump = require('stump')
ApiClient = require('./lib/ews/ew_api')

stump.stumpify(this, "[TEST]Client")

client = new ApiClient()
client.event_filters.ADD_DEPOSIT = (data) ->
  [
    {name: "ADD_DEPOSIT", data: data},
    {name: "ADD_DEPOSIT/account:#{data.operation.account}", data: data}
  ]

client.on "ADD_DEPOSIT", ->
  @warn "YAY GOT GENERIC DEPOSIT EVENT"

client.on "ADD_DEPOSIT/account:peter", ->
  @error "YAY GOT PETER DEPOSIT EVENT"

client.start().then =>
  client.deposit_funds('peter', 'USD', '5').then (result) =>
    @info "Deposited 5 USD. New balance: $#{result.retval}"
.then =>
  client.get_balances('peter').then (result) =>
    @info "Got balances:"
    for k, v of result.balances
      console.log "#{k}:", v
.done()

