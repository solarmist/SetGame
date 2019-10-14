//
//  Set.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import Foundation

let cardsInSet = 3

class SetGame {
    private var cardsRemaining = [Card]()
    private var cardsMatched = [Card]()
    var cardsSelected = [Card]() // Should be 0, 1, 2, or 3
    var score = 0

    init() {
        for shape in 0..<itemsInCategory {
            for color in 0..<itemsInCategory {
                for shading in 0..<itemsInCategory {
                    for numShapes in 0..<itemsInCategory {
                        cardsRemaining.append(Card(shape: shape, shading: shading, color: color, numShapes: numShapes))
                    }
                }
            }
        }
        cardsRemaining.shuffle()
    }

    func selectCard(at index: Int) {
        if cardsSelected.count == cardsInSet {
            if isMatch() {  // We have a match
                for card in cardsSelected {
                    cardsRemaining.remove(at: cardsRemaining.firstIndex(of: card)!)
                    cardsMatched.append(card)
                }
                // Add to score
            } else {  // No match
                // Add to score
                cardsSelected = [Card]()  // Clear currently selected
                cardsSelected.append(cardsRemaining[index])
            }
        } else if let indexOf = cardsSelected.firstIndex(of: cardsRemaining[index]) {
            cardsSelected.remove(at: indexOf)
        } else {
            cardsSelected.append(cardsRemaining[index])
        }
    }

    private func isMatch() -> Bool {
        assert(cardsSelected.count == cardsInSet, "Wrong number of cards")
        var isMatch = true
        let categories: [(Card) -> Int] = [{$0.shape},
                                           {$0.shading},
                                           {$0.color},
                                           {$0.numShapes}]
        for category in categories {
            isMatch = isMatch && isMatchCategory(for:category)
        }
        return isMatch
    }

    /**
     Check if that the cards selected are a match for that category or not

     - Parameter cards: A list of 3 cards to compare
     - Parameter closure:

     - Returns: True if we have a match (all three different or all three the same
     */
    func isMatchCategory(for category: (Card) -> Int) -> Bool {
        assert(cardsSelected.count == cardsInSet, "Wrong number of cards")
        let comparisonSet = Set(cardsSelected.map(category))
        return comparisonSet.count == 3 || comparisonSet.count == 1
    }


}
