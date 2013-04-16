chai = require 'chai'
chai.should()
expect = chai.expect
assert = chai.assert

Q = require('q')
fs = require 'fs'
Journal = require '../lib/journal'
Ops = require '../lib/operations'
TestHelper = require('./test_helper')

logger = require('../lib/logger')

kTestFilename = 'test.log'

describe 'Journal', ->
  beforeEach =>
   TestHelper.clean_state_sync

  afterEach =>
    TestHelper.clean_state_sync

  it 'should initialize', (finish) ->
    journal = new Journal( kTestFilename )
    journal.start( (op) =>
      console.log 'EXECUTE OP', op
    ).then =>
      console.log 'FINISHED'
      assert journal.filename is kTestFilename
      journal.shutdown().then =>
        finish()
    .done()

  it 'should initialize if the log file already exists', (finish) ->
    logger.info('test journal')
    journal = new Journal( kTestFilename )
    journal.start((op) =>
      console.log 'EXECUTE OP', op
    ).then =>
      # logger.info('STARTED 1')
      assert journal.filename is kTestFilename
      journal.shutdown().then =>
        journal.start((op) =>
          console.log 'EXECUTE OP', op
        ).then =>
          # logger.info('STARTED 2')
          assert journal.filename is kTestFilename
          journal.shutdown().then =>
            finish()
    .done()

  it 'should record a message correctly', (finish) ->
    journal = new Journal( kTestFilename )
    journal.start((op) =>
      console.log 'EXECUTE OP', op
    ).then =>
      raw_msg = [ Ops.ADD_DEPOSIT, "fake" ]
      msg = JSON.stringify(raw_msg)
      journal.record msg
    .then =>
      journal.flush()
      journal.shutdown().then =>
        assert fs.existsSync kTestFilename
        finish()
    .done()
