Q = require('q')
WebSocketServer = require('ws').Server

module.exports = class EngineWebsocketAdapter
  constructor: (pce) ->
    if not pce
      throw new Error('Cannot create EngineWebsocketAdapter without PCE')

    @pce = pce

  start: ( options, callback ) ->
    serverOptions = {
      host: options.host ? 'localhost',
      port: options.port ? 8080
    }

    adapter = this

    @wss = new WebSocketServer(serverOptions)
    console.log 'WS Server started on ', sercerOptions.host, ' using port ', serverOptions.port

    @wss.on 'error', (err) =>
      # TODO: decide what to do here
      throw err

    @wss.on 'connection', (conn) =>
      conn.on 'error', (err) =>
        # TODO: come up with error API spec
        console.log 'SOCKET ERROR: ', err
        conn.close()

      conn.on 'message', (message) =>
        adapter.process_message(message)

          
  process_message: (conn, message) ->
    # TODO: come up with better API
    try
      operation = JSON.parse message

      # TODO: operation validation!

      @pce.forward_operation(operation).then =>
        conn.send('Success')
        conn.close()
      .fail (err) =>
        throw err
    catch err
      console.log 'WSA Error: ', err
      conn.send('Invalid message: ' + message)
      conn.close()
