Q = require 'q'
DataStore = require './datastore/datastore'
Operations = require './operations'

module.exports = class ProcessingChainEntrance
  constructor: (@engine, @journal, @replication) ->

  start: =>
    Q.all [
      @journal.start(@forward_operation).then =>
        console.log 'INITIALIZED/REPLAYED LOG'
      @replication.start()
    ]

  forward_operation: (operation) =>
    message = JSON.stringify(operation)
    Q.all([
      @journal.record(message)
      @replication.send(message)
    ]).then =>
        @engine.execute_operation({
          message: message
          uid: undefined
          #success: undefined
          #error: undefined
        })

