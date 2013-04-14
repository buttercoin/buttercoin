SkipList = require("../../experimental/skiplist").SkipList

module.exports = class Market
  constructor: ->
    @buy_book = new SkipList()
    @sell_book = new SkipList()
