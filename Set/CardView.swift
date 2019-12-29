//
//  CardView.swift
//  Set
//
//  Created by Joshua Olson on 11/15/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

class CardView: UIView {
    public let card: Card?
    public var isCardSelected: Bool {
        get {layer.borderColor == UIColor.blue.cgColor}
        set {layer.borderColor = newValue ? UIColor.blue.cgColor : UIColor.clear.cgColor}
    }
    private var shapes = [ShapeView]()
    private var numShapes = 1

    init(_ card: Card) {
        self.card = card
        numShapes = card.numShapes
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        isOpaque = false
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)

        for _ in 1...numShapes {
            let shape = ShapeView(frame: bounds)
            shape.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            shape.isOpaque = false

            if numShapes > 1 {
                shape.useShorter = false
            }
            shapes.append(shape)
            addSubview(shape)
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }

    override func layoutSubviews() {
        super.layoutSubviews()  // Runs autolayout stuff

        // Split the longest axis into numShapes
        var shapeFrame = CGRect(origin: frame.origin, size: frame.size)
        if frame.width > frame.height {
            shapeFrame.size.width = shapeFrame.width / CGFloat(numShapes)
        } else {
            shapeFrame.size.height = shapeFrame.height / CGFloat(numShapes)
        }

        for shape in shapes {
            shape.frame.origin = shapeFrame.origin
            shape.bounds = shapeFrame
            shape.setNeedsLayout()

            // Move the frame
            if frame.width > frame.height {
                shapeFrame.origin.x += shapeFrame.width - 1  // -1 to avoid a border effect
            } else {
                shapeFrame.origin.y += shapeFrame.height
            }
        }
    }

    override func draw(_ rect: CGRect) {
        let cardBackground = UIBezierPath(
            roundedRect: CGRect(x: rect.minX,
                                y: rect.minY,
                                width: rect.width,
                                height: rect.height),
            cornerRadius: cornerRadius)
        cardBackground.lineWidth = 1.5
        UIColor.black.setStroke()
        UIColor.white.setFill()
        cardBackground.fill()
        cardBackground.stroke()

        for shape in shapes {
            if let card = self.card {
                switch card.color {
                    case 0:
                        shape.color = UIColor.red
                    case 1:
                        shape.color = UIColor.green
                    default:
                        shape.color = UIColor.purple
                }
                shape.fill = card.shading
                shape.shape = card.shape
            }
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
