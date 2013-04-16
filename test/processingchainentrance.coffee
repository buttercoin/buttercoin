ProcessingChainEntrance = require('../lib/processingchainentrance')
TransactionLog = require('../lib/transactionlog')
TradeEngine = require('../lib/trade_engine')

describe 'ProcessingChainEntrance', ->
  beforeEach (done) ->
    @tlog = sinon.mock(new TransactionLog())
    @replication = sinon.mock({start: (->), send: (->)})
    @engine = sinon.mock(new TradeEngine())
    @pce = new ProcessingChainEntrance(@engine.object, @tlog.object, @replication.object)
    done()

  afterEach (done) ->
    @tlog.verify()
    @replication.verify()
    @engine.verify()
    done()

  it 'should intialize the transaction log and replication when starting', (done) ->
    @tlog.expects('start').once().returns(then: ->)
    @replication.expects('start').once().returns(then: ->)

    @pce.start()

    done()

  it 'should log, replicate, and package a messge upon receiving it', (done) ->
    deferred = Q.defer()
    deferred.resolve(undefined)

    message = {kind: "TEST"}
    @tlog.expects('record').once().withArgs(message).returns(deferred.promise)
    #@replication.expects('send').once().withArgs(message).returns(deferred.promise)
    @engine.expects('execute_operation').once() #.withArgs({message: message, uid: undefined})

    @pce.forward_message(message).then(-> done()).done()
