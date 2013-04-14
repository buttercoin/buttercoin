chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Front = require('../lib/front')

describe 'Front', ->

  it 'should initialize', ->
    front = new Front()
    front.start