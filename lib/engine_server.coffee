stump = require('stump')

BE = require('buttercoin-engine')
Journal = BE.Journal
ProcessingChainEntrance = BE.ProcessingChainEntrance

module.exports = class EngineServer
  constructor: (@journalname) ->
    stump.stumpify(@, @constructor.name)

    @journalname = @journalname or 'testjournal'

    @engine = new BE.TradeEngine()
    @journal = new BE.Journal(@journalname)
    @replication = new BE.Replication()
    @pce = new ProcessingChainEntrance( @engine, @journal, @replication )

  start: =>
    throw Error("Not Implemented")

  send_all: ( obj ) =>
    throw Error("Not Implemented")    