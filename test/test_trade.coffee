Q = require("q")

Buttercoin = require('../lib/buttercoin')

describe 'TradeEngine', ->
  it 'can initialize', (finish) ->
    butter = new Buttercoin()

    butter.engine.start().then =>
      butter.api.add_deposit( {'account': 'Peter', 'currency': 'USD', 'amount': '200.0'} )
      .then (result) =>
        logger.info 'ADDED DEPOSIT. NEW BALANCE', result.toString()
        butter.api.add_deposit( {'account': 'Peter', 'currency': 'USD', 'amount': '200.0'} )
      .then (result) =>
        logger.info 'ADDED DEPOSIT. NEW BALANCE', result.toString()
        logger.info 'WAITING FOR FLUSH'
        butter.engine.flush().then =>
          finish()
    .done()
