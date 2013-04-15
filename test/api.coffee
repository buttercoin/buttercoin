Api = require('../lib/api')
WebSocket = require('ws')

describe 'Api', ->
  it 'should initialize', ->
    api = new Api
    api.start

  it 'should start and provide a WS server', ->
    api = new Api
    api.start {port: 3022, host: "0.0.0.0"}, () =>
      logger.info 'called api callback'

    client = new WebSocket("ws://localhost:3022")
    client.on 'connection', () ->
      client.send '{"itsjson":"morejson"}'

      client.on 'message', () ->
        logger.info 'Client received message:' + message


