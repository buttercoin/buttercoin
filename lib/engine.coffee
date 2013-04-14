
Dequeue = require('deque').Dequeue

DataStore = require('./datastore/datastore')

TransactionLog = require('./transactionlog')

Q = require('q')

operations = require("./operations")

module.exports = class Engine
  constructor: ->
    @transaction_log = new TransactionLog(@)
    @datastore = new DataStore()

  start: =>
    return Q.fcall =>
      return @transaction_log.start()
    .then =>
      console.log 'STARTED ENGINE'

  receive_message: (message) =>
    # journal + replicate

    console.log 'RECEIVED MESSAGE'

    @transaction_log.record( JSON.stringify(message) ).then =>
      # deserialize (skipping this for now)
      # execute business logic
      @replay_message(message)

  replay_message: (message) =>
    console.log 'REPLAY MESSAGE', message

    if message[0] == operations.ADD_DEPOSIT
      @datastore.add_deposit(message[1])
    else
      throw Error("Unknown Operation Type")

  flush: =>
    @transaction_log.flush()