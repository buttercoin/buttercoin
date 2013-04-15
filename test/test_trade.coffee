BD = require('bigdecimal')

Q = require("q")

Buttercoin = require('../lib/buttercoin')

describe 'TradeEngine', ->
  it 'can initialize', (finish) ->
    butter = new Buttercoin()

    butter.engine.start {port: 3060}, () =>
      finish()
