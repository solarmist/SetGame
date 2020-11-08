//
//  CardView.swift
//  Set
//
//  Created by Joshua Olson on 11/15/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit


func getColor(from: Card<SetCardFace>) -> UIColor {
    switch from.faceValue.color {
    case .red:
        return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    case .green:
        return #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
    default:
        return #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
    }
}

class CardView: UIView {
    public let card: Card<SetCardFace>  // This is only used for looking up the card in the gameBoard since it is copied by value into the card
    public var borderColor = UIColor.black
    public var gridIndex = 0
    public var isLandscape: Bool {
        get { bounds.width > bounds.height }
    }
    public var isCardSelected: Bool = false {
        didSet {
            print("Changed isCardSelected for Card \(gridIndex) to \(isCardSelected)")
            borderColor = (isCardSelected) ? UIColor.blue: UIColor.black
            setNeedsDisplay()
        }
    }

    // Computed/Read-only
    public var color: UIColor {return getColor(from: card)}
    public var shape: String {return card.faceValue.shape.rawValue}
    public var shading: String {return card.faceValue.shading.rawValue}
    override public var description: String {card.description}

    private var lineWidth: CGFloat = 1.5
    private var initialCenter = CGPoint()  // The initial center point of the view.
    private var shapes = [ShapeView]()

    init(_ card: Card<SetCardFace>) {
        self.card = card
        super.init(frame: CGRect(x: 0, y: 0, width: 79, height: 110))
        isOpaque = false
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        for shapeNum in 1...card.faceValue.numShapes {
            let shape = ShapeView(card: card, frame: bounds, topEdge: shapeNum == 1)
            shapes.append(shape)
            addSubview(shape)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // Needed for https://www.hackingwithswift.com/example-code/language/how-to-fix-argument-of-selector-refers-to-instance-method-that-is-not-exposed-to-objective-c
    @objc func pan(recognizer: UIPanGestureRecognizer) {
        print("Start pan")
        switch recognizer.state {
            case .changed: fallthrough
            case .ended:
                let translation = recognizer.translation(in: superview)
                print("x: \(translation.x), y: \(translation.y)")
                recognizer.setTranslation(CGPoint.zero, in: superview)
            default: break
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()  // Runs autolayout stuff

        // Split the longest axis into numShapes

        // For 1 shape (even above and below)
        // For 2 shapes (3 spaces, even at top, bottom and middle)
        var shapeFrame = CGRect(origin: bounds.origin, size: bounds.size)

        let xOffset: CGFloat
        let yOffset: CGFloat

        if isLandscape {
            xOffset = shapeFrame.width / CGFloat(card.faceValue.numShapes)
            yOffset = 0
            shapeFrame.size.width = xOffset
        } else {
            xOffset = 0
            yOffset = shapeFrame.height / CGFloat(card.faceValue.numShapes)
            shapeFrame.size.height = yOffset
        }

        // Place the shapes.
        for shape in shapes {
            shape.frame = shapeFrame
            // The stripes need redraw on layout changes
            shape.setNeedsDisplay()
            // Move the frame for the next shape
            shapeFrame.origin.x += xOffset
            shapeFrame.origin.y += yOffset
        }
    }

    /**
     Draw the outline of the card and tell the shapes they need to redraw themselves
     */
    override func draw(_ rect: CGRect) {
        let cardBackground = UIBezierPath(
            roundedRect: CGRect(
                x: bounds.minX + 1,
                y: bounds.minY + 1,
                width: bounds.width - 2,
                height: bounds.height - 2 ),
            cornerRadius: cornerRadius)

        UIColor.white.setFill()
        borderColor.setStroke()
        cardBackground.lineWidth = isCardSelected ? 3.0 : 1.5

        cardBackground.fill()
        cardBackground.stroke()
    }
}

extension CardView {
    private struct SizeRatio {
        static let cornerRadiusToBoundsHeight: CGFloat = 0.1
    }
    private var cornerRadius: CGFloat {
        return bounds.size.height * SizeRatio.cornerRadiusToBoundsHeight
    }

}
