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
    public var cardViews: [Card: CardView] = [:]

    private lazy var grid = Grid(layout: Grid.Layout.aspectRatio(GameBoardView.cardAspect), frame: bounds)  // Setup a dummy Grid to start with

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func layoutSubviews() {
        super.layoutSubviews()  // Runs autolayout stuff
        layoutCards()
    }

    /**
     Register cards in the view and add the `tapGestureRecognizer` to it and place it on the board.
     */
    public func registerCard(card: Card, tapGestureRecognizer: UITapGestureRecognizer) {
        guard cardViews[card] == nil else {
            return
        }
        let newCardView = CardView(card)
        newCardView.gridIndex = grid.cellCount
        newCardView.addGestureRecognizer(tapGestureRecognizer)

        grid.cellCount += 1
        addSubview(newCardView)
        print("Registered card: \(card) at index \(newCardView.gridIndex)")
        cardViews[card] = newCardView
    }

    public func newGame() {
        isOpaque = false
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        cardViews = [:]
        grid.cellCount = 0
        setNeedsLayout()
    }

    /**
     Use the `grid` to determine the size and layout of the cards on the board.
     This function changes the `card.bounds` and `card.frame` and sets needs layout on each card.
     */
    private func layoutCards() {
        grid.aspectRatio = 1 / GameBoardView.cardAspect
        print("Set game board aspect: (\(grid.aspectRatio))")
        grid.frame = bounds
        for (_, cardView) in cardViews {
//            print("Card \(cardView.gridIndex)'s new bounds: \(cardLayout)")
            let cardLayout = grid[cardView.gridIndex] ?? CGRect()

            cardView.bounds = cardLayout
            cardView.frame.origin = cardLayout.origin
            cardView.bounds.origin = cardLayout.origin
            cardView.setNeedsLayout()
        }
    }

}
