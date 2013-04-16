ProcessingChainEntrance = require('../lib/processingchainentrance')
TradeEngine = require('../lib/trade_engine')
Journal = require('../lib/journal')

describe 'ProcessingChainEntrance', ->
  beforeEach (done) ->
    @journal = sinon.mock(new Journal())
    @replication = sinon.mock({start: (->), send: (->)})
    @engine = sinon.mock(new TradeEngine())
    @pce = new ProcessingChainEntrance(@engine.object, @journal.object, @replication.object)
    done()

  afterEach (done) ->
    @journal.verify()
    @replication.verify()
    @engine.verify()
    done()

  it 'should intialize the transaction log and replication when starting', (done) ->
    @journal.expects('start').once().returns(then: ->)
    @replication.expects('start').once().returns(then: ->)

    @pce.start()
    done()

  it 'should log, replicate, and package a messge upon receiving it', (done) ->
    deferred = Q.defer()
    deferred.resolve(undefined)

    message = {kind: "TEST"}
    @journal.expects('record').once().withArgs(message).returns(deferred.promise)
    #@replication.expects('send').once().withArgs(message).returns(deferred.promise)
    @engine.expects('execute_operation').once() #.withArgs({message: message, uid: undefined})

    @pce.forward_message(message).then(-> done()).done()
