BD = require('bigdecimal')
Q = require("q")

logger = require('../lib/logger')

operations = require('../lib/operations')
ProcessingChainEntrance = BE.ProcessingChainEntrance
TradeEngine = BE.TradeEngine
Journal = BE.Journal

kTestFilename = 'test.log'


describe 'TradeEngine', ->
  beforeEach =>
    TestHelper.clean_state_sync()

  afterEach =>
    TestHelper.clean_state_sync()

  it 'can perform deposit', (finish) ->
    deferred = Q.defer()
    deferred.resolve(undefined)

    replicationStub =
      start: sinon.stub()
      send: sinon.stub().returns(deferred.promise)

    pce = new ProcessingChainEntrance(new TradeEngine(),
                                      new Journal(kTestFilename),
                                      replicationStub)
    pce.start().then ->
      logger.info('Started PCE')
      pce.forward_operation
        kind: operations.ADD_DEPOSIT
        account: 'Peter'
        currency: 'USD'
        amount: 200.0
      .then =>
        finish()
    .done()
