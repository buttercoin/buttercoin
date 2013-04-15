chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Q = require('q')
fs = require 'fs'
TLog = require '../lib/transactionlog'
Ops = require '../lib/operations'

kTestFilename = 'test.log'

describe 'TransactionLog', ->
  it 'should initialize', (finish) ->
    trans_log = new TLog null, kTestFilename
    trans_log.start().then =>
      assert trans_log.filename is kTestFilename
      trans_log.shutdown()
      finish()
    .done()

  it 'should initialize if the log file already exists', (finish) ->
    trans_log = new TLog null, kTestFilename
    trans_log.start().then =>
      assert trans_log.filename is kTestFilename
      trans_log.shutdown()
      trans_log.start().then =>
        assert trans_log.filename is kTestFilename
        trans_log.shutdown()
        finish()
    .done()

  it 'should record a message correctly', (finish) ->
    # Make sure the state is clean
    if fs.existsSync kTestFilename
      fs.unlinkSync kTestFilename

    trans_log = new TLog null, kTestFilename
    trans_log.start().then =>
      raw_msg = [ Ops.ADD_DEPOSIT, "fake" ]
      msg = JSON.stringify(raw_msg)
      trans_log.record msg
    .then =>
      trans_log.flush
      trans_log.shutdown
      assert fs.existsSync kTestFilename
      fs.unlink kTestFilename
    .then (err) =>
      if (err)
        console.log 'Unlink error: ', err
      finish()
    .done()
      
