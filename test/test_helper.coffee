global.chai = require 'chai'
global.expect = chai.expect
global.assert = chai.assert
global.sinon = require('sinon')
chai.should()

global.logger = require('../lib/logger')
global.Q = require('q')
Order = require('../lib/datastore/order')

fs = require('fs')

chai.use (_chai, utils) ->
  chai.Assertion.addMethod 'succeed_with', (kind) ->
    obj = utils.flag(this, 'object')
    this.assert obj.status is 'success',
                "Expected #\{this} to have status of success but got #{obj.status}",
                "Expected #\{this} not to have status of "
    this.assert obj.kind is kind,
                "Expected #\{this} to have kind of #{kind} but got #{obj.kind}",
                "Expected #\{this} not to have kind of #{kind} (got #{obj.kind}"


class TestHelper
  constructor: ->

  @clean_state_sync: ->
    if fs.existsSync 'journal.log'
      fs.unlinkSync 'journal.log'

    if fs.existsSync 'test.log'
      fs.unlinkSync 'test.log'

global.TestHelper = TestHelper

global.buyBTC = (acct, numBtc, numDollars) ->
  new Order(acct, 'USD', numDollars, 'BTC', numBtc)

global.sellBTC = (acct, numBtc, numDollars) ->
  new Order(acct, 'BTC', numBtc, 'USD', numDollars)

global.logResults = (results) ->
  displaySold = (x) ->
    console.log "\t#{x.account.name} sold #{x.received_amount} #{x.received_currency} for #{x.offered_amount} #{x.offered_currency}"
  displayOpened = (x) ->
    console.log "\t#{x.account.name} listed #{x.received_amount} #{x.received_currency} for #{x.offered_amount} #{x.offered_currency}"
  while results.length > 0
    x = results.shift()
    if x.kind is 'order_opened' #or x.kind is 'order_partially_filled'
      displayOpened(x.order || x.residual_order)
    if x.kind is 'order_filled' or x.kind is 'order_partially_filled'
      displaySold(x.order || x.filled_order)
