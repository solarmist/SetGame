//
//  ShapeView.swift
//  Set
//
//  Created by Joshua Olson on 11/15/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

@IBDesignable
class ShapeView: UIView {
    // Variables for UI
    // Scale to 0.85 the largest without clipping by the edge of the card.
    // This looks cramped on the cards with 3 ovals though, so I'm using 0.75 which looks alright to me.
    let scale: CGFloat = 0.75
    let ratio: CGFloat = 0.5  // of width:height
    let lineWidth: CGFloat = 0.8  // lineWidth times thicker than standard thickness, used for striping and shape drawing
    private let color: UIColor
    private let topPaddingScale: CGFloat
    private let useShorter: Bool  // See notes in init

    private var path: UIBezierPath
    private var fill: () -> Void

    /**
     - parameters:
        - card: The card that is being displayed
        - frame: The shape's drawing area
        - topEdge: Does this shape share the top edge with the edge of the card
        - bottomEdge: Does this shape share the bottom edge with the edge of the card
     */
    init(card: Card<SetCardFace>, frame: CGRect, topEdge: Bool = true) {
        // Set these as dummy values for Phase 1
        path = UIBezierPath()
        fill = {}

        // This is used for single shapes because we're given the entire card to use.
        // In this case the natural orientation would be to place the longest axis of
        // the shape on the longest axis of the frame which wouldn't match any of the other cards.
        useShorter = card.faceValue.numShapes == 1 ? true : false

        // The padding of a shape on a card will one of (top, bottom):
        // (1/2, 1/2) single shape or (1/3, 1/3) internal shape
        // (2/3, 1/3) top shape or (1/3, 2/3) bottom shape
        if card.faceValue.numShapes == 1 {
            topPaddingScale = 1 / 2
        } else {
            topPaddingScale = topEdge ? 2/3 : 1/3
        }
        color = getColor(from: card)

        super.init(frame: frame)

        isOpaque = true
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0) // Set this to clear so we can see the card frame from the CardView

        switch card.faceValue.shape {
        case .squiggle: path = getSquiggle()
        case .oval: path = getOval()
        default: path = getDiamond()
        }
        path.lineWidth = lineWidth

