//
//  Cookie.swift
//  CookieCrunch
//
//  Created by Daniel Flax on 4/30/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import SpriteKit

enum CookieType: Int, Printable {

	case Unknown = 0, Croissant, Cupcake, Danish, Donut, Macaroon, SugarCookie

	var spriteName: String {
		let spriteNames = [
			"Croissant",
			"Cupcake",
			"Danish",
			"Donut",
			"Macaroon",
			"SugarCookie"]

		return spriteNames[rawValue - 1]
	}

	var highlightedSpriteName: String {
		return spriteName + "-Highlighted"
	}

	static func random() -> CookieType {
		return CookieType(rawValue: Int(arc4random_uniform(6)) + 1)!
	}

	// To conform to the Printable protocol
	var description: String {
		return spriteName
	}

}

func ==(lhs: Cookie, rhs: Cookie) -> Bool {
	return lhs.column == rhs.column && lhs.row == rhs.row
}

class Cookie: Printable, Hashable {

	// To conform to the Printable protocol
	var description: String {
		return "type:\(cookieType) square:(\(column),\(row))"
	}

	var column: Int
	var row: Int
	let cookieType: CookieType
	var sprite: SKSpriteNode?

	// To conform to the Hashable protocol (required for Set<Cookie> usage)
	var hashValue: Int {
		return row*10 + column
	}

	init(column: Int, row: Int, cookieType: CookieType) {
		self.column = column
		self.row = row
		self.cookieType = cookieType
	}

}

