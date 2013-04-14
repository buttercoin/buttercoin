BD = require('bigdecimal')

Q = require("q")

chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Buttercoin = require('../lib/buttercoin')

describe 'TradeEngine', ->
  it 'can initialize', (finish) ->
    butter = new Buttercoin()

    butter.engine.start().then =>
      butter.api.add_deposit( {'account': 'Peter', 'currency': 'USD', 'amount': 200.0} )
      .then (result) =>
        console.log 'ADDED DEPOSIT. NEW BALANCE', result
        butter.api.add_deposit( {'account': 'Peter', 'currency': 'USD', 'amount': 200.0} )
      .then (result) =>
        console.log 'ADDED DEPOSIT. NEW BALANCE', result
        console.log 'WAITING FOR FLUSH'
        butter.engine.flush().then =>
          finish()
    .done()