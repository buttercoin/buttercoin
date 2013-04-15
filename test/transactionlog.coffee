chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Q = require('q')
fs = require 'fs'
TLog = require '../lib/transactionlog'
Ops = require '../lib/operations'
TestHelper = require('./test_helper')

kTestFilename = 'test.log'

describe 'TransactionLog', ->
  beforeEach =>
   TestHelper.clean_state_sync 

  afterEach =>
    TestHelper.clean_state_sync

  it 'should initialize', (finish) ->
    trans_log = new TLog kTestFilename
    trans_log.start().then =>
      assert trans_log.filename is kTestFilename
      trans_log.shutdown()
      finish()
    .done()

  it 'should initialize if the log file already exists', (finish) ->
    trans_log = new TLog kTestFilename
    trans_log.start().then =>
      assert trans_log.filename is kTestFilename
      trans_log.shutdown()
      trans_log.start().then =>
        assert trans_log.filename is kTestFilename
        trans_log.shutdown()
        finish()
    .done()

  it 'should record a message correctly', (finish) ->
    trans_log = new TLog kTestFilename
    trans_log.start().then =>
      raw_msg = [ Ops.ADD_DEPOSIT, "fake" ]
      msg = JSON.stringify(raw_msg)
      trans_log.record msg
    .then =>
      trans_log.flush
      trans_log.shutdown
      assert fs.existsSync kTestFilename
      finish()
    .done()
