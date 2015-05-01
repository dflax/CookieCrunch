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
	private var cookies = Array2D<Cookie>(columns: NumColumns, rows: NumRows)

	// Since the cookies array is private, need a way to access the cookies outside the Level
	func cookieAtColumn(column: Int, row: Int) -> Cookie? {
		assert(column >= 0 && column < NumColumns)
		assert(row >= 0 && row < NumRows)
		return cookies[column, row]
	}

}

