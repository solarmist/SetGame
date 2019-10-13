//
//  Card.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import Foundation

struct Card: Equatable {
    let shape: Int
    let shading: Int
    let color: Int
    let count: Int

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.shape == rhs.shape && lhs.shading == rhs.shading && lhs.color == rhs.color && lhs.count == rhs.count
    }

}

func match(cards: [Card], by closure: (Card) -> Int) -> Bool {
    assert(cards.count == 3, "Wrong number of cards")
    let comparisonSet = Set(cards.map(closure))
    return comparisonSet.count == 3 || comparisonSet.count == 1
}
