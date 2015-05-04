//
//  Swap.swift
//  CookieCrunch
//
//  Created by Daniel Flax on 5/4/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

struct Swap: Printable {
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