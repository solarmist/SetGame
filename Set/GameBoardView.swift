//
//  CardView.swift
//  Set
//
//  Created by Joshua Olson on 11/11/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

@IBDesignable
class GameBoardView: UIView {
    static let cardAspect: CGFloat = 89/64
    static let startingCards = 12
    static let cardsPerDraw = 3
    public var cards = [CardView]()
    private lazy var grid = Grid(layout: Grid.Layout.aspectRatio(GameBoardView.cardAspect), frame: bounds)  // Setup a dummy Grid to start with

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func layoutSubviews() {
        super.layoutSubviews()  // Runs autolayout stuff
        layoutCards()
    }

    public func addCards(_ cards: [Card]) {
        grid.cellCount += cards.count
        print("Adding \(cards.count) to the board")
        for card in cards {
            let cardView = CardView(card)
            self.cards.append(cardView)
            addSubview(cardView)
        }
    }

    public func newGame(cards: [Card]) {
        isOpaque = false
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        self.cards = [CardView]()
        grid.cellCount = GameBoardView.startingCards
        addCards(cards)
        setNeedsLayout()
    }

    private func layoutCards() {
        grid.aspectRatio = 1 / GameBoardView.cardAspect
        print("Set game board aspect: (\(grid.aspectRatio))")
        grid.frame = bounds
        grid.cellCount = cards.count
        for (i, card) in cards.enumerated() {
            let cardLayout = grid[i] ?? CGRect()
            print("Button \(i)'s new bound: \(cardLayout)")

            card.bounds = cardLayout
            card.frame.origin = cardLayout.origin
            card.setNeedsLayout()
        }
    }

}
