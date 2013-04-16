Q = require 'q'
DataStore = require './datastore/datastore'
Operations = require './operations'

module.exports = class ProcessingChainEntrance
<<<<<<< HEAD
  constructor: (@engine, @journal, @replication) ->
    # @replication = new ReplicationThing
=======
  constructor: (@engine, @tlog, @replication) ->
>>>>>>> 390aea79a869c4571274a3711edaad98028d141a

  start: =>
    Q.all [
      @journal.start(@forward_operation).then =>
        console.log 'INITIALIZED/REPLAYED LOG'
      @replication.start()
    ]

<<<<<<< HEAD
  forward_operation: (operation) =>
    Q.all( [
      @journal.record(operation)
      # replicate
      @replication.send(operation)
    ])
    .then =>
      # all complete -> put on queue
      @engine.execute_operation( operation )
=======
  forward_message: (message) =>
    Q.all([
      @tlog.record(JSON.stringify(message))
      @replication.send(message)
    ]).then =>
        @engine.execute_operation({
          message: message
          uid: undefined
          success: undefined
          error: undefined
        })
>>>>>>> 390aea79a869c4571274a3711edaad98028d141a

