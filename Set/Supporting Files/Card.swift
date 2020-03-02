//
//  Card.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import Foundation

let itemsInCategory = 3

struct Card: Equatable, CustomStringConvertible, Hashable {
    var description: String {
        get {
            "Shape: \(shape), Shading: \(shading), Color: \(color), numShapes: \(numShapes)"
        }
    }

    var selected: Bool = false
    let shape: Int
    let shading: Int
    let color: Int
    let numShapes: Int

    func hash(into hasher: inout Hasher){
        hasher.combine(shape)
        hasher.combine(shading)
        hasher.combine(color)
        hasher.combine(numShapes)
    }

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.shape == rhs.shape && lhs.shading == rhs.shading && lhs.color == rhs.color && lhs.numShapes == rhs.numShapes
    }
}
