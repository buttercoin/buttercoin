API = require('./api')
Engine = require('./engine')
Front = require('./front/front')
logger = require('./logger')

module.exports = class Buttercoin
  @set_log_level: logger.set_levels
  constructor: ->
    @engine = new Engine()
    @api = new API(@engine)
    @front = new Front()
