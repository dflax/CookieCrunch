//
//  GameScene.swift
//  CookieCrunch
//
//  Created by Daniel Flax on 4/30/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

	var level: Level!

	let TileWidth: CGFloat = 32.0
	let TileHeight: CGFloat = 36.0

	let gameLayer = SKNode()
	let tilesLayer = SKNode()
	let cookiesLayer = SKNode()

	// To track swipes for cookie moves
	var swipeFromColumn: Int?
	var swipeFromRow: Int?

	// Closure to tell the controller about swipes
	var swipeHandler: ((Swap) -> ())?

	// To handle highlighting during selection
	var selectionSprite = SKSpriteNode()

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder) is not used in this app")
	}

	override init(size: CGSize) {
		super.init(size: size)

		anchorPoint = CGPoint(x: 0.5, y: 0.5)

		let background = SKSpriteNode(imageNamed: "Background")
		addChild(background)

		addChild(gameLayer)

		let layerPosition = CGPoint(
			x: -TileWidth * CGFloat(NumColumns) / 2,
			y: -TileHeight * CGFloat(NumRows) / 2)

		tilesLayer.position = layerPosition
		gameLayer.addChild(tilesLayer)

		cookiesLayer.position = layerPosition
		gameLayer.addChild(cookiesLayer)

		// Initialize the swipe gesture tracking properties
		swipeFromColumn = nil
		swipeFromRow = nil
	}

	// Add the cookies to the scene
	func addSpritesForCookies(cookies: Set<Cookie>) {
		for cookie in cookies {
			let sprite = SKSpriteNode(imageNamed: cookie.cookieType.spriteName)
			sprite.position = pointForColumn(cookie.column, row:cookie.row)
			cookiesLayer.addChild(sprite)
			cookie.sprite = sprite
		}
	}

	// Returns the point to place a tile based on the row/column in the grid
	func pointForColumn(column: Int, row: Int) -> CGPoint {
		return CGPoint(
			x: CGFloat(column)*TileWidth + TileWidth/2,
			y: CGFloat(row)*TileHeight + TileHeight/2)
	}

	// Returns the row/column of a point on the playing grid
	func convertPoint(point: CGPoint) -> (success: Bool, column: Int, row: Int) {
		if point.x >= 0 && point.x < CGFloat(NumColumns)*TileWidth && point.y >= 0 && point.y < CGFloat(NumRows)*TileHeight {
			return (true, Int(point.x / TileWidth), Int(point.y / TileHeight))
		} else {
			return (false, 0, 0)  // invalid location
		}
	}

	// Add tiles to the scene
	func addTiles() {
		for row in 0..<NumRows {
			for column in 0..<NumColumns {
				if let tile = level.tileAtColumn(column, row: row) {
					let tileNode = SKSpriteNode(imageNamed: "Tile")
					tileNode.position = pointForColumn(column, row: row)
					tilesLayer.addChild(tileNode)
				}
			}
		}
	}

	//MARK: - Handle user touches
	// Track where a touch begins - to understand player moves (swipes)
	override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {

		// 1
		let touch = touches.first as! UITouch
		let location = touch.locationInNode(cookiesLayer)

		// 2
		let (success, column, row) = convertPoint(location)
		if success {

			// 3
			if let cookie = level.cookieAtColumn(column, row: row) {

				// Highlight the sprite on the selected cookie
				showSelectionIndicatorForCookie(cookie)

				// 4
				swipeFromColumn = column
				swipeFromRow = row
			}
		}
	}

	// Continue tracking the touch to determine the swipe's direction
	override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {

		// 1
		if swipeFromColumn == nil { return }

		// 2
		let touch = touches.first as! UITouch
		let location = touch.locationInNode(cookiesLayer)

		let (success, column, row) = convertPoint(location)
		if success {

			// 3
			var horzDelta = 0, vertDelta = 0
			if column < swipeFromColumn! {          // swipe left
				horzDelta = -1
			} else if column > swipeFromColumn! {   // swipe right
				horzDelta = 1
			} else if row < swipeFromRow! {         // swipe down
				vertDelta = -1
			} else if row > swipeFromRow! {         // swipe up
				vertDelta = 1
			}

			// 4
			if horzDelta != 0 || vertDelta != 0 {
				trySwapHorizontal(horzDelta, vertical: vertDelta)

				// Hide the highlight on the cookie
				hideSelectionIndicator()

				// 5
				swipeFromColumn = nil
			}
		}
	}

	// For completeness, putting in touchedEnded and touchesCancelled
	override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {

		// In case the user just taps the screen, get rid of the selection of a cookie
		if selectionSprite.parent != nil && swipeFromColumn != nil {
			hideSelectionIndicator()
		}

		swipeFromColumn = nil
		swipeFromRow = nil
	}

	// If touches are cancelled, just call touchesEnded and nill out the values
	override func touchesCancelled(touches: Set<NSObject>, withEvent event: UIEvent) {
		touchesEnded(touches, withEvent: event)
	}


	//MARK: - Handle swapping of cookies and tiles
	// Actually swap the cookies placements
	func trySwapHorizontal(horzDelta: Int, vertical vertDelta: Int) {

		// 1
		let toColumn = swipeFromColumn! + horzDelta
		let toRow = swipeFromRow! + vertDelta

		// 2
		if toColumn < 0 || toColumn >= NumColumns { return }
		if toRow < 0 || toRow >= NumRows { return }

		// 3
		if let toCookie = level.cookieAtColumn(toColumn, row: toRow) {
			if let fromCookie = level.cookieAtColumn(swipeFromColumn!, row: swipeFromRow!) {

				// 4
				println("*** swapping \(fromCookie) with \(toCookie)")
				if let handler = swipeHandler {
					let swap = Swap(cookieA: fromCookie, cookieB: toCookie)
					handler(swap)
				}
			}
		}
	}

	// Animate the swap movement
	func animateSwap(swap: Swap, completion: () -> ()) {
		let spriteA = swap.cookieA.sprite!
		let spriteB = swap.cookieB.sprite!

		spriteA.zPosition = 100
		spriteB.zPosition = 90

		let Duration: NSTimeInterval = 0.3

		let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
		moveA.timingMode = .EaseOut
		spriteA.runAction(moveA, completion: completion)

		let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
		moveB.timingMode = .EaseOut
		spriteB.runAction(moveB)
	}

	// Support highlighting during swap
	func showSelectionIndicatorForCookie(cookie: Cookie) {
		if selectionSprite.parent != nil {
			selectionSprite.removeFromParent()
		}

		if let sprite = cookie.sprite {
			let texture = SKTexture(imageNamed: cookie.cookieType.highlightedSpriteName)
			selectionSprite.size = texture.size()
			selectionSprite.runAction(SKAction.setTexture(texture))

			sprite.addChild(selectionSprite)
			selectionSprite.alpha = 1.0
		}
	}

	// Hide the selection highlight
	func hideSelectionIndicator() {
		selectionSprite.runAction(
			SKAction.sequence([
			SKAction.fadeOutWithDuration(0.3),
				SKAction.removeFromParent()
				])
		)
	}

	// Animate an invalid swap... for fun
	func animateInvalidSwap(swap: Swap, completion: () -> ()) {
		let spriteA = swap.cookieA.sprite!
		let spriteB = swap.cookieB.sprite!

		spriteA.zPosition = 100
		spriteB.zPosition = 90

		let Duration: NSTimeInterval = 0.2

		let moveA = SKAction.moveTo(spriteB.position, duration: Duration)
		moveA.timingMode = .EaseOut

		let moveB = SKAction.moveTo(spriteA.position, duration: Duration)
		moveB.timingMode = .EaseOut

		spriteA.runAction(SKAction.sequence([moveA, moveB]), completion: completion)
		spriteB.runAction(SKAction.sequence([moveB, moveA]))
	}

	// Remove (with animation) matched cookies
	func animateMatchedCookies(chains: Set<Chain>, completion: () -> ()) {
		for chain in chains {
			for cookie in chain.cookies {
				if let sprite = cookie.sprite {
					if sprite.actionForKey("removing") == nil {
						let scaleAction = SKAction.scaleTo(0.1, duration: 0.3)
						scaleAction.timingMode = .EaseOut
						sprite.runAction(SKAction.sequence([scaleAction, SKAction.removeFromParent()]),
							withKey:"removing")
					}
				}
			}
		}
		runAction(matchSound)
		runAction(SKAction.waitForDuration(0.3), completion: completion)
	}


}


