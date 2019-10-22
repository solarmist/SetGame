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
    @IBOutlet weak var winLabel: UILabel!
    @IBOutlet var cardButtons: [UIButton]!
    @IBOutlet weak var newGameButton: UIButton!
    @IBAction func selectCard(_ sender: UIButton) {
    }

    private lazy var game = SetGame()

    override func viewDidLoad() {
        super.viewDidLoad()
        newGameButton.layer.cornerRadius = 8.0
        winLabel.isHidden = true
        // Hide all the buttons to begin with.
        for button in cardButtons{
            button.isHidden = true
            button.layer.cornerRadius = 8.0
        }

        // Do any additional setup after loading the view.
        updateViewFromModel()
    }


    func updateViewFromModel(){
        for (i, card) in game.cardsInPlay.enumerated() {
            cardButtons[i].isHidden = false
            cardButtons[i].setAttributedTitle(getCardString(for: card), for: UIControl.State.normal)


            print(cardButtons[i].setTitle)
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
    let attributes: [NSAttributedString.Key: Any] = [
        .strokeColor: color,
        .foregroundColor: color,
        .strokeWidth: card.shading - 1,
    ]

    return NSAttributedString(string: string, attributes: attributes)

}
