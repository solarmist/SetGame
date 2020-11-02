//
//  ViewController.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

// TODO: Swipe to shuffle isn't implemented
// TODO: Draw to re-order isn't working
// TODO: Required: Swipe down should Deal 3 cards
// TODO: Required: Rotation gesture should reshuffle cards

import UIKit

class SetGameViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var gameBoard: GameBoardView!

    private lazy var game = SetGame()

    @IBAction func touchNewGame(_ sender: UIButton) {
        newGame()
        updateViewFromModel()
    }

    @objc func swipeDown(_ gesture: UISwipeGestureRecognizer) {
        print("Swipe detected")
        switch gesture.direction {
        case .down:
            dealCards()
        default:
            break
        }
    }

    @objc func rotate(_ gesture: UIRotationGestureRecognizer) {
        // Rotated at least 66 degrees
        if abs(gesture.rotation) > CGFloat.pi / 3 {
            gameBoard.shuffleCards()
            gesture.rotation = 0
        }
    }

    @objc func touchCard(_ gestureRecognizer: UITapGestureRecognizer) {
        if dealButton.isEnabled && game.deckEmpty {
            print("Disable deal button.")
            dealButton.backgroundColor = UIColor.gray
            dealButton.setTitleColor(UIColor.lightGray, for: .disabled)
            dealButton.isEnabled = false
            dealButton.setNeedsDisplay()
        }
        guard gestureRecognizer.view != nil && gestureRecognizer.state == .ended else { return }

        let cardView = gestureRecognizer.view as! CardView

        guard game.selectCard(cardView.card) else {
            print("No card was selected. Game over or a match was made.")
            if game.gameOver {
                winLabel.isHidden = false
            }
            return
        }
        // Check for matched cards moving out of play
        if let matchedCard = game.lastMatch?[0] {
            if gameBoard.cardViews[matchedCard] != nil {
                print("Removing CardViews ")
                var removedCards = [CardView]()
                // Make them green. Then sleep for a second, remove the views and update them with the new cards.
                for (card, cardView) in gameBoard.cardViews where !game.cardsInPlay.contains(card) {
                    removedCards.append(cardView)
                }

                for card in game.cardsInPlay where (gameBoard.cardViews[card] == nil) {
                    replaceCard(view: removedCards.popLast()!, card: card)
                }
                // When removing cards also remove gaps in the cards
                removedCards.forEach({gameBoard.removeCard(view: $0)})
            }
        }

        for card in game.cardsInPlay where gameBoard.cardViews[card]?.isCardSelected != card.selected {
            print("Updated card \(gameBoard.cardViews[card]!.gridIndex)")
            gameBoard.cardViews[card]?.isCardSelected = card.selected
            gameBoard.cardViews[card]?.setNeedsDisplay()
        }
        updateViewFromModel()
    }

    @IBAction func touchDealCards(_ sender: UIButton) {
        dealCards()
    }

    func dealCards(){
        if dealButton.isEnabled && game.deckEmpty {
            print("Disable deal button.")
            dealButton.backgroundColor = UIColor.gray
            dealButton.setTitleColor(UIColor.lightGray, for: .disabled)
            dealButton.isEnabled = false
            dealButton.setNeedsDisplay()
        }
        let cards = game.drawCards(cardsInSet)
        for card in cards {
            setupNewCard(card)
        }
        for (_, view) in gameBoard.cardViews {
            view.setNeedsLayout()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(SetGameViewController.swipeDown))
        swipe.direction = .down
        swipe.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipe)

        let rotate = UIRotationGestureRecognizer(target: self, action: #selector(SetGameViewController.rotate))
        self.view.addGestureRecognizer(rotate)

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
    private func replaceCard(view: CardView, card: Card) {
        let tapGestureRecognizer = UITapGestureRecognizer(
            target: self, action: #selector(SetGameViewController.touchCard))
        tapGestureRecognizer.numberOfTouchesRequired = 1
        tapGestureRecognizer.numberOfTapsRequired = 1

        gameBoard.replaceCard(view: view, card: card, tapGestureRecognizer: tapGestureRecognizer)
    }


    private func newGame(){
        gameBoard.newGame()
        game = SetGame()

        print("Enable deal button.")
        dealButton.backgroundColor = UIColor.systemBlue
        dealButton.setTitleColor(UIColor.white, for: .normal)
        dealButton.isEnabled = true
        dealButton.setNeedsDisplay()

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
