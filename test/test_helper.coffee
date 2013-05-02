global.chai = require 'chai'
global.expect = chai.expect
global.assert = chai.assert
global.sinon = require('sinon')
chai.should()

global.Q = require('q')
global.stump = require('stump')

fs = require('fs')

chai.use (_chai, utils) ->
  chai.Assertion.addMethod 'succeed_with', (kind) ->
    obj = utils.flag(this, 'object')
    this.assert obj.status is 'success',
                "Expected #\{this} to have status of success but got #{obj.status}",
                "Expected #\{this} not to have status of "
    this.assert obj.kind is kind,
                "Expected #\{this} to have kind of #{kind} but got #{obj.kind}",
                "Expected #\{this} not to have kind of #{kind} (got #{obj.kind}"

class TestHelper
  constructor: ->

  @clean_state_sync: ->
    if fs.existsSync 'journal.log'
      fs.unlinkSync 'journal.log'

    if fs.existsSync 'test.log'
      fs.unlinkSync 'test.log'

global.TestHelper = TestHelper

