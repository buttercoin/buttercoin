stump = require('stump')

EngineWebsocketServer = require('./lib/ews/ew_server')
EngineWebsocketSlave = require('./lib/ews/ew_slave')
WebsocketInitiator = require('./lib/ews/ws_initiator')

InitiatorProtocol = require('./lib/ews/i_protocol')

options = {
  journalname: "testjournal"
}

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
.done()