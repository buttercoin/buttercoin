logger = require './logger'
Q = require("q")

operations = require("./operations")

module.exports = class API
  constructor: (@engine) ->

  add_deposit: ( args ) ->
    deferred = Q.defer()
    args.callback = deferred.resolve

    message = [operations.ADD_DEPOSIT, args ]

    @engine.receive_message(message)
    return deferred.promise

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

    logger.info "Buttercoin api server started on ws://" + wss.options.host + ":" + wss.options.port
    wss.on 'connection', (ws) ->

      logger.info 'api server receiving incoming wss connection from', ws.upgradeReq.headers.host

      ws.on 'message', (message) ->
        logger.info 'api server ' + process.pid + ' received message: ' + message

      ws.send 'i am api server ' + process.pid

    callback null, wss
