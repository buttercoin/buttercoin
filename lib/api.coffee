logger = require './logger'
Q = require("q")

operations = require("./operations")


module.exports = class API
  constructor: (@engine) ->

    # stores incoming front-end sockets
    @frontEndSockets = {}

    # front-end server socket id
    @fid = 0

  send_message: ( message ) ->

    #
    # TODO: Send an API request to the trading engine
    #
    # logger.info 'sending message to trading engine', message

    # Sends message to engine with a continuation
    # @engine.recieve_message message ->
    #  this.frontEndSockets[message.front.fid].send(JSON.stringify(message))

    # Echo back websocket message ( for now )
    this.frontEndSockets[message.front.fid].send(JSON.stringify(message))

  add_deposit: ( args ) ->
    deferred = Q.defer()
    args.callback = deferred.resolve

    message = [operations.ADD_DEPOSIT, args ]

    @engine.receive_message(message)
    return deferred.promise

  start: ( options, callback ) ->

    api = this

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

    wss.on 'error', (err) ->
      throw err

    wss.on 'connection', (socket) ->

      socket.fid = api.fid
      api.frontEndSockets[api.fid] = socket
      api.fid++

      logger.info 'api server receiving incoming wss connection from', socket.upgradeReq.headers.host

      socket.on 'error', (err) ->
        throw err

      socket.on 'message', (message) ->
        logger.info 'api server ' + process.pid + ' received message: ' + message

        try
          message = JSON.parse message
        catch err
          message = {}

        # Create a JSON representation of the originating message
        message.front = {
          host: socket.upgradeReq.headers.host,
          fid: socket.fid
        }

        api.send_message(message)

      socket.send 'i am api server ' + process.pid

    callback null, wss