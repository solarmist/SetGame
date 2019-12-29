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
    // Scale to 0.85 the largest without clipping by the edge of the card
    let scale: CGFloat = 0.75
    let ratio: CGFloat = 0.5
    var color = UIColor.red
    var lineWidth: CGFloat = 1.5
    var useShorter: Bool = true  // If the shape is the whole card we want to use the shorter dimension
    // 0 = empty
    // 1 = striped
    // 2 = opaque
    var fill = 2
    var shape = 0

    override func draw(_ rect: CGRect) {
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        isOpaque = false

        let path: UIBezierPath

        switch shape {
            case 0:
                path = getSquiggle(bounds)
            case 1:
                path = getOval(bounds)
            default:
                path = getDiamond(bounds)
        }
        path.lineWidth = lineWidth

        color.setStroke()
        scaleAndPlace(path)
        path.addClip()

        switch fill {
            case 0:
                color.setFill()
            case 1:
                drawStripes(path.bounds)
                fallthrough
            default:
                UIColor.clear.setFill()
        }

        path.fill()
        path.stroke()
    }

    func drawStripes(_ rect: CGRect) {
        let thickness: CGFloat = lineWidth // desired thickness of lines
        let gap: CGFloat = lineWidth * 1.5  // desired gap between lines

        guard let c = UIGraphicsGetCurrentContext() else { return }
        c.setStrokeColor(color.cgColor)
        c.setLineWidth(thickness)

        var p = gap / 2 + rect.minX
        while p <= rect.minX + rect.size.width {
            let start = CGPoint(x: p, y: rect.minY)
            let end = CGPoint(x: p, y: rect.maxY)
            c.move(to: start)
            c.addLine(to: end)
            c.strokePath()
            p += gap + thickness
        }
    }

    func scaleAndPlace(_ path: UIBezierPath) {
        // Now scale and translate the squiggle
        let scale: CGFloat = self.scale * (useShorter ? min(bounds.width, bounds.height) : max(bounds.width, bounds.height))
        path.apply(CGAffineTransform(scaleX: scale / max(path.bounds.width, path.bounds.height),
                                     y: scale / max(path.bounds.width, path.bounds.height)))

        // Only use this if we have the cards layed out on their side (wider than tall)
        // path.apply(CGAffineTransform(rotationAngle: -CGFloat.pi / 2))

        // Now move the object to the center of the bounds rectangle
        let widthPadding = (bounds.width - path.bounds.width) / 2
        let heightPadding = (bounds.height - path.bounds.height) / 2
        path.apply(CGAffineTransform(translationX: bounds.minX + -path.bounds.minX + widthPadding,
                                     y: bounds.minY + -path.bounds.minY + heightPadding))
    }

    func getOval(_ bounds: CGRect) -> UIBezierPath {
        let width: CGFloat = 1000
        let height = width * ratio
        let path = UIBezierPath(
            roundedRect: CGRect(x: 0,
                                y: 0,
                                width: width,
                                height: height),
            cornerRadius: height)
        return path
    }

    func getDiamond(_ bounds: CGRect) -> UIBezierPath {
        let width: CGFloat = 1000
        let height = width * ratio
        let path = UIBezierPath()

        path.move(to: CGPoint(x: -width / 2 + lineWidth, y: 0))
        path.addLine(to: CGPoint(x: 0, y: -height / 2 + lineWidth))
        path.addLine(to: CGPoint(x: width / 2 - lineWidth, y: 0))
        path.addLine(to: CGPoint(x: 0, y: height / 2 - lineWidth))

        path.close()
        return path
    }

    func getSquiggle(_ bounds: CGRect) -> UIBezierPath {
        // Based on: https://stackoverflow.com/questions/25387940/how-to-draw-a-perfect-squiggle-in-set-card-game-with-objective-c
        let startPoint = CGPoint(x: 76.5, y: 403.5)
        let curves = [ // to, cp1, cp2
            (CGPoint(x:  199.5, y: 295.5), CGPoint(x: 92.463, y: 380.439),
             CGPoint(x: 130.171, y: 327.357)),
            (CGPoint(x:  815.5, y: 351.5), CGPoint(x: 418.604, y: 194.822),
             CGPoint(x: 631.633, y: 454.052)),
            (CGPoint(x: 1010.5, y: 248.5), CGPoint(x: 844.515, y: 313.007),
             CGPoint(x: 937.865, y: 229.987)),
            (CGPoint(x: 1057.5, y: 276.5), CGPoint(x: 1035.564, y: 254.888),
             CGPoint(x: 1051.46, y: 270.444)),
            (CGPoint(x:  993.5, y: 665.5), CGPoint(x: 1134.423, y: 353.627),
             CGPoint(x: 1105.444, y: 556.041)),
            (CGPoint(x:  860.5, y: 742.5), CGPoint(x: 983.56, y: 675.219),
             CGPoint(x: 941.404, y: 715.067)),
            (CGPoint(x:  271.5, y: 728.5), CGPoint(x: 608.267, y: 828.077),
             CGPoint(x: 452.192, y: 632.571)),
            (CGPoint(x:  101.5, y: 803.5), CGPoint(x: 207.927, y: 762.251),
             CGPoint(x: 156.106, y: 824.214)),
            (CGPoint(x:   49.5, y: 745.5), CGPoint(x: 95.664, y: 801.286),
             CGPoint(x: 73.211, y: 791.836)),
            (startPoint, CGPoint(x: 1.465, y: 651.628),
             CGPoint(x: 1.928, y: 511.233)),
        ]

        // Draw the squiggle
        let path = UIBezierPath()
        path.move(to: startPoint)
        for (to, cp1, cp2) in curves {
            path.addCurve(to: to, controlPoint1: cp1, controlPoint2: cp2)
        }
        path.close()

        // Shrink the squiggle by 10% to make it look more balanced with the diamond and oval
        path.apply(CGAffineTransform(scaleX: 0.9 / max(path.bounds.width, path.bounds.height),
                                     y: 0.9 / max(path.bounds.width, path.bounds.height)))
        return path
    }
}
