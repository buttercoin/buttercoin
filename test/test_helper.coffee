global.chai = require 'chai'
chai.should()
global.expect = chai.expect
global.assert = chai.assert
global.sinon = require('sinon')

global.logger = require('../lib/logger')

fs = require('fs')

global.TestHelper = class TestHelper
  constructor: ->

  @clean_state_sync: ->
    if fs.existsSync 'transaction.log'
      fs.unlinkSync 'transaction.log'

    if fs.existsSync 'test.log'
      fs.unlinkSync 'test.log'

