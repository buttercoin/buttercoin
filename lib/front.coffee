module.exports = class Front
  constructor: () ->

  start: ( callback ) ->

    express = require('express')
    connect = require('connect')
    WebSocket = require('ws')

    # Create a new express app
    app = express()

    # Expose the "/public" folder to the web using the static middleware provided with connect
    # see: https://github.com/senchalabs/connect/blob/master/lib/middleware/static.js
    app.use(connect.static('./public'))

    # Remark: express listen function doesn't continue with err and server,
    # so we assign it to a value new value server instead
    server = app.listen 3000, () =>

      endpoint = "ws://localhost:3001";
      ws = new WebSocket(endpoint)

      ws.on 'open', () ->

        console.log 'front: connected to ' + endpoint

        ws.send 'i am front-end ' + process.pid

        ws.on 'message', (message) ->
          console.log('front: ' + process.pid +  ' received message: %s', message);

      callback null, server