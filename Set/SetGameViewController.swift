//
//  ViewController.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

// TODO: A match should remove the cards from the board
// TODO: Card selection isn't working correctly.
// TODO: Full hand highlighting is not working
// TODO: Swipe to shuffle isn't implemented
// TODO: Draw to re-order isn't working
// TODO: touchCard should have methods that keep track of the states


import UIKit

class SetGameViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var gameBoard: GameBoardView! {
        didSet {
            for (_, cardView) in gameBoard.cardViews {
                let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(CardView.pan(recognizer:)))
                cardView.addGestureRecognizer(panGestureRecognizer)
            }
        }
    }

    private lazy var game = SetGame()

    @IBAction func touchNewGame(_ sender: UIButton) {
        newGame()
        updateViewFromModel()
    }

    @objc func touchCard(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.view != nil && gestureRecognizer.state == .ended else { return }

        let cardView = gestureRecognizer.view as! CardView
        let card = cardView.card

        guard game.selectCard(card) else {
            print("No card was selected. Nothing to do.")
            if game.gameOver {
                winLabel.isHidden = false
            }
            return
        }

        for card in game.cardsInPlay {
            gameBoard.cardViews[card]?.isCardSelected = card.selected
            gameBoard.cardViews[card]?.setNeedsDisplay()
        }
        updateViewFromModel()
    }

    @IBAction func touchDealCards(_ sender: UIButton) {
        let cards = game.drawCards(cardsInSet)
        for card in cards {
            setupNewCard(card)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        newGameButton.layer.cornerRadius = 8.0
        dealButton.layer.cornerRadius = 8.0
        newGame()
        updateViewFromModel()
    }

    /**
     Build the card view, setup the tap gesture and add it to the `gameBoard`.

     - Parameter card: the card to be registered
     */
    private func setupNewCard(_ card: Card) {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(SetGameViewController.touchCard))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1

        gameBoard.registerCard(card: card, tapGestureRecognizer: tapGestureRecognizer)
    }

    private func newGame(){
        gameBoard.newGame()
        game = SetGame()

        for card in game.cardsInPlay {
            print("Adding cardView \(gameBoard.cardViews.count)")
            setupNewCard(card)
        }

        winLabel.isHidden = true
        // clear the buttons from the board
    }

    private func updateViewFromModel(){
        print("Update score: \(game.score)")
        scoreLabel.text = String(game.score)
        print("Redraw buttons")

        guard game.cardsInPlay.count <= gameBoard.cardViews.count else {
            print("Too many cards in play \(game.cardsInPlay.count) >= \(gameBoard.cardViews.count)")
            return
        }
    }
}
