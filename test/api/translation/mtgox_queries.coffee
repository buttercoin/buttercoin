Router = require('../../../lib/api/translation/routing').Router
require '../../../lib/api/translation/mtgox_queries'

describe 'MtGoxQueriesTranslator', ->
  aid = undefined
  translator = undefined

  beforeEach ->
    aid = "dfasdlfkjf24234098093sf"

  # Return open orders
  # no MtGox Params
  it 'should translate open orders query method from MtGox to ButterCoin', ->
    request =
      url: 'orders'
    translator = Router.route(request)

    mtgox_params = {}

    bc_request = translator.translate(mtgox_params)
    expect(bc_request).to.be.ok

    bc_request.operation.should.equal 'OPEN_ORDERS'

  # Order result
  # type <bid or ask>
  # order <order id in>
  describe 'order results', ->
    oid = undefined
    request = undefined
    translator = undefined
    beforeEach ->
      oid = 'afdadfas098098908uiofsdsdf'
      request =
        url: 'order/result'
      translator = Router.route(request)

    it 'should be able to find a router for an existing route', ->
      expect(translator).to.be.ok
      translator.constructor.name.should.equal 'OrderInfoTranslator'

    it 'should translate order result bid query method from MtGox to ButterCoin', ->
      
      mtgox_params =
        type: 'bid'
        order: oid

      bc_request = translator.translate(mtgox_params)
      expect(bc_request).to.be.ok

      bc_request.operation.should.equal 'ORDER_INFO'

    it 'should translate order result ask query method from MtGox to ButterCoin', ->
      
      mtgox_params =
        type: 'ask'
        order: oid

      bc_request = translator.translate(mtgox_params)
      expect(bc_request).to.be.ok

      bc_request.operation.should.equal 'ORDER_INFO'

  xit 'should translate market depth query method from MtGox', ->
    request =
      url: 'orders'
    translator = Router.route(request)

