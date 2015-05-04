//
//  Level.swift
//  CookieCrunch
//
//  Created by Daniel Flax on 5/1/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import Foundation

let NumColumns = 9
let NumRows = 9

class Level {

	// Cookies are the actual items on the board
	private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)

	// Tiles are the slots on the board where the cookies are placed
	private var tiles   = Array2D<Tile>(columns: NumColumns, rows: NumRows)

	// Create a new level
	init(filename: String) {

		// 1
		if let dictionary = Dictionary<String, AnyObject>.loadJSONFromBundle(filename) {

			// 2
			if let tilesArray: AnyObject = dictionary["tiles"] {

				// 3
				for (row, rowArray) in enumerate(tilesArray as! [[Int]]) {

					// 4
					let tileRow = NumRows - row - 1

					// 5
					for (column, value) in enumerate(rowArray) {
						if value == 1 {
							tiles[column, tileRow] = Tile()
						}
					}
				}
			}
		}
	}

	// Since the cookies array is private, need a way to access the cookies outside the Level
	func cookieAtColumn(column: Int, row: Int) -> Cookie? {
		assert(column >= 0 && column < NumColumns)
		assert(row >= 0 && row < NumRows)
		return cookies[column, row]
	}

	func shuffle() -> Set<Cookie> {
		return createInitialCookies()
	}

	private func createInitialCookies() -> Set<Cookie> {
		var set = Set<Cookie>()

		// 1
		for row in 0..<NumRows {
			for column in 0..<NumColumns {

				// If the tile is meant to be filled, put a cookie in there
				if tiles[column, row] != nil {

					// 2
					var cookieType = CookieType.random()

					// 3
					let cookie = Cookie(column: column, row: row, cookieType: cookieType)
					cookies[column, row] = cookie

					// 4
					set.insert(cookie)
				}
			}
		}
		return set
	}

	func tileAtColumn(column: Int, row: Int) -> Tile? {
		assert(column >= 0 && column < NumColumns)
		assert(row >= 0 && row < NumRows)
		return tiles[column, row]
	}

}

