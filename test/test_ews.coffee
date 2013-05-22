Q = require('q')
stump = require('stump')

describe 'EWS', ->
  EngineWebsocketServer = require('../lib/ews/ew_server')
  EngineWebsocketSlave = require('../lib/ews/ew_slave')
  WebsocketInitiator = require('../lib/ews/ws_initiator')

  InitiatorProtocol = require('../lib/ews/i_protocol')

  options = {
    journalname: "testjournal"
  }

  beforeEach (finish) ->
    console.log 'STARTING'
    @engine_server = new EngineWebsocketServer()
    @engine_server.start().then =>
      finish()

  afterEach (finish) ->
    console.log 'CLEANING UP'
    @engine_server.stop().then =>
      finish()

  it 'should listen and be connectable', (finish) ->
    stump.info('started')

    wsi = new WebsocketInitiator( {
      wsconfig: 'ws://localhost:6150/'
      protocol: new InitiatorProtocol( {} )
    } )
    wsi.connect().then =>
      wsi.execute_operation(
        {
          kind: "ADD_DEPOSIT"
          account: "peter"
          amount: "5"
          currency: 'BTC'
        }
      ).then (retval) =>
        stump.info 'GOT RETVAL', retval
        finish()
    .done()

  xit 'should replicate', (finish) ->
    slave = new EngineWebsocketSlave( {
      journalname: 'slavejournal'
      wsconfig: 'ws://localhost:6150/'
    } )
    slave.connect_upstream().then =>
      stump.info 'CONNECTED UPSTREAM'
      wsi = new WebsocketInitiator( {
        wsconfig: 'ws://localhost:6150/'
        protocol: new InitiatorProtocol( {} )
      } )
      wsi.connect().then =>
        wsi.execute_operation(
          {
            kind: "ADD_DEPOSIT"
            account: "peter"
            amount: "5"
            currency: 'BTC'
          }
        ).then (retval) =>
          stump.info 'GOT RETVAL', retval
          finish()
