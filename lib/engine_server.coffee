stump = require('stump')

BE = require('buttercoin-engine')
Journal = BE.Journal
ProcessingChainEntrance = BE.ProcessingChainEntrance

module.exports = class EngineServer
  constructor: (@options) ->
    stump.stumpify(@, @constructor.name)

    @options = @options or {}

    @options.journalname = @options.journalname or 'testjournal'

    @engine = new BE.TradeEngine()
    @journal = new BE.Journal(@options.journalname)
    @pce = new ProcessingChainEntrance( @engine, @journal )

  start: =>
    throw Error("Not Implemented")

  send_all: ( obj ) =>
    throw Error("Not Implemented")
