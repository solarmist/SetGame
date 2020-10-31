//
//  CardView.swift
//  Set
//
//  Created by Joshua Olson on 11/15/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

func getColor(from: Card) -> UIColor {
    switch from.color {
        case 0:
            return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        case 1:
            return #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
        default:
            return #colorLiteral(red: 0.3236978054, green: 0.1063579395, blue: 0.574860394, alpha: 1)
    }
}

func getColor(from: Card) -> String {
    switch from.color {
        case 0:
            return "red"
        case 1:
            return "green"
        default:
            return "purple"
    }
}

func getShape(from: Card) -> String {
    var shape: String = ""
    switch from.shape {
        case 0:
            shape += "squiggle"
        case 1:
            shape += "oval"
        default:
            shape += "diamond"
    }
    if from.numShapes > 1 {
        shape += "s"
    }
    return shape
}

func getShading(from: Card) -> String {
    switch from.shading {
        case 0:
            return "empty"
        case 1:
            return "stripping"
        default:
            return "fill"
    }
}


class CardView: UIView {
    public let card: Card  // This is only used for looking up the card in the gameBoard since it is copied by value into the card
    public var borderColor = UIColor.black
    public var gridIndex = 0
    public var isCardSelected: Bool = false {
        didSet {
            print("Changed isCardSelected for Card \(gridIndex) to \(isCardSelected)")
            borderColor = (isCardSelected) ? UIColor.blue: UIColor.black
            setNeedsDisplay()
        }
    }

    // Computed/Read-only
    public var color: UIColor {return getColor(from: card)}
    public var shape: String {return getShape(from: card)}
    public var shading: String {return getShading(from: card)}
    override public var description: String {
        get {
            "Shape: \(getShape(from: card)), Shading: \(getShading(from: card)), Color: \(getColor(from: card)), numShapes: \(card.numShapes)"
        }
    }

    private var lineWidth: CGFloat = 1.5
    private var initialCenter = CGPoint()  // The initial center point of the view.
    private var shapes = [ShapeView]()

    init(_ card: Card) {
        self.card = card
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        isOpaque = false
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        for shapeNum in 1...card.numShapes {
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

        if bounds.width > bounds.height {
            shapeFrame.size.width = shapeFrame.width / CGFloat(card.numShapes)
        } else {
            shapeFrame.size.height = shapeFrame.height / CGFloat(card.numShapes)
        }

        // Place the shapes.
        for (num, shape) in shapes.enumerated() {
            if (num == 0) {
//                print("Card \(gridIndex) shape \(num)'s new bounds: \(shapeFrame)")
            }

            shape.bounds = shapeFrame
            shape.frame.origin = shapeFrame.origin
            shape.bounds.origin = shapeFrame.origin
            shape.setNeedsLayout()
            // The stripes need redraw on layout changes
            shape.setNeedsDisplay()

            // Move the frame for the next shape
            if bounds.width > bounds.height {
                shapeFrame.origin.x += shapeFrame.width
            } else {
                shapeFrame.origin.y += shapeFrame.height
            }
        }
    }

    /**
     Draw the outline of the card and tell the shapes they need to redraw themselves
     */
    override func draw(_ rect: CGRect) {
        let cardBackground = UIBezierPath(
            roundedRect: CGRect(
                x: rect.minX + 1,
                y: rect.minY + 1,
                width: rect.width - 2,
                height: rect.height - 2 ),
            cornerRadius: cornerRadius)

        cardBackground.lineWidth = isCardSelected ? 3.0 : 1.5

        UIColor.white.setFill()
        borderColor.setStroke()

        cardBackground.fill()
        cardBackground.stroke()

        cardBackground.lineWidth = 1.5
        for shape in shapes {
            shape.setNeedsDisplay()
        }
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
