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
    messageJson = JSON.stringify(message)
    @journal.expects('record').once().withArgs(messageJson).returns(deferred.promise)
    @replication.expects('send').once().withArgs(messageJson).returns(deferred.promise)
    @engine.expects('execute_operation').once().withArgs({message: messageJson, uid: undefined})

    @pce.forward_operation(message).then(-> done()).done()
