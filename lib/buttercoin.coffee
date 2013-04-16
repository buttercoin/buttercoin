ApiClient = require('./api_client')
Api = require('./api')
Front = require('./front/front')
logger = require('./logger')

module.exports = class Buttercoin
  @set_log_level: logger.set_levels
  constructor: ->
    @api = new Api()
    @api_client = new ApiClient()
    @front = new Front()
