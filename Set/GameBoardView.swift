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
    public var cardViews: [Card<SetCardFace>: CardView] = [:]
    public var deckLocation = CGPoint(x: 0, y: 0)
    public var discardLocation = CGPoint(x: 0, y: 0)
    private lazy var grid : Grid = {
        var newGrid = Grid(layout: Grid.Layout.aspectRatio(GameBoardView.cardAspect), frame: frame)  // Setup a dummy Grid to start with
        return newGrid
    }()

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func layoutSubviews() {
        super.layoutSubviews()  // Runs autolayout stuff
        layoutCards()
    }

    /**
     Register cards in the view and add the `tapGestureRecognizer` to it and place it on the board.
     */
    public func registerCard(card: Card<SetCardFace>, tapGestureRecognizer: UITapGestureRecognizer) {
        guard cardViews[card] == nil else {
            return
        }
        let newCardView = CardView(card)
        newCardView.gridIndex = grid.cellCount
        newCardView.addGestureRecognizer(tapGestureRecognizer)

        grid.cellCount += 1
        newCardView.frame.origin = deckLocation
        addSubview(newCardView)
        print("Registered card: \(card) at index \(newCardView.gridIndex)")
        cardViews[card] = newCardView
    }

    public func shuffleCards() {
        for (i, (card, view)) in cardViews.shuffled().enumerated() {
            print("Card \(card) is now at index \(i)")
            view.gridIndex = i
        }
        self.setNeedsLayout()
        self.setNeedsDisplay()
    }

    /**
     Remove cards in the view with a new card and add the `tapGestureRecognizer` to it and place it on the board.
     */
    public func removeCard(view: CardView) {
        view.removeFromSuperview()
        cardViews.removeValue(forKey: view.card)
        grid.cellCount -= 1
        for (i, (card, view)) in cardViews.enumerated() {
            print("Card \(card) is at index \(i)")
            view.gridIndex = i
        }
    }
    /**
     Replace cards in the view with a new card and add the `tapGestureRecognizer` to it and place it on the board.
     */
    public func replaceCard(view: CardView, card: Card<SetCardFace>, tapGestureRecognizer: UITapGestureRecognizer) {
        guard cardViews[view.card] != nil else {
            return
        }
        view.removeFromSuperview()

        cardViews.removeValue(forKey: view.card)

        let newCardView = CardView(card)
        newCardView.gridIndex = view.gridIndex
        newCardView.addGestureRecognizer(tapGestureRecognizer)

        addSubview(newCardView)
        print("Replaced card: \(card) at index \(newCardView.gridIndex)")
        cardViews[card] = newCardView
    }

    public func newGame() {
        isOpaque = false
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        // Clear any remaining cards from the view
        cardViews.values.forEach({$0.removeFromSuperview()})

        cardViews = [:]
        grid.cellCount = 0
        grid.aspectRatio = 1 / GameBoardView.cardAspect
        print("Set game board aspect: (\(grid.aspectRatio))")
        setNeedsLayout()
    }

    /**
     Use the `grid` to determine the size and layout of the cards on the board.
     This function changes the `card.bounds` and `card.frame` and sets needs layout on each card.
     */
    private func layoutCards() {
        grid.frame = bounds
        for (_, cardView) in cardViews {
            let cardLayout = grid[cardView.gridIndex] ?? CGRect()

            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: 1.0,
                delay: 0.0,
                options: [.allowUserInteraction],
                animations: {cardView.frame = cardLayout},
                completion: {_ in })

            cardView.setNeedsLayout()
        }
    }

}