        // The background inside the shape
        switch card.faceValue.shading {
        case .fill: fill = {self.color.setFill(); self.path.fill()}
        case .stripping: fill = drawStripes
        default: fill = {}  // Do nothing
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented"); }

    override func layoutSubviews() {
        super.layoutSubviews()  // Runs autolayout stuff
        // Re-scale and place the shape when the cards move
        scaleAndPlace(path)
    }

    override func draw(_ rect: CGRect) {
        path.addClip()
        color.setStroke()
        path.stroke()
        fill()
    }

    /**
     Draws closely spaced lines as an alternative fill compared to solid and empty

     - parameter rect: The area to fill with stripes

     - note:
        The line thickness and spacing is controlled by `lineWidth` and the space size is 1.5 times `lineWidth`.
        The objects' `color` is used for the color.

     */
    func drawStripes() {
        let stripeGap: CGFloat = path.lineWidth * 1.5  // desired gap between lines
        guard let context = UIGraphicsGetCurrentContext() else { return }

        UIColor.white.setFill()
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(path.lineWidth)

        var padding = stripeGap / 2 + bounds.minX
        while padding <= bounds.minX + bounds.size.width {
            let start = CGPoint(x: padding, y: bounds.minY)
            let end = CGPoint(x: padding, y: bounds.maxY)
            context.move(to: start)
            context.addLine(to: end)
            context.strokePath()
            padding += stripeGap + path.lineWidth
        }
    }

    /**
     Modifies the `path` object by positioning and resizing it with in the `bounds` of the object.

     - Parmeter path: The BezierPath to modify

     - Note: Uses `useShorter` to determine which axis to align with.
     */
    @discardableResult func scaleAndPlace(_ path: UIBezierPath) -> UIBezierPath {
        let minMax: (CGFloat, CGFloat) -> CGFloat = useShorter ? min : max
        let scale: CGFloat = self.scale * minMax(bounds.width, bounds.height)

        let scalePath = CGAffineTransform(
            scaleX: scale / max(path.bounds.width, path.bounds.height),
            y: scale / max(path.bounds.width, path.bounds.height)
        )
        path.apply(scalePath)

        // Calculate padding after resizing our shape
        let leadingPadding = (bounds.width - path.bounds.width) / 2
        let topPadding = (bounds.height - path.bounds.height) * self.topPaddingScale

        let translate = CGAffineTransform(
            translationX: -path.bounds.minX + leadingPadding,
            y: -path.bounds.minY + topPadding
        )
        path.apply(translate)

        return path
    }

    /**
     Make a generic Oval shape(path) in a rectangle

     - Returns: UIBezierPath with an oval scaled to the current frame.
     */
    func getOval() -> UIBezierPath {
        let width: CGFloat = 100
        let height = width * ratio
        // Need to replace the empty path we started with to get a rounded rectangle
        let path = UIBezierPath(
            roundedRect: CGRect(
                x: 0,
                y: 0,
                width: width,
                height: height),
            cornerRadius: height)

        return path
    }

    /**
     Make a diamond within a rectangle

     - Returns: UIBezierPath with a diamond scaled to the current frame.
     */
    func getDiamond() -> UIBezierPath {
        let width: CGFloat = 100
        let height = width * ratio
        let xCenter = width / 2
        let yCenter = height / 2

        path.move(to: CGPoint(x: -xCenter + lineWidth, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -yCenter + lineWidth))
        path.addLine(to: CGPoint(x: xCenter - lineWidth, y: 0))
        path.addLine(to: CGPoint(x: 0, y: yCenter - lineWidth))
        path.close()
        let reSize = CGAffineTransform(
            scaleX: 100 / path.bounds.width ,
            y: 50 / path.bounds.height
        ).translatedBy(
            x: -path.bounds.minX,
            y: -path.bounds.minY
        )
        path.apply(reSize)
        return path
    }

    /**
     Make a squiggle

     - Returns: UIBezierPath with a squiggle scaled to the current frame.

    - Note: Based on [How to draw a perfect squiggle in set card game with objective-c?](
     https://stackoverflow.com/questions/25387940/how-to-draw-a-perfect-squiggle-in-set-card-game-with-objective-c)
     */
    func getSquiggle() -> UIBezierPath {
        let startPoint = CGPoint(x: 76.5, y: 403.5)
        let curves = [
            // (to,
            //  Control Point 1, Control Point 2)
            // Top half
            (CGPoint(x: 199.5, y: 295.5),
             CGPoint(x: 92.463, y: 380.439), CGPoint(x: 130.171, y: 327.357)),

            (CGPoint(x: 815.5, y: 351.5),
             CGPoint(x: 418.604, y: 194.822), CGPoint(x: 631.633, y: 454.052)),

            (CGPoint(x: 1010.5, y: 248.5),
             CGPoint(x: 844.515, y: 313.007), CGPoint(x: 937.865, y: 229.987)),

            (CGPoint(x: 1057.5, y: 276.5),
             CGPoint(x: 1035.564, y: 254.888), CGPoint(x: 1051.46, y: 270.444)),

            // Bottom half
            (CGPoint(x: 993.5, y: 665.5),
             CGPoint(x: 1134.423, y: 353.627), CGPoint(x: 1105.444, y: 556.041)),

            (CGPoint(x: 860.5, y: 742.5),
             CGPoint(x: 983.56, y: 675.219), CGPoint(x: 941.404, y: 715.067)),

            (CGPoint(x: 271.5, y: 728.5),
             CGPoint(x: 608.267, y: 828.077), CGPoint(x: 452.192, y: 632.571)),

            (CGPoint(x: 101.5, y: 803.5),
             CGPoint(x: 207.927, y: 762.251), CGPoint(x: 156.106, y: 824.214)),

            (CGPoint(x: 49.5, y: 745.5),
             CGPoint(x: 95.664, y: 801.286), CGPoint(x: 73.211, y: 791.836)),

            (startPoint,
             CGPoint(x: 1.465, y: 651.628), CGPoint(x: 1.928, y: 511.233)),
        ]

        // Draw the squiggle
        path.move(to: startPoint)
        for (to, cp1, cp2) in curves {
            path.addCurve(to: to, controlPoint1: cp1, controlPoint2: cp2)
        }
        path.close()

        // Resize to 100 * 50 and move to origin
        let reSize = CGAffineTransform(
            scaleX: 100 / path.bounds.width ,
            y: 50 / path.bounds.height
        ).translatedBy(
            x:  -path.bounds.minX,
            y: -path.bounds.minY
        )

        path.apply(reSize)
        return path
    }
}
