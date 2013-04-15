global.chai = require 'chai'
chai.should()
global.expect = chai.expect
global.assert = chai.assert

global.logger = require('../lib/logger')
