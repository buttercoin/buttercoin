chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Buttercoin = require('../lib/buttercoin')

describe 'FrontEngine', ->
  it 'can initialize with options', (finish) ->
    server_options =
      port: 3000
      host: "0.0.0.0"
      apiEndpoint: "ws://localhost:3001"
    butter = new Buttercoin()
    butter.front.start server_options, finish
