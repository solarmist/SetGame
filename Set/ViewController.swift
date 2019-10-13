//
//  ViewController.swift
//  Set
//
//  Created by Joshua Olson on 10/13/19.
//  Copyright © 2019 solarmist. All rights reserved.
//

import UIKit

//case diamond = "▲"
//case squiggle = "■"
//case oval = "●"
// These are all UI specific
enum Shape: String, CustomStringConvertible {
    // Note: The string values are only temporary until we use drawing to represent the images
    var description: String { return "\(self.rawValue)"}

    case diamond = "▲"
    case squiggle = "■"
    case oval = "●"
}

enum Shading: Double {
    case open = 0
    case translucent = 0.5
    case solid = 1
}

enum Color {
    case color1
    case color2
    case red
}


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

