logger = require './logger'
Q = require("q")

operations = require("./operations")


module.exports = class API
  constructor: (@engine) ->

    # websocket client to the trading engine
    @engineClient = null

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
    if this.engineClient
      this.engineClient.send(JSON.stringify(message))

    # Echo back websocket message ( for now )
    # this.frontEndSockets[message.front.fid].send(JSON.stringify(message))

  add_deposit: ( args ) ->

    api = this
    deferred = Q.defer()
    args.callback = deferred.resolve

    message = [operations.ADD_DEPOSIT, args ]

    api.send_message(message)
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
    options.engineEndpoint = options.engineEndpoint || "ws://0.0.0.0:3003/"
    WebSocketServer = require('ws').Server
    WebSocketClient = require('ws')

    wss = new WebSocketServer({port: options.port, host: options.host});

    logger.info "Buttercoin api server started on ws://" + wss.options.host + ":" + wss.options.port

    wss.on 'error', (err) ->
      throw err

    wss.on 'connection', (socket) ->

      socket.fid = api.fid
      api.frontEndSockets[api.fid] = socket

      logger.warn 'api server receiving incoming wss connection'

      api.fid++

      socket.on 'error', (err) ->
        throw err

      socket.on 'message', (message) ->
        logger.data 'api server ' + process.pid + ' received message from front: ' + message

        valid = false
        try
          message = JSON.parse message
          valid = true
        catch err
          valid = false

        # TODO: Additional validation before submitting message to trading engine

        if valid

          # Create a JSON representation of the originating message
          message[1].front = {
            host: socket.upgradeReq.headers.host,
            fid: socket.fid
          }

          api.send_message(message)

      socket.send 'i am api server ' + process.pid

    #
    # Establish outgoing connection to VLAN websocket engine server
    #
    logger.info 'api attempting to log in to engine ' + options.engineEndpoint

    api.engineClient = new WebSocketClient(options.engineEndpoint)

    api.engineClient.on 'error', (err) ->
      logger.error 'unable to connect to engine server ' + options.engineEndpoint
      logger.help 'did you try starting the engine server?'
      logger.warn 'throwing connection error!'
      throw err;

    api.engineClient.on 'open', () ->

      logger.info 'api connected to ' + options.engineEndpoint

      api.engineClient.on 'message', (message) ->

        logger.data('api ' + process.pid +  ' received message from engine: ' + message);

        valid = false
        try
          message = JSON.parse message
          valid = true
        catch err
          valid = false

        api.frontEndSockets[message[1].front.fid].send(JSON.stringify(message))

        # If there is a valid socket.id in the current list of server sockets
        # if (typeof message.sid is 'string' and typeof engineIOServer.clients[message.sid] is 'object')
          # Send the message
          # engineIOServer.clients[message.sid].send(JSON.stringify(message, true))

      return callback null, wss