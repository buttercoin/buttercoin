stump = require('stump')
ApiClient = require('./lib/ews/ew_api')

stump.stumpify(this, "[TEST]Client")

client = new ApiClient()
client.start().then =>
  client.deposit_funds('peter', 'USD', '5').then (result) =>
    @info "Deposited 5 USD. New balance: $#{result.retval}"
.then =>
  client.get_balances('peter').then (result) =>
    @info "Got balances:"
    for k, v of result.balances
      console.log "#{k}:", v
.done()

