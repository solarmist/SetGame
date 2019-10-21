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
    var cardsInPlay = [Card]()
    private var deck = [Card]()
    private var cardsMatched = [Card]()
    let totalCards = 81
    var cardsDrawn = 12
    var cardsSelected = [Card]() // Should be 0, 1, 2, or 3
    var score = 0

    init() {
        for shape in 0..<itemsInCategory {
            for color in 0..<itemsInCategory {
                for shading in 0..<itemsInCategory {
                    for numShapes in 0..<itemsInCategory {
                        deck.append(Card(shape: shape, shading: shading, color: color, numShapes: numShapes))
                    }
                }
            }
        }
        deck.shuffle()
        for _ in 0..<cardsDrawn {
            drawCard()  // We don't need the cards back when setting up the game
        }
    }

    /**
    Returns a single card from the deck if possible
     If cardsInSet number of cards are already selected and they select a new card check if the three cards are a match.

    - Returns: A card.  nil if no cards remaining
    */
    @discardableResult private func drawCard() -> Card? {
        guard deck.count >= 1 else {
            print("No cards remaining")
            return nil
        }

        let card = deck.popLast()!
        cardsInPlay.append(card)
        return card
    }

    /**
    Adds or removes a card to the currently selected cards.
     If cardsInSet number of cards are already selected and they select a new card check if the three cards are a match.

    - Parameter numCards: The index of the cards to be drawn from the deck

    - Returns: An array of cards drawn.  If there aren't enough cards returns nil
    */
    @discardableResult func drawCards(numCards: Int = cardsInSet) -> [Card]? {
        guard numCards <= deck.count else {
            print("Too few cards remaining. Cannot draw \(numCards) out of \(deck.count)")
            return nil
        }

        var cards = [Card]()
        cardsDrawn += numCards
        for _ in 1...numCards {
            cards.append(drawCard()!)
        }
        return cards
    }

    func selectCard(card: Card) {
        guard let cardIndex = cardsInPlay.firstIndex(of: card) else {
            print("You've selected a card that has not yet been drawn.")
            return
        }
        return selectCard(at: cardIndex)
    }

    /**
    Adds or removes a card to the currently selected cards.
     If cardsInSet number of cards are already selected and they select a new card check if the three cards are a match.

    - Parameter index: The index of the card selected
    */
    func selectCard(at index: Int) {
        guard index < cardsInPlay.count else {
            print("You've selected a card that has not yet been drawn.")
            return
        }

        if cardsSelected.count == cardsInSet, cardsSelected.contains(deck[index]) {
            // The user has a set selected and chose one of the cards already selected.  Do nothing.
            return
        } else if cardsSelected.count == cardsInSet {  // Check for a set
            if isMatch() {  // We have a match
                for card in cardsSelected {
                    deck.remove(at: deck.firstIndex(of: card)!)
                    cardsMatched.append(card)
                }
                // Draw new cards to replace the matched cards
                if deck.count > 0 {
                    drawCards(numCards: min(cardsInSet, deck.count))
                }
                if deck.count == 0 && cardsInPlay.count == 0 {
                    print("You win")
                    return
                }

                // TODO: Add to score
            } else {  // No match
                // TODO: Add to score
            }
            cardsSelected = [Card]()  // Clear currently selected
        }

        if let indexOf = cardsSelected.firstIndex(of: deck[index]) {
            // Selected an already selected card, so unselect.
            cardsSelected.remove(at: indexOf)
        } else {
            cardsSelected.append(deck[index])
        }
    }

    /**
    Check if that the cards selected are a match across all categories

    - Returns: True if we have a match (all three different or all three the same
    */
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

     - Parameter closure: A closure that returns the category being checked

     - Returns: True if we have a match for a single category
     */
    private func isMatchCategory(for category: (Card) -> Int) -> Bool {
        assert(cardsSelected.count == cardsInSet, "Wrong number of cards")
        let comparisonSet = Set(cardsSelected.map(category))
        return comparisonSet.count == 3 || comparisonSet.count == 1
    }


}
