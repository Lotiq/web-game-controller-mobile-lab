//
//  ViewController.swift
//  Web Game Controller
//
//  Created by Timothy on 3/4/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit
import Starscream
import CDJoystick

struct windowDimensions{
    let minX = 0
    let minY = 0
    let maxX = 95
    let maxY = 53
    let step = 0.25
}

class ViewController: UIViewController{
    
    @IBOutlet weak var joystick: CDJoystick!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        joystick.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        joystick.substrateColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        joystick.substrateBorderColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
        joystick.substrateBorderWidth = 1.0
        joystick.stickColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        joystick.stickBorderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        joystick.stickBorderWidth = 2.0
        joystick.fade = 0.5
        
        joystick.trackingHandler = { joystickData in
            self.move(angle: joystickData.angle)
        }
    }
    
    func move(angle: CGFloat){
        print(angle)
    }
    

}

