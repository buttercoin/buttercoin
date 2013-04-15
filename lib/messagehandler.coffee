TransactionLog = require './transactionlog'
Q = require 'q'
DataStore = require './datastore/datastore'
Operations = require './operations'

# The MessageHandler class deals with the high level processing flow of each
# message that the server receives.  This includes the interactions with the
# transaction logs (for replaying transactions), sending the messages to the
# order engine/processor (datastore), and [eventually] signalling the
# datastore snapshots
module.exports = class MessageHandler
  constructor: () ->
    @tlog = new TransactionLog
    @datastore = new DataStore

  start: ->
    # TODO: (qubey) this doesn't current handle the case when we are still
    # replaying the transactions from the log file when our first new
    # message comes in.  We need to handle this case more gracefully
    @tlog.start().then =>
      @tlog.replay_log()
    .progress (message) =>
      @process_message message, false
    .fin =>
      console.log 'Done with replay'

  process_message: (message, save = true) ->
    # TODO: (qubey) add more validation for the incoming message
    if message[0] == Operations.ADD_DEPOSIT
      if save
        @tlog.record message
      @datastore.add_deposit(message[1])
    else
      throw new Error( "Unkown operation type: " + message )
