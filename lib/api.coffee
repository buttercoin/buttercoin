
module.exports = class API
  constructor: (@engine) ->

  add_deposit: ( args ) ->
    message = ['ADD_DEPOSIT', args ]

    @engine.receive_message(message)


  start: ( callback ) ->

    WebSocketServer = require('ws').Server
    wss = new WebSocketServer({port: 3001});

    wss.on 'connection', (ws) ->

      console.log 'api: incoming wss connection from', ws.upgradeReq.headers.host

      ws.on 'message', (message) ->
        console.log('api: server ' + process.pid + ' received message: %s', message);

      ws.send 'i am api server ' + process.pid

    callback null, wss