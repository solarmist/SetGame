//
//  ViewController.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

// These are all UI specific
enum Shape: String, CaseIterable {
    // Note: The string values are only temporary until we use drawing to represent the images
    case diamond = "▲"
    case squiggle = "■"
    case oval = "●"
}

enum Shading: Double {
    case open = 0
    case translucent = 0.15
    case solid = 1
}

enum Color {
    case color1// = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    case color2
    case red
}

class ViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet weak var dealButton: UIButton!
    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet weak var newGameButton: UIButton!

    private lazy var game = SetGame()
    private var handSize: Int {
        get {
            cardButtons.filter({!$0.isHidden}).count
        }
    }
    private var maxCards: Int {
        get {
            cardButtons.count
        }
    }

    @IBAction func touchNewGame(_ sender: UIButton) {
        newGame()
        updateViewFromModel()
    }


    @IBAction func touchCard(_ sender: UIButton) {
        let index = cardButtons.firstIndex(of: sender)!
        let numCardsInPlay = game.cardsInPlay.count

        if game.selectCard(at: index) {
            print("Card at index \(index) is \(sender.isCardSelected)")
            sender.isCardSelected = !sender.isCardSelected
        } else if game.cardsSelected.count == 0 {
            print("Hand cleared: Refreshing buttons")
            for card in cardButtons {
                card.isCardSelected = false
            }
        }
//        if game.cardsInPlay.count < numCardsInPlay {
//            // We're in the second half of the game so start consolidating buttons displayed.
//            for button in cardButtons {
//                button.isHidden = true
//            }
//        }
        updateViewFromModel()
    }

    @IBAction func touchDealCards(_ sender: UIButton) {
        guard handSize < maxCards else {
            print("No room for more cards")
            sender.isEnabled = false
            return
        }

        let cards = game.drawCards(numCards: cardsInSet)
        game.cardsInPlay.append(contentsOf: cards)
        if handSize >= maxCards {
            sender.isEnabled = false
        }
        updateViewFromModel()
    }

//    private func updateLabel() {
//        let attributes: [NSAttributedString.Key: Any] = [
//            .strokeWidth: 5.0,
//            .strokeColor: #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1)
//        ]
//        let attributedString = NSAttributedString(string: scoreLabel.text!, attributes: attributes)
//        scoreLabel.attributedText = attributedString
//    }

    override func viewDidLoad() {
        super.viewDidLoad()
        newGameButton.layer.cornerRadius = 8.0
        dealButton.layer.cornerRadius = 8.0
        newGame()
        updateViewFromModel()
    }

    private func newGame(){
        game = SetGame()
        winLabel.isHidden = true
        // Hide all the buttons to begin with.
        for button in cardButtons{
            button.isHidden = true
            button.isCardSelected = false
            button.layer.cornerRadius = 8.0
        }
    }

    private func updateViewFromModel(){
        print("Update score: \(game.score)")
        scoreLabel.text = String(game.score)
        print("Redraw buttons")
        guard game.cardsInPlay.count <= cardButtons.count else {
            print("Too many cards in play \(game.cardsInPlay.count) >= \(cardButtons.count)")
            return
        }
        for (i, card) in game.cardsInPlay.enumerated() {
            cardButtons[i].setAttributedTitle(getCardString(for: card), for: UIControl.State.normal)
            cardButtons[i].isHidden = false

            print(cardButtons[i].setTitle)
        }
        if game.cardsInPlay.count<cardButtons.count {
            for i in game.cardsInPlay.count..<cardButtons.count {
                cardButtons[i].isHidden = true
            }
        }
    }
}

extension UIButton{
    public var isCardSelected: Bool {
        get {
            layer.borderColor == UIColor.blue.cgColor
        }
        set {
            layer.borderColor = newValue ? UIColor.blue.cgColor : UIColor.clear.cgColor
            layer.borderWidth = 3.0
        }
    }

}

func getCardString(for card: Card) -> NSAttributedString {
    var string = ""
    for _ in 1...card.numShapes {
        string += Shape.allCases[card.shape].rawValue
    }
    // Card shading and card color
    // .strokeWidth = <0  filled in
    var color: UIColor
    var alpha: CGFloat = 0.0
    var strokeWidth = 0.0

    switch card.color {
        case 0:
            color = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
        case 1:
            color = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
        case 2:
            color = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        default:
            color = #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1)
    }
    switch card.shading {
        case 0:
            alpha = 1.0
            strokeWidth = -5
        case 1:
            alpha = 0.25
            strokeWidth = -5
        case 2:
            alpha = 1.0
            strokeWidth = 5
        default:
            alpha = 0
    }
    color = color.withAlphaComponent(alpha)
    let attributes: [NSAttributedString.Key: Any] = [
        .strokeColor: color,
        .foregroundColor: color,
        .strokeWidth: strokeWidth,
    ]

    return NSAttributedString(string: string, attributes: attributes)
}
