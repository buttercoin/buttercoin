BD = require('bigdecimal')

Q = require("q")

operations = require('../lib/operations')

Buttercoin = require('../lib/buttercoin')

describe 'TradeEngine', ->
  it 'can initialize', (finish) ->
    butter = new Buttercoin()

    butter.engine.start {port: 3060}, () =>
      butter.engine.receive_message( [operations.ADD_DEPOSIT, {'account': 'Peter', 'password': 'foo', 'currency': 'USD', 'amount': 200.0}] )
      finish()
