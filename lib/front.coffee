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

    connect = require('connect')
    express = require('express')
    http = require('http')
    sockjs = require('sockjs')
    WebSocket = require('ws')
    MemoryStore = express.session.MemoryStore

    # Create a new memory store for account sessions
    store = new MemoryStore()

    # Create a new express app
    app = express()
    server = http.createServer(app)

    # Expose the "/public" folder to the web using the static middleware provided with connect
    # see: https://github.com/senchalabs/connect/blob/master/lib/middleware/static.js
    app.use(connect.static('./public'))

    # Use the express session middleware to store account sessions
    secret = 'MUST-CHANGE-THIS-FOR-PRODUCTION'
    app.use(express.session({ store: store, secret: secret, key: 'sid' }))
    cookieParser = express.cookieParser(secret)

    # Create browser-facing sockjs server
    socketServer = sockjs.createServer
      sockjs_url: "/js/vendor/sockjs-0.3.min.js"
    socketServer.installHandlers(server, {prefix: '/sock'})

    server.listen options.port, options.host, ->
      logger.info "Buttercoin front-end server started on http://" +
        options.host + ":" + options.port

    socketServer.on 'connection', (connection) ->
      # TODO: authentication.
      # if we want the socket to work cross-domain, the client will need to
      # send a token/hmac/cookie as the first message over the connection.
      # Otherwise, we can probably rely on cookies.
      sid = null

      # TODO: retrieve session store based on sid
      # store.get sid, (err, res) ->
      #  console.log err, res

      connection.write 'hello ' + sid + '\ni am front-end ' + process.pid

      connection.on 'data', (message) ->
        logger.info('front ' + process.pid + ' received message from ' + sid + ': ' + message);

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
          wsClient.send JSON.stringify(message)
        else
          logger.warn 'invalid message - not relaying to api server'
          connection.write message

      #
      # Establish outgoing connection to VLAN websocket API server
      #
      logger.warn 'front attempting to log in to ' + options.apiEndpoint

      wsClient = new WebSocket(options.apiEndpoint)

      wsClient.on 'error', (err) ->
        logger.error 'unable to connect to api server ' + options.apiEndpoint
        logger.warn 'throwing connection error!'
        throw err;

      wsClient.on 'open', () ->

        logger.info 'front connected to ' + options.apiEndpoint

        wsClient.send 'i am front-end ' + process.pid

        wsClient.on 'message', (message) ->
          logger.info('front ' + process.pid +  ' received message: ' + message);

          callback null, server