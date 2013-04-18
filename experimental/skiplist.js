// Enki: Taken from https://github.com/reddragon/skiplist-js

/* Copyright (C) 2013 Gaurav Menghani

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

util = require('util');

// SkipListNode
// Each node in the SkipList is a SkipListNode
function SkipListNode(value, payload) {
    // Setting the value and initializing the direction pointers
    this.v = value;
    this.l = null;
    this.r = null;
    this.u = null;
    this.d = null;
    this.payload = payload;
}

// SkipList
function SkipList(coinflipper) {
    // Left Sentinel & Right Sentinels
    // We keep guard elements at each level, one at the left-most end,
    // and the other at the right-most end. These are called left
    // and right sentinels, and have the lm and rm properties set.
    // Left and Right Sentinels at the top-most level are directly
    // accessibel through the ls and rs attributes of the SkipList
    this.ls = new SkipListNode(null);
    this.rs = new SkipListNode(null);

    // Setting up their pointers
    this.ls.r = this.rs;
    this.rs.l = this.ls;

    // Is this the left sentinel (i.e, the left-most element)?
    this.ls.lm = true;

    // Is this the right sentinel (i.e, the right-most element)?
    this.rs.rm = true;

    // The top-most left-sentinel is also the 'root' of the SkipList
    // Setting the top-left pointer of the root
    this.root = this.ls;

    // For those who are conscious about their PRNGs! :D
    this.coinflipper = coinflipper || function () { return Math.round(Math.random()); };
}

SkipList.prototype =  {
    _promote_sentinels: function () {
        // This function is called when a new node grows beyond the top level

        // Create new sentinels for the new level
        var new_ls = new SkipListNode(null);
        var new_rs = new SkipListNode(null);

        // They are left-most and right-most respectively
        new_ls.lm = true;
        new_rs.rm = true;

        // Set the pointers
        new_ls.d = this.ls;
        new_rs.d = this.rs;
        this.ls.u = new_ls;
        this.rs.u = new_rs;
        new_ls.r = new_rs;
        new_rs.l = new_ls;

        // Update the sentinels
        this.ls = new_ls;
        this.rs = new_rs;

        // Set the new root
        this.root = this.ls;
    },

    _demote_sentinels: function () {
        // This function is called when there are no elements
        // left at a level, so we delete that level.

        // However, we should not try to delete the sole level
        if (this.ls.r !== this.rs || this.ls.d === null) {
            throw new Error('Sentinels can\'t be demoted any further');
        }

        // Get the new sentinels
        var new_ls = this.ls.d;
        var new_rs = this.rs.d;

        // Resetting the up pointers
        new_ls.u = null;
        new_rs.u = null;

        // Update the sentinels
        this.ls = new_ls;
        this.rs = new_rs;

        // Set the new root
        this.root = this.ls;
    },

    head: function () {
	cur = this.root.r;
	while (cur.d != null) {
	    cur = cur.d;
	}

	return cur;
    },

    is_empty: function () {
        return this.ls.r === this.rs
    },

    insert_before: function (before, value, payload) {
        // Are we messing with the left sentinel?
        if (before.lm) {
            throw new Error('Cannot insert before the left sentinel.');
        }

        // Get the neighbors
        var l = before.l;
        var r = before;

        // Create a new node
        var new_node = new SkipListNode(value, payload);
        var n = new_node;

        // Set the pointers of its left and right neighbors
        l.r = n;
        r.l = n;
        n.l = l;
        n.r = r;
        var old_node = n;

        while (this.coinflipper()) {
            // console.log('Heads');

            // Move left till you have an up pointer
            while (l.u === null && !l.lm) {
                l = l.l;
            }

            // Our left is a sentinel, and no one lives upstairs.
            if (l.lm === true && l == this.root) {
                this._promote_sentinels();
            }

            // Now actually move up
            l = l.u;

            // Move right till you have an up pointer
            while (r.u === null) {
                r = r.r;
            }
            // Now actually move up
            r = r.u;

            n = new SkipListNode(value);

            // Setting up pointers with the neighbors
            l.r = n;
            r.l = n;
            n.l = l;
            n.r = r;

            // Chaining up with the old node
            old_node.u = n;
            n.d = old_node;

            // For chaining up with the node at the next level
            old_node = n;
        }

        return new_node;
    },

    is_sentinel: function(n) {
	return (n.lm === true) || (n.rm === true);
    },

    delete_node: function(n) {
        // We love our sentinels!
        if (this.is_sentinel(n)) {
            throw new Error('Cannot delete sentinels');
        }

        // Only nodes at the ground level can be deleted (for sanity sake)
        if (n.d !== null) {
            throw new Error('Can only delete nodes at the ground level.');
        }

        while (1) {
            // Have we met Ted? :P
            n.l.r = n.r;
            n.r.l = n.l;
            if (n.u !== null) {
                var upper_node = n.u;
                n = upper_node;
            }
            else {
                break;
            }
        }
    },

    lower_bound: function (t) {
        // We need to demote the sentinels, they are just linking to each other
        while (this.ls.r == this.rs && this.ls.d) {
            // console.log('_demote_sentinels() called');
            this._demote_sentinels();
        }

        // If we have an empty list
        if (this.is_empty()) {
            return null;
        }

        var n = this.root;
        var prev_test_node = n;
        while (1) {
            prev_test_node = n;
            var test_node = n.r;

            // If we haven't defined the less_than function for the test_node, we can't move ahead.
	    assert.ok(test_node.v.leq, "SkipList node missing .leq definition")

            //if (test_node.v.value_str)
            //    console.log(util.format('Test Node: %s, value: %d, leq: %d', test_node.v.value_str(), t.value, test_node.v.leq(t)));

            if (test_node.v.leq(t)) {
                // Sentinel ahead
                if  (test_node.r.rm) {
                    // We cannot go down
                    if (test_node.d === null) {
                        // console.log('Returning right sentinel');
                        return test_node;
                    }
                    // Because we move to the right, when we begin this loop, 
                    // and we want to be at exactly below our current position when we resume
                    n = test_node.d.l;
                }
                else {
                    n = test_node;
                }
            }
            else {
                // At the ground level
                if (n.d == null) {
                    // We cannot go down, test_node is either the desired node, 
                    // or its successor, or if the value is greater than the 
                    // value of the last node, then we return the last element
                    return prev_test_node;
                }
                else {
                    n = n.d;
                }
            }

        }
    }
};

exports.SkipListNode = SkipListNode;
exports.SkipList = SkipList;
