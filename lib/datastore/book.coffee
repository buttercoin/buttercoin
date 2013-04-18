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

module.exports = class Book
  constructor: () ->
    # TODO - keep a typed array of price levels combined with a hash of actual orders?
    @store = new SkipList()

  fill_orders_with: (order) =>
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
          
          # there must always be another order here or else we would have consumed 
          # the entire price level at once
          #
          # if there isn't we have a major problem 
          cur_order = order_level.orders.shift()
        
        # diminish next order by remaining amount
        if cur_order?.offered_amount > 0
          # TODO - don't mutate order, create new instead?
          cur_order.offered_amount -= amount_remaining
          order_level.size -= amount_remaining
          amount_filled += amount_remaining
          amount_remaining = 0

          # push the partially filled order back to the front of the queue
          order_level.orders.unshift(cur_order)

      cur = cur.r

    closed.forEach (x) =>
      joinQueues(results, x.payload.orders, mkCloseOrder)
      @store.delete_node(x) unless @store.is_sentinel(x)


    if amount_remaining == 0
      results.push mkCloseOrder(order)
    else if amount_filled == 0
      results.push {
        status: 'success'
      }
    else
      results.push {
        status: 'success'
      }

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

