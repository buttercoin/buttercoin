BD = require('bigdecimal')

chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Buttercoin = require('../lib/buttercoin')

describe 'TradeEngine', ->
  it 'can initialize', (finish) ->
    butter = new Buttercoin()

    butter.api.add_deposit {'account': 'Peter', 'currency': 'USD', 'amount': 200.0, 'callback': finish}
