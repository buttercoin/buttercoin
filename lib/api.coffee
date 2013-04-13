
module.exports = class API
  constructor: (@engine) ->

  add_deposit: ( args ) ->
    message = ['ADD_DEPOSIT', args ]

    @engine.receive_message(message)


  start: ( callback ) ->

    express = require('express');

    # Create a new express app
    app = express();

    app.get '/', (req, res) ->
      res.end 'Buttercoin websocket API endpoint'

    # Remark: express listen function doesn't continue with err and server,
    # so we assign it to a value new value server instead
    server = app.listen 3001, () =>
      callback null, server