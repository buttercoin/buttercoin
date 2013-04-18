SkipList = require('../experimental/skiplist')
SkipListNode = SkipList.SkipListNode
SkipList = SkipList.SkipList

Number::leq = (y) -> @ <= y

describe 'SkipList', ->
  beforeEach ->
    @list = new SkipList()

  it 'should start as empty', ->
    @list.is_empty().should.be.true

  it 'should not be empty after an insert', ->
    @list.insert_before(@list.rs, 10, null)
    @list.is_empty().should.not.be.true

  it 'should be empty after all items are deleted', ->
    new_node = @list.insert_before(@list.rs, 10, null)
    @list.delete_node(new_node)

  it 'should find a newly added node', ->
    new_node = @list.insert_before(@list.rs, 10, null)

    expect(@list.lower_bound(10)).to.exist
    @list.lower_bound(10).should.equal(new_node)
