SkipList = require('../../experimental/skiplist').SkipList
DQ = require ('deque')

module.exports = class Book
  constructor: () ->
    # TODO - keep a typed array of price levels combined with a hash of actual orders?
    @store = new SkipList()

  fill_orders_with: (order) =>
    cur = @store.head()
    closed = [] # TODO - snip skiplist at a certain point?
    amount_filled = 0
    amount_remaining = order.received_amount
    order_level = []
    while cur?.v <= order.price and amount_remaining > 0 and not @store.is_sentinel(cur) #head.v -> price
      order_level = cur.payload

      # cloce the whole price level if we can
      if order_level.size <= amount_remaining
        amount_filled += order_level.size
        amount_remaining -= order_level.size
        closed.push(cur)
      else
        # consume all orders we can at this price level
        cur_order = order_level.orders.shift()
        while cur_order?.offered_amount <= amount_remaining
          amount_filled += cur_order.amount
          amount_remaining -= cur_order.amount
          order_level.size -= cur_order.amount
          if order_level.orders.isEmpty()
            cur_order = null
          else
            cur_order = order_level.orders.shift()
        
        # diminish next order by remaining amount
        if cur_order?.offered_amount > 0
          # TODO - don't mutate order?
          cur_order.offered_amount -= amount_remaining
          order_level.size -= amount_remaining
          amount_filled += amount_remaining
          amount_remaining = 0
          order_level.orders.unshift(cur_order)

      cur = cur.r

    closed.forEach (x) =>
      @store.delete_node(x) unless @store.is_sentinel(x)
  
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

