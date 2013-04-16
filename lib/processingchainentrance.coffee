Q = require 'q'
DataStore = require './datastore/datastore'
Operations = require './operations'

module.exports = class ProcessingChainEntrance
  constructor: (@engine, @journal, @replication) ->
    # @replication = new ReplicationThing

  start: =>
    Q.all [
      @journal.start(@forward_operation).then =>
        console.log 'INITIALIZED/REPLAYED LOG'
      @replication.start()
    ]

  forward_operation: (operation) =>
    Q.all( [
      @journal.record(operation)
      # replicate
      @replication.send(operation)
    ])
    .then =>
      # all complete -> put on queue
      @engine.execute_operation( operation )

