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

	// Properties for scoring
	var movesLeft = 0
	var score = 0

	@IBOutlet weak var targetLabel: UILabel!
	@IBOutlet weak var movesLabel: UILabel!
	@IBOutlet weak var scoreLabel: UILabel!

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

		// Updating HUD
		movesLeft = level.maximumMoves
		score = 0
		updateLabels()

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

		if level.isPossibleSwap(swap) {
			level.performSwap(swap)

			scene.animateSwap(swap, completion: handleMatches)

		} else {
			scene.animateInvalidSwap(swap) {
				self.view.userInteractionEnabled = true
			}
		}
	}

	// Look for matches - chains in either direction
	func handleMatches() {
		let chains = level.removeMatches()
		if chains.count == 0 {
			beginNextTurn()
			return
		}
		scene.animateMatchedCookies(chains) {

			// Update scores
			for chain in chains {
				self.score += chain.score
			}
			self.updateLabels()

			let columns = self.level.fillHoles()
			self.scene.animateFallingCookies(columns) {
				let columns = self.level.topUpCookies()
				self.scene.animateNewCookies(columns) {
					self.handleMatches()
				}
			}
		}
	}

	// Start a new turn by turning back on the user interaction for the layer
	func beginNextTurn() {
		level.detectPossibleSwaps()
		view.userInteractionEnabled = true
	}

	// Update the HUD labels
	func updateLabels() {
		targetLabel.text = String(format: "%ld", level.targetScore)
		movesLabel.text = String(format: "%ld", movesLeft)
		scoreLabel.text = String(format: "%ld", score)
	}


}


