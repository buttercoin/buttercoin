ProcessingChainEntrance = require('../lib/processingchainentrance')
TradeEngine = require('../lib/trade_engine')
Journal = require('../lib/journal')

kTestFilename = 'test.log'

describe 'ProcessingChainEntrance', ->
  beforeEach (done) ->
    @journal = sinon.mock(new Journal(kTestFilename))
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

  it 'should log, replicate, and execute a messge upon receiving it', (done) ->
    deferred = Q.defer()
    deferred.resolve(undefined)

    operation = {kind: "TEST"}
    messageJson = JSON.stringify(operation)
    @journal.expects('record').once().withArgs(messageJson).returns(deferred.promise)
    @replication.expects('send').once().withArgs(messageJson).returns(deferred.promise)
    @engine.expects('execute_operation').once().withArgs(operation).returns("success")

    onComplete = (result) ->
      result.should.equal "success"
      done()

    @pce.forward_operation(operation).then(onComplete).done()

  it 'should report an error when the exectution fails', (done) ->
    deferred = Q.defer()
    deferred.resolve(undefined)

    @journal.expects('record').once().returns(deferred.promise)
    @replication.expects('send').once().returns(deferred.promise)
    @engine.expects('execute_operation').once().throws("failure")

    onError = (error) ->
      error.name.should.equal "failure"
      done()

    @pce.forward_operation(null).fail(onError).done()

