chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Buttercoin = require('../lib/buttercoin')

describe 'TradeEngine', ->
  it 'can initialize', (finish) ->
    butter = new Buttercoin

    finish()