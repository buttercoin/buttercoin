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
    q = Q.all [
      @journal.record(message)
      @replication.send(message)]

    q.then(@package_operation)
     .then(@on_operation_succeded)
     #.fail(@on_operation_failed)
     #.done()

  package_operation: (operation) =>
    deferred = Q.defer()
    try
      deferred.resolve(
        @engine.execute_operation
          message: operation
          uid: undefined)
    catch err
      deferred.reject(err)

    return deferred.promise


  on_operation_succeded: (update_set) =>
    console.log "success:", update_set

  on_operation_failed: (error) =>
    console.log "failure:", error
