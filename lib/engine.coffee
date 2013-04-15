logger = require('./logger')

Dequeue = require('deque').Dequeue

DataStore = require('./datastore/datastore')

TransactionLog = require('./transactionlog')

Q = require('q')

operations = require("./operations")

module.exports = class Engine
  constructor: ->
    @transaction_log = new TransactionLog(@)
    @datastore = new DataStore()
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
    options.host = options.host || "0.0.0.0"
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

    return Q.fcall =>
      return @transaction_log.start()

  receive_message: (message) =>
    # journal + replicate

    console.log 'RECEIVED MESSAGE'

    @transaction_log.record( JSON.stringify(message) ).then =>
      # deserialize (skipping this for now)
      # execute business logic
      @replay_message(message)

  replay_message: (message) =>
    console.log 'REPLAY MESSAGE'

    engine = this

    message[1].callback = () ->
      # if there is a socket connected to the trade engine
      if engine.socket
        message[1].etime = new Date().getTime() # <- stub execution time estimate ( inaccurate )
        # send the message back out through that socket
        engine.socket.send(JSON.stringify(message))

    if message[0] == operations.ADD_DEPOSIT
      @datastore.add_deposit(message[1])
    else
      throw new Error("Unknown Operation Type")

  flush: =>
    @transaction_log.flush()
