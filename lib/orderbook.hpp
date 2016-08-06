#include <stdint.h>
#include <vector>
#include <set>

#define UINT64_MAX ((uint64_t)(-1))

struct order {
	uint64_t order_id;
	uint64_t price;
	uint64_t original_volume;
	uint64_t remaining_volume;
	bool isAsk;

	order (uint64_t oi, uint64_t p, uint64_t ov, uint64_t rv, bool ia) {
		order_id = oi;
		price = p;
		original_volume = ov;
		remaining_volume = rv;
		isAsk = ia;
	}
};


struct askcomp {
	bool operator () (const order & lhs, const order & rhs) {
		if (lhs.price < rhs.price)
			return true;
		else if (lhs.price == rhs.price && lhs.order_id < rhs.order_id)
			return true;
		return false;
	}
};


struct bidcomp {
	bool operator () (const order & lhs, const order & rhs) {
		if (lhs.price > rhs.price)
			return true;
		else if (lhs.price == rhs.price && lhs.order_id > rhs.order_id)
			return true;
		return false;
	}
};

struct match {
	uint64_t passive_order_id;
	uint64_t active_order_id;

	bool passive_ask;

	uint64_t volume;
	uint64_t price;

	match(uint64_t poid, uint64_t aoid, bool pa, uint64_t v, uint64_t p) {
		passive_order_id = poid;
		active_order_id = aoid;
		passive_ask = pa;
		volume = v;
		price = p;
	}
};


class orderbook {
private:

	// May seem strange to use set, but experimental testing verifies that it is faster than priority queue.
	std::set<order,askcomp> asks;
	std::set<order,bidcomp> bids;
	uint64_t id_counter;


	template <class S, class T>
	std::vector<match> create_limit_order_internal (order ord, std::set<order,S> & lookForMatchesIn, std::set<order,T> & insertIn) {
		std::vector<match> matches;

		while (true) {
			if (lookForMatchesIn.empty ())
				break;
			if (ord.remaining_volume == 0)
				return matches;

			// To prevent noobs from fucking up, std::set returns constant iterators.
			// Since my modification doesn't change ordering this little breach of contract should be cool
			order & best = const_cast<order &>( *lookForMatchesIn.begin());

			if ((ord.isAsk 	&& ord.price > best.price) ||
				(!ord.isAsk && ord.price < best.price))
				break;

			uint64_t vol;
			if (best.remaining_volume > ord.remaining_volume) {
				vol = ord.remaining_volume;
				best.remaining_volume -= vol;
				ord.remaining_volume = 0;
			} else {
				vol = best.remaining_volume;
				ord.remaining_volume -= vol;

				//lookForMatchesIn.pop ();
			}
			match m (best.order_id, ord.order_id, best.isAsk, vol,
					best.price); // Execute at the price of the order in the book
			matches.push_back(m);
		}
		if (ord.remaining_volume != 0  // Completely filled already
				&& ord.price != 0 && ord.price != UINT64_MAX  // price = 0 or price = MAX indicates market order. If we ate every order in the book, this is a good time to give up
				)
			insertIn.insert(ord);
		return matches;
	}
public:

	orderbook():id_counter(0){
	}
	std::vector<match> limit_order (uint64_t price, uint64_t volume, bool isAsk) {
		order ord(id_counter++, price, volume, volume, isAsk);
		if (ord.isAsk)
			return create_limit_order_internal (ord, bids, asks);
		else
			return create_limit_order_internal (ord, asks, bids);
	}

	std::vector<match> market_order (uint64_t vol, bool isAsk) {
		return limit_order (isAsk?0:UINT64_MAX, vol, isAsk);
	}
};
