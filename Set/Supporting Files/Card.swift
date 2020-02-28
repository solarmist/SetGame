//
//  Card.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import Foundation

let itemsInCategory = 3

struct Card: Equatable, CustomStringConvertible {
    var description: String {
        get {
            "Shape: \(shape), Shading: \(shading), Color: \(color), numShapes: \(numShapes)"
        }
    }

    let shape: Int
    let shading: Int
    let color: Int
    let numShapes: Int

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.shape == rhs.shape && lhs.shading == rhs.shading && lhs.color == rhs.color && lhs.numShapes == rhs.numShapes
    }
}
