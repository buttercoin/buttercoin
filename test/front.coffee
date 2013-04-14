chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Front = require('../lib/front')

describe 'Front', ->
  beforeEach ->
    @front = new Front

  it 'should initialize', ->
    @front.start

  it 'should start a WSS', ->
    @front.start
    # test for WSS existence

  it 'should connect to the API', ->
    @front.start
    # test connection to API