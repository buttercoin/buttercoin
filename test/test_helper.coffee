Q = require('q')
global.chai = require 'chai'
global.expect = chai.expect
global.assert = chai.assert
global.sinon = require('sinon')
chai.should()

global.logger = require('../lib/logger')
global.Q = require('Q')

fs = require('fs')

class TestHelper
  constructor: ->

  @clean_state_sync: ->
    if fs.existsSync 'journal.log'
      fs.unlinkSync 'journal.log'

    if fs.existsSync 'test.log'
      fs.unlinkSync 'test.log'

global.TestHelper = TestHelper
