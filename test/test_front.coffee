chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Buttercoin = require('../lib/buttercoin')
describe 'Front', ->
  it 'can initialize optionless', (finish) ->
    butter = new Buttercoin()
    butter.front.start {}, finish

  it 'can initialize with options', (finish) ->
    butter = new Buttercoin()
    butter.front.start {port: 3000, host: "0.0.0.0", apiEndpoint: "ws://localhost:3001"}, finish