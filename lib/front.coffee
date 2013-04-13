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
    app.use(express.session({ store: store, secret: secret, key: 'sid' }))
    cookieParser = express.cookieParser(secret)

    server = app.listen options.port, options.host, () ->

      #
      # Create public facing websocket server
      #
      wss = new WebSocket.Server {server: server}

      logger.info "Buttercoin front-end server started on http://" + server.address().address + ":" + server.address().port

      wss.on 'connection', (ws) ->

        cookieParser ws.upgradeReq, null, (err) ->

          if err
            throw err

          #
          # TODO: use ws.upgradeReq.signedCookies instead of ws.upgradeReq.cookies
          #

          # Get the session id from cookie
          sid = ws.upgradeReq.cookies['connect.sid']

          #
          # TODO: retrieve session store based on sid from websocket
          #
          # store.get sid, (err, res) ->
          #  console.log err, res

          ws.send 'hello ' + sid + '\ni am front-end ' + process.pid

          ws.on 'message', (message) ->
            logger.info('front ' + process.pid +  ' received message from ' + sid + ': ' + message);

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
              ws.send message

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