ProcessingChainEntrance = require('../lib/processingchainentrance')
TradeEngine = require('../lib/trade_engine')
Journal = require('../lib/journal')
EngineWebAdapter = require('../lib/engine_websocket_adapter.coffee')
EngineClient = require('../lib/engine_client')

assert = chai.assert

kTestFilename = 'test.log'

describe 'EngineWebsocketAdapter', ->
  beforeEach (done) ->
    @journal = sinon.mock(new Journal(kTestFilename))
    @replication = sinon.mock({start: (->), send: (->)})
    @engine = sinon.mock(new TradeEngine())
    @pce = new ProcessingChainEntrance(@engine.object, @journal.object, @replication.object)
    @wsa = new EngineWebAdapter(@pce)
    done()

  afterEach (done) ->
    @journal.verify()
    @replication.verify()
    @engine.verify()
    done()

  it 'should process a message correctly', (done) ->
    mockConn = {
      send: (result) ->
        console.log 'RESULT: ', result
        assert result is 'Success'

      close: ->
        done()
    }

    @wsa.process_message(mockConn, '{ "kind": "ADD_DEPOSIT", "account": "acct", "currency": "USD", "amount": 123 }')

  it 'should process an add_deposit request', (done) ->
    console.log 'attempting to start wsa'
    @wsa.start({ })

    client = new EngineClient
    client.set_account_info 'qubey'
    client.add_deposit('USD', 100).then =>
      done()

