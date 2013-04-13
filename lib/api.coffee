
module.exports = class API
  constructor: (@engine) ->

  add_deposit: ( args ) ->
    message = ['ADD_DEPOSIT', args ]

    @engine.receive_message(message)


  start: ( options, callback ) ->

    # Basic currying for api.start method
    if typeof options is 'function'
      callback = options
      options = {}

    options = options || {}

    # Default api.start options
    options.port = options.port || 3001
    options.host = options.host || "0.0.0.0"
    WebSocketServer = require('ws').Server
    wss = new WebSocketServer({port: options.port, host: options.host});

    wss.on 'connection', (ws) ->

      console.log 'api: incoming wss connection from', ws.upgradeReq.headers.host

      ws.on 'message', (message) ->
        console.log 'api: server ' + process.pid + ' received message: %s', message

      ws.send 'i am api server ' + process.pid

    callback null, wss