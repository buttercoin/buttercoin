BD = require('bigdecimal')

Q = require("q")

operations = require('../lib/operations')

ProcessingChainEntrance = require('../lib/processingchainentrance')
TradeEngine = require('../lib/trade_engine')
TransactionLog = require('../lib/transactionlog')
TestHelper = require('./test_helper')

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
                                      new TransactionLog(),
                                      replicationStub)
    pce.start().then ->
      console.log "STARTED!!!"
      pce.forward_message({operation: "TEST"})
      done()
    #butter.api.receive_message( [operations.ADD_DEPOSIT, {'account': 'Peter', 'password': 'foo', 'currency': 'USD', 'amount': 200.0}] )
    #  finish()
