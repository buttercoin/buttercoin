SkipList = require('../../experimental/skiplist').SkipList
DQ = require ('deque')

joinQueues = (front, back, withCb) ->
  withCb ||= (x) -> x
  until back.isEmpty()
    front.push withCb(back.shift())

mkCloseOrder = (order) -> {
  status: 'success'
  kind: 'order_filled'
  order: order
}

mkPartialOrder = (original_order, filled, remaining) -> {
  status: 'success'
  kind: 'order_partially_filled'
  filled_order: filled
  remaining_order: remaining
  original_order: original_order
}

module.exports = class Book
  constructor: -> #(@inverted=false) -> #(@offered_currency, @received_currency) ->
    # TODO - keep a typed array of price levels combined with a hash of actual orders?
    @store = new SkipList()

  fill_orders_with: (order) =>
    # TODO - Move this check to the market?
    orig_order = order
    order = order.clone()
    order.price = 1/order.price

    cur = @store.head()
    closed = [] # TODO - snip skiplist at a certain point, requires changes in SkipList
    amount_filled = 0
    amount_remaining = order.received_amount
    results = new DQ.Dequeue()

    while cur?.v <= order.price and amount_remaining > 0 and not @store.is_sentinel(cur) #head.v -> price
      order_level = cur.payload

      # cloce the whole price level if we can
      if order_level.size <= amount_remaining
        amount_filled += order_level.size
        amount_remaining -= order_level.size

        # queue the entire price level to be closed
        closed.push(cur)
      else
        # consume all orders we can at this price level, starting with the oldest
        cur_order = order_level.orders.shift()
        while cur_order?.offered_amount <= amount_remaining
          amount_filled += cur_order.amount
          amount_remaining -= cur_order.amount
          order_level.size -= cur_order.amount
          results.push mkCloseOrder(cur_order)
          
          # there must always be another order here or else we would have consumed 
          # the entire price level at once
          #
          # if there isn't we have a major problem 
          cur_order = order_level.orders.shift()
        
        # diminish next order by remaining amount
        if cur_order?.offered_amount > 0
          [filled, remaining] = cur_order.split(amount_remaining)
          order_level.size -= amount_remaining
          amount_filled += amount_remaining
          amount_remaining = 0

          # push the partially filled order back to the front of the queue
          order_level.orders.unshift(remaining)

          # report the partially filled order
          results.push mkPartialOrder(cur_order, filled, remaining)

      cur = cur.r

    closed.forEach (x) =>
      joinQueues(results, x.payload.orders, mkCloseOrder)
      @store.delete_node(x) unless @store.is_sentinel(x)

    if amount_remaining == 0
      results.push mkCloseOrder(orig_order)
    else if amount_filled == 0
      results.push {
        status: 'success'
        kind:   'not_filled'
        order: orig_order
      }
    else
      [filled, remaining] = orig_order.split(amount_filled)
      results.push mkPartialOrder(orig_order, filled, remaining)

    return results
  
  add_order: (order) =>
    # get the node at or below a price level
    node = @store.lower_bound(order.price)
    if node?.v == order.price
      # append to current order level
      node.payload.size += order.offered_amount
      node.payload.orders.push(order)
    else
      # create order level
      dq = new DQ.Dequeue()
      dq.push(order)
      level =
        size: order.offered_amount
        orders: dq
      @store.insert_before(node || @store.rs, order.price, level)

    return {
      status: 'success'
      kind: 'order_opened'
      order: order
    }

