Q = require('q')
global.chai = require 'chai'
chai.should()
global.expect = chai.expect
global.assert = chai.assert
global.sinon = require('sinon')

global.logger = require('../lib/logger')

fs = require('fs')

module.exports = class TestHelpers
  constructor: ->

  @clean_state_sync: ->
    if fs.existsSync 'journal.log'
      Q.fcall =>
        fs.unlinkSync 'journal.log'
      .end()

    if fs.existsSync 'test.log'
      Q.fcall =>
        fs.unlinkSync 'test.log'
      .end()
