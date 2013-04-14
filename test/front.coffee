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