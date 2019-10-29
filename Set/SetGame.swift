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
    private var deck: [Card] = {
        var tempDeck = [Card]()
        for shape in 0..<itemsInCategory {
            for color in 0..<itemsInCategory {
                for shading in 0..<itemsInCategory {
                    for numShapes in 1...itemsInCategory {
                        tempDeck.append(Card(shape: shape, shading: shading, color: color, numShapes: numShapes))
                    }
                }
            }
        }
        return tempDeck
    }()
    private var cardsMatched = [Card]()
    let totalCards = 81
    var cardsDrawn = 12
    var cardsSelected = [Card]() // Should be 0, 1, 2, or 3
    var score = 0

    init() {
        deck.shuffle()
        for _ in 0..<cardsDrawn {
            let card = drawCard()!  // We don't need the cards back when setting up the game
            cardsInPlay.append(card)
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

        return deck.popLast()!
    }

    /**
    Adds or removes a card to the currently selected cards.
     If cardsInSet number of cards are already selected and they select a new card check if the three cards are a match.

    - Parameter numCards: The index of the cards to be drawn from the deck

    - Returns: An array of cards drawn.  If there aren't enough cards returns nil
    */
    @discardableResult func drawCards(numCards: Int = cardsInSet) -> [Card] {
        guard numCards <= deck.count, numCards != 0 else {
            print("Too few cards remaining. Cannot draw \(numCards) out of \(deck.count)")
            return []
        }

        var cards = [Card]()
        cardsDrawn += numCards
        for _ in 1...numCards {
            cards.append(drawCard()!)
        }
        return cards
    }

    func selectCard(card: Card) -> Bool {
        guard let cardIndex = cardsInPlay.firstIndex(of: card) else {
            print("You've selected a card that has not yet been drawn.")
            return false
        }
        return selectCard(at: cardIndex)
    }

    /**
    Adds or removes a card to the currently selected cards.
     If cardsInSet number of cards are already selected and they select a new card check if the three cards are a match.

    - Parameter index: The index of the card selected

    - Returns: true if a card was sucessfully selected, false otherwise
    */
    func selectCard(at index: Int) -> Bool {
        guard index < cardsInPlay.count else {
            print("You've selected a card that has not yet been drawn.")
            return false
        }

        if cardsSelected.count == cardsInSet, cardsSelected.contains(cardsInPlay[index]) {
            // The user has a set selected and chose one of the cards already selected.  Do nothing.
            return false
        } else if cardsSelected.count == cardsInSet {  // Check for a set
            if isMatch() {  // We have a match
                print("Found a match")
                // Draw new cards to replace the ones just matched
                var newCards = drawCards(numCards: min(cardsInSet, deck.count))
                for card in cardsSelected {
                    let index = cardsInPlay.firstIndex(of: card)!
                    print("\(index)")
                    if let newCard = newCards.popLast() {
                        print("Replace card")
                        cardsInPlay[index] = newCard
                    } else {
                        print("Remove card")
                        cardsInPlay.remove(at: index)
                    }
                    cardsMatched.append(card)
                }
                if deck.count == 0, cardsInPlay.count == 0 {
                    print("You win")
                    score += 100
                    return false
                }
                score += 10
                // TODO: Add to score
            } else {  // No match
                print("No match")
                score -= 1
                // TODO: Add to score
                for card in cardsSelected {
                    print("Card: \(card)")
                }
            }
            cardsSelected = [Card]()  // Clear currently selected
            return false
        }

        if let indexOf = cardsSelected.firstIndex(of: cardsInPlay[index]) {
            // Selected an already selected card, so unselect.
            cardsSelected.remove(at: indexOf)
        } else {
            cardsSelected.append(cardsInPlay[index])
        }
        print("Selected card")
        return true
    }

    /**
    Check if that the cards selected are a match across all categories

    - Returns: True if we have a match (all three different or all three the same
    */
    private func isMatch() -> Bool {
        assert(cardsSelected.count == cardsInSet, "Wrong number of cards")
        var isMatch = true
        let categories: [(String, (Card) -> Int)] = [("Shape", {$0.shape}),
                                                     ("Shading", {$0.shading}),
                                                     ("Color", {$0.color}),
                                                     ("Number of shapes", {$0.numShapes})]
        for (catName, category) in categories {
            let catMatch = isMatchCategory(for:category)
            print("\(catName) is a match: \(catMatch)")
            isMatch = isMatch && catMatch
        }
        return isMatch
    }

    /**
     Check if that the cards selected are a match for that category or not

     - Parameter closure: A closure that returns the category being checked

     - Returns: True if we have a match for a single category
     */
    private func isMatchCategory(for category: (Card) -> Int) -> Bool {
        guard cardsSelected.count == cardsInSet else {
            print("Wrong number of cards selected.")
            return false
        }
        let comparisonSet = Set(cardsSelected.map(category))
        return comparisonSet.count == 3 || comparisonSet.count == 1
    }


}
