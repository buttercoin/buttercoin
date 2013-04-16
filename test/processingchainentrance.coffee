ProcessingChainEntrance = require('../lib/processingchainentrance')
TransactionLog = require('../lib/transactionlog')

describe 'ProcessingChainEntrance', ->
  beforeEach (done) ->
    @tlog = sinon.mock(new TransactionLog())
    @replication = sinon.mock({start: (->), send: (->)})
    @pce = new ProcessingChainEntrance(null, @tlog.object, @replication.object)
    done()

  afterEach (done) ->
    @tlog.verify()
    @replication.verify()
    done()

  it 'should intialize the transaction log and replication when starting', (done) ->
    @tlog.expects('start').once().returns(then: ->)
    @replication.expects('start').once().returns(then: ->)

    @pce.start()

    done()


  it 'should log, replicate, and package a messge upon receiving it', (done) ->
    message = {}
    @tlog.expects('record').once().withArgs(message).returns(then: ->)
    @replication.expects('send').once().withArgs(message).returns(then: ->)

    @pce.forward_message(message)

    done()
