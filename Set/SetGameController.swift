//
//  ViewController.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

class SetGameController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var gameBoard: GameBoardView!

    private lazy var game = SetGame()
    private var buttonsSelected = [UIButton]()

    @IBAction func touchNewGame(_ sender: UIButton) {
        newGame()
        updateViewFromModel()
    }

//    @IBAction func touchCard(_ sender: UIButton) {
//        let index = gameBoard.cardButtons.firstIndex(of: sender)
//
//        if game.cardsSelected.count == cardsInSet {
//            print("Hand cleared: Refreshing buttons")
//            for card in buttonsSelected {
//                card.isCardSelected = false
//            }
//            buttonsSelected = []
//        }
//
//        if game.selectCard(at: index) {
//            print("Card at index \(index) is \(sender.isCardSelected)")
//            sender.isCardSelected = !sender.isCardSelected  // Toggle button
//            if !sender.isCardSelected {
//                buttonsSelected.remove(at: buttonsSelected.firstIndex(of: sender)!)
//            } else {
//                buttonsSelected.append(sender)
//            }
//        }
//        if game.gameOver {
//            winLabel.isHidden = false
//        }
//
//        if game.cardsSelected.count == cardsInSet {
//            for button in buttonsSelected {
//                button.layer.borderColor = game.isMatch ? UIColor.green.cgColor : UIColor.red.cgColor
//            }
//        }
//        updateViewFromModel()
//    }

    @IBAction func touchDealCards(_ sender: UIButton) {

        let cards = game.drawCards(numCards: cardsInSet)
        game.cardsInPlay.append(contentsOf: cards)
        gameBoard.addCards(cards)
        updateViewFromModel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        newGameButton.layer.cornerRadius = 8.0
        dealButton.layer.cornerRadius = 8.0
        newGame()
        updateViewFromModel()
    }

    private func newGame(){
        game = SetGame()
        gameBoard.newGame(cards: game.cardsInPlay)
        winLabel.isHidden = true
        // clear the buttons from the board

    }

    private func updateViewFromModel(){
        print("Update score: \(game.score)")
        scoreLabel.text = String(game.score)
        print("Redraw buttons")

        guard game.cardsInPlay.count <= gameBoard.cards.count else {
            print("Too many cards in play \(game.cardsInPlay.count) >= \(gameBoard.cards.count)")
            return
        }
    }
}
