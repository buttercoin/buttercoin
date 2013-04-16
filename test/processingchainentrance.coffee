ProcessingChainEntrance = require('../lib/processingchainentrance')
Journal = require('../lib/journal')

describe 'ProcessingChainEntrance', ->
  beforeEach (done) ->
    @journal = sinon.mock(new Journal())
    @replication = sinon.mock({start: (->), send: (->)})
    @pce = new ProcessingChainEntrance(null, @journal.object, @replication.object)
    done()

  afterEach (done) ->
    @journal.verify()
    @replication.verify()
    done()

  it 'should intialize the transaction log and replication when starting', (done) ->
    @journal.expects('start').once().returns(then: ->)
    @replication.expects('start').once().returns(then: ->)

    @pce.start()

    done()

  it 'should log, replicate, and package a messge upon receiving it', (done) ->
    message = {}
    @journal.expects('record').once().withArgs(message).returns(then: ->)
    @replication.expects('send').once().withArgs(message).returns(then: ->)

    @pce.forward_message(message)

    done()
