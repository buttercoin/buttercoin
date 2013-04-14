chai = require 'chai'  
chai.should()
expect = chai.expect
assert = chai.assert

Market = require('../../lib/datastore/market')
SkipList = require("../../experimental/skiplist").SkipList

describe 'Market', ->
  it 'should initialize with a buy book and a sell book', ->
    market = new Market()
    market.buy_book.should.be.an.instanceOf(SkipList)
    market.sell_book.should.be.an.instanceOf(SkipList)
