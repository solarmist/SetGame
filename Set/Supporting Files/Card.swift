//
//  Card.swift
//  Concentration
//
//  Created by Joshua Olson on 9/7/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import Foundation


func getColor(from: Card<SetCardFace>) -> String {
    switch from.faceValue.color {
    case .red:
        return "red"
    case .green:
        return "green"
    default:
        return "purple"
    }
}


func getShading(from: Card<SetCardFace>) -> String {
    switch from.faceValue.shading {
    case .empty:
        return "empty"
    case .stripping:
        return "stripping"
    default:
        return "fill"
    }
}

// This is a face for when all you need is a unique value per card for mapping
struct GenericFace: Equatable, Hashable, CustomStringConvertible {
    private static var identifierFactory = 0
    var identifier: Int
    var description: String {"\(identifier)"}

    init() {
       self.identifier = GenericFace.getUniqueIdentifier()
    }

    private static func getUniqueIdentifier() -> Int {
         identifierFactory += 1
         return identifierFactory
     }

    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }

}


let itemsInCategory = 3

struct SetCardFace: Equatable, Hashable, CustomStringConvertible {
    enum Shading: String, CaseIterable {
        case empty = "empty", stripping = "stripping", fill = "fill"
    }
    enum Color: String, CaseIterable {
        case red = "red", green = "green", purple = "purple"
    }
    enum Shape: String, CaseIterable {
        case squiggle = "squiggle", oval = "oval", diamond = "diamond"
    }

    let shading: Shading, color: Color, shape: Shape
    let numShapes: Int

    var description: String {"{Shape: \(shape), Shading: \(shading), Color: \(color), numShapes: \(numShapes)}"}
}


struct Card<FaceType: Equatable & Hashable & CustomStringConvertible>: Equatable, Hashable, CustomStringConvertible {
    var description: String {faceValue.description}

    var faceValue: FaceType
    var isFaceUp = false
    var selected = false

    func hash(into hasher: inout Hasher) {
        faceValue.hash(into: &hasher)
    }

    static func == (lhs: Card<FaceType>, rhs: Card<FaceType>) -> Bool {
        lhs.faceValue == rhs.faceValue
    }

}
