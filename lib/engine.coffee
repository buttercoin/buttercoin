logger = require('./logger')

Dequeue = require('deque').Dequeue

Q = require('q')

module.exports = class Engine
  constructor: ->
    #@handler = new MessageHandler
    @socket = null

  start: ( options, callback ) ->

    engine = this

    # Basic currying for engine.start method
    if typeof options is 'function'
      callback = options
      options = {}

    options = options || {}

    # Default api.start options
    options.port = options.port || 3003
    options.host = options.host || "localhost"
    WebSocketServer = require('ws').Server
    wss = new WebSocketServer({port: options.port, host: options.host});

    logger.info "Buttercoin engine server started on ws://" + wss.options.host + ":" + wss.options.port

    wss.on 'error', (err) ->
      throw err

    wss.on 'connection', (socket) ->

      engine.socket = socket
      logger.warn 'engine server receiving incoming ws'

      socket.on 'error', (err) ->
        throw err

      socket.on 'message', (message) ->
        logger.data 'engine server ' + process.pid + ' received message: ' + message

        try
          message = JSON.parse message
        catch err
          message = {}

        engine.receive_message(message)

    callback(null, wss)

  receive_message: (message) =>
    console.log 'RECEIVED MESSAGE'
    engine = this

    # TODO: better error handling and reporting; propagate correct information
    # on the success or failure of processing the request
    message[1].callback = (error, param) ->
      if error
        # if there is a socket connected to the trade engine
        if engine.socket
          message[1].booked = false
          message[1].error = error.toString()
          message[1].etime = new Date().getTime() # <- stub execution time estimate ( inaccurate )
          # send the message back out through that socket
          engine.socket.send(JSON.stringify(message))
      else    
        # if there is a socket connected to the trade engine
        if engine.socket
          message[1].booked = true
          message[1].etime = new Date().getTime() # <- stub execution time estimate ( inaccurate )
          # send the message back out through that socket
          engine.socket.send(JSON.stringify(message))

    @handler.process_message(message)
