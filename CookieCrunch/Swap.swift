//
//  Swap.swift
//  CookieCrunch
//
//  Created by Daniel Flax on 5/4/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

func ==(lhs: Swap, rhs: Swap) -> Bool {
	return (lhs.cookieA == rhs.cookieA && lhs.cookieB == rhs.cookieB) ||
		(lhs.cookieB == rhs.cookieA && lhs.cookieA == rhs.cookieB)
}

struct Swap: Printable, Hashable {

	var hashValue: Int {
		return cookieA.hashValue ^ cookieB.hashValue
	}

	let cookieA: Cookie
	let cookieB: Cookie
 
	init(cookieA: Cookie, cookieB: Cookie) {
		self.cookieA = cookieA
		self.cookieB = cookieB
	}
 
	var description: String {
		return "swap \(cookieA) with \(cookieB)"
	}
}