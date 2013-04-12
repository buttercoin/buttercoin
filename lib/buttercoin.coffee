API = require('./api')

Engine = require('./engine')

module.exports = class Buttercoin
  constructor: ->
    @engine = new Engine()
    @api = new API(@engine)

    @engine.process_loop()