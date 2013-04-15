API = require('./api')

Engine = require('./engine')

Front = require('./front/front')

module.exports = class Buttercoin
  constructor: ->
    @engine = new Engine()
    @api = new API(@engine)
    @front = new Front()
