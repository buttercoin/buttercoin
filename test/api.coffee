chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Api = require('../lib/api')

describe 'Api', ->
  it 'should initialize', ->
    api = new Api
    api.start