logger = require './logger'

module.exports = class Front
  constructor: () ->

  start: ( options, callback ) ->

    # Basic currying for front.start method
    if typeof options is 'function'
      callback = options
      options = {}

    options = options || {}

    # Default front.start options
    options.port = options.port || 3000
    options.host = options.host || "0.0.0.0"
    options.apiEndpoint = options.apiEndpoint || "ws://localhost:3001"

    express = require('express')
    connect = require('connect')
    WebSocket = require('ws')
    engineio = require('engine.io')
    MemoryStore = express.session.MemoryStore

    # Create a new memory store for account sessions
    store = new MemoryStore()

    # Create a new express app
    app = express()

    # Expose the "/public" folder to the web using the static middleware provided with connect
    # see: https://github.com/senchalabs/connect/blob/master/lib/middleware/static.js
    app.use(connect.static('./public'))

    # Use the express session middleware to store account sessions
    secret = 'MUST-CHANGE-THIS-FOR-PRODUCTION'
    cookieParser = express.cookieParser(secret)

    app.use(cookieParser);
    app.use(express.session({ store: store, secret: secret, key: 'sid' }))

    server = app.listen options.port, options.host, () ->

      #
      # Create public facing websocket server
      #
      engineIOServer = engineio.attach(server)

      logger.info "Buttercoin front-end server started on http://" + server.address().address + ":" + server.address().port

      engineIOServer.on 'error', (err) ->
        throw err

      engineIOServer.on 'connection', (socket) ->

        socket.send 'hello ' + socket.id + '\ni am front-end ' + process.pid

        socket.on 'error', (err) ->
          throw err

        socket.on 'message', (message) ->
          logger.info('front ' + process.pid +  ' received message from ' + socket.id + ': ' + message);

          #
          # Remark: this is where conditional logic can be placed to authorize the message before it is
          # passed along to an API server
          valid = false

          # Check if incoming message is actually valid JSON
          try
            message = JSON.parse message
            valid = true
          catch err
            valid = false
            message = err.message

          if valid
            message.sid = socket.id
            wsClient.send JSON.stringify(message)
          else
            logger.warn 'invalid message - not relaying to api server'
            socket.send message

      #
      # Establish outgoing connection to VLAN websocket API server
      #
      logger.warn 'front attempting to log in to ' + options.apiEndpoint

      wsClient = new WebSocket(options.apiEndpoint)

      wsClient.on 'error', (err) ->
        logger.error 'unable to connect to api server ' + options.apiEndpoint
        logger.help 'did you try starting the api server?'
        logger.warn 'throwing connection error!'
        throw err;

      wsClient.on 'open', () ->

        logger.info 'front connected to ' + options.apiEndpoint

        wsClient.send 'i am front-end ' + process.pid

        wsClient.on 'message', (message) ->
          logger.info('front ' + process.pid +  ' received message: ' + message);
          try
            message = JSON.parse message
          catch err
            message = {}

          if (typeof message.sid is 'string' and typeof engineIOServer.clients[message.sid] is 'object')
            engineIOServer.clients[message.sid].send(JSON.stringify(message, true))

          callback null, server