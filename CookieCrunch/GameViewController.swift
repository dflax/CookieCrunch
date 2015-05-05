//
//  GameViewController.swift
//  CookieCrunch
//
//  Created by Daniel Flax on 4/30/15.
//  Copyright (c) 2015 Daniel Flax. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
	var scene: GameScene!
	var level: Level!

	override func prefersStatusBarHidden() -> Bool {
		return true
	}

	override func shouldAutorotate() -> Bool {
		return true
	}

	override func supportedInterfaceOrientations() -> Int {
		return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
	}
 
	override func viewDidLoad() {
		super.viewDidLoad()

		// Configure the view
		let skView = view as! SKView
		skView.multipleTouchEnabled = false

		// Create and configure the scene.
		scene = GameScene(size: skView.bounds.size)
		scene.scaleMode = .AspectFill

		// Create the Level - start with level 1
		level = Level(filename: "Level_1")
		scene.level = level

		// Add the tiles to the scene
		scene.addTiles()

		// Handle swaps
		scene.swipeHandler = handleSwipe

		// Present the scene.
		skView.presentScene(scene)

		// Begin the game itself
		beginGame()

	}

	// Start the game
	func beginGame() {
		shuffle()
	}

	// shuffle the board (or start from scratch)
	func shuffle() {
		let newCookies = level.shuffle()
		scene.addSpritesForCookies(newCookies)
	}

	// Handle when someone swipes to move pieces
	func handleSwipe(swap: Swap) {
		view.userInteractionEnabled = false

		level.performSwap(swap)

		scene.animateSwap(swap) {
			self.view.userInteractionEnabled = true
		}
	}

}

