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
    var deckEmpty: Bool {
        get {
            return deck.count == 0
        }
    }
    var lastMatch: [Card]? {
        get {
            return (cardsMatched.count >= cardsInSet) ? cardsMatched.suffix(cardsInSet) : nil
        }
    }
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
    let totalCards = 3 * 3 * 3 * 3 // num shapes * num colors * num shadings * num symbols on card
    var cardsDrawn = 12
    var cardsSelected = [Card]() // Should be 0, 1, 2, or 3
    var score = 0
    var gameOver: Bool {deck.count == 0 && cardsInPlay.count == 0}
    var isFullHand: Bool {cardsSelected.count == cardsInSet}
    var isMatch : Bool {isFullHand && checkIsMatch()}

    init() {
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
        print("Dealing card")
        cardsInPlay.append(card)
        return card
    }

    /**
     Adds or removes a card to the currently selected cards.
     If cardsInSet number of cards are already selected and they select a new card check if the three cards are a match.

     - Parameter numCards: The index of the cards to be drawn from the deck

     - Returns: An array of cards drawn.  If there aren't enough cards returns nil
    */
    @discardableResult func drawCards(_ numCards: Int = cardsInSet) -> [Card] {
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


    @discardableResult func selectCard(_ card: Card) -> Bool {
        if isFullHand {
            processHand()
        }

        guard let cardIndex = cardsInPlay.firstIndex(of: card) else { return false }
        return selectCard(at: cardIndex)
    }

    /**
     Adds or removes a card to the currently selected cards.
     If cardsInSet number of cards are already selected and they select a new card check if the three cards are a match.

     - Parameter at: Choose the card at this index

     - Returns: true if a card was sucessfully selected, false otherwise
    */
    @discardableResult func selectCard(at index: Int) -> Bool {

        guard index < cardsInPlay.count || !gameOver  else {
            if gameOver {
                print("You win")
                score += 100
            }
            return false
        }

        // We know we have a card in play that we want to do something with
        cardsInPlay[index].selected = !cardsInPlay[index].selected
        let card = cardsInPlay[index]

        if let indexInHand = cardsSelected.firstIndex(of: card) {
            cardsSelected.remove(at: indexInHand)
        } else {
            cardsSelected.append(card)
        }
        // If the card was in a previous hand we don't care about .selected anymore so this is safe.

        if isMatch {
            print("Found a match")
            score += 10
        } else if isFullHand {
            score -= 1
            print("No match")
        }
        return true
    }


    /**
     Handles updating the deck after a match.  Cards are moved from `SetGame.cardsInPlay` to `SetGame.cardsMatched`
     */
    private func processHand() {
        let drewCards: Bool
        for (i, _) in cardsInPlay.enumerated() {
            cardsInPlay[i].selected = false
        }

        // Remove the matched cards from play
        if isMatch {
            drewCards = drawCards(min(cardsInSet, deck.count)).count > 0

            for card in cardsSelected {
                let index = cardsInPlay.firstIndex(of: card)!
                cardsMatched.append(card)
                cardsInPlay.remove(at: index)
                if drewCards, let newCard = cardsInPlay.popLast() {
                    // New cards were added at the end of the array
                    print("Replaced card \(card) in play with \(newCard)")
                    cardsInPlay.insert(newCard, at: index)
                }
            }
        }
        cardsSelected = [Card]()  // Clear current hand
    }
    /**
     Check if that the cards selected are a match across all categories

     - Returns: True if we have a match (all three different or all three the same) for each category.
    */
    private func checkIsMatch() -> Bool {
        assert(cardsSelected.count == cardsInSet, "Wrong number of cards")
        var isMatch = true
        // The cards need to either be identical or completely different for each category
        let categories: [(String, (Card) -> Int)] = [("Shape", {$0.shape}),
                                                     ("Shading", {$0.shading}),
                                                     ("Color", {$0.color}),
                                                     ("Number of shapes", {$0.numShapes})]
        for (_, category) in categories {
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
        guard cardsSelected.count == cardsInSet else {
            print("Wrong number of cards selected.")
            return false
        }
        let comparisonSet = Set(cardsSelected.map(category))
        return comparisonSet.count == 3 || comparisonSet.count == 1
    }


}
