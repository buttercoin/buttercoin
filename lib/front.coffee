module.exports = class Front
  constructor: () ->

  start: ( callback ) ->

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

    # Remark: express listen function doesn't continue with err and server,
    # so we assign it to a value new value server instead
    server = app.listen 3000, () ->

      #
      # Create public facing websocket server
      #
      wss = new WebSocket.Server {server: server}
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
            console.log('front: ' + process.pid +  ' received message from ' + sid + ': %s', message);

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
              console.log 'front: invalid message - not relaying to api server'
              ws.send message

      #
      # Establish outgoing connection to VLAN websocket API server
      #
      endpoint = "ws://localhost:3001";
      wsClient = new WebSocket(endpoint)

      wsClient.on 'open', () ->

        console.log 'front: connected to ' + endpoint

        wsClient.send 'i am front-end ' + process.pid

        wsClient.on 'message', (message) ->
          console.log('front: ' + process.pid +  ' received message: %s', message);

      callback null, server