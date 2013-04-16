BD = require('bigdecimal')

Q = require("q")

operations = require('../lib/operations')

ProcessingChainEntrance = require('../lib/processingchainentrance')
TradeEngine = require('../lib/trade_engine')
Journal = require('../lib/journal')

describe 'TradeEngine', ->
  beforeEach =>
    TestHelper.clean_state_sync

  afterEach =>
    TestHelper.clean_state_sync

  it 'can perform deposit', (done) ->
    deferred = Q.defer()
    deferred.resolve(undefined)

    replicationStub =
      start: sinon.stub()
      send: sinon.stub().returns(deferred.promise)

    pce = new ProcessingChainEntrance(new TradeEngine(),
                                      new Journal(),
                                      replicationStub)
    pce.start().then ->
      pce.forward_message({
        kind: operations.ADD_DEPOSIT
        operatation:
          account: 'Peter'
          password: 'foo'
          currency: 'USD'
          amount: 200.0
      })
      done()
