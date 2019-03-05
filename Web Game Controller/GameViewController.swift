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
import Foundation

struct windowDimensions{
    let minX = 0
    let minY = 0
    let maxX = 95
    let maxY = 53
    let step = 0.25
}

enum DirectionCode: String {
    case up = "0"
    case right = "1"
    case down = "2"
    case left = "3"
}

let playerIdKey = "PLAYER_ID"

class GameViewController: UIViewController, WebSocketDelegate{
    
    @IBOutlet weak var joystick: CDJoystick!
    
    var latestAngle: Double = 0
    var previousLoc: (Double,Double) = (0,0)
    var currentLoc: (Double,Double) = (0,0)
    var previousDirection: DirectionCode = .up
    var defaults: UserDefaults!
    var socket: WebSocket?
    var playerId: String = "Chupacabra"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString = "wss://gameserver.mobilelabclass.com"
        socket = WebSocket(url: URL(string: urlString)!)
        
        
        // Assign WebSocket delegate to self
        socket?.delegate = self
        
        // Connect.
        socket?.connect()
        
        // Assigning notifications to handle when the app becomes active or inactive.
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        joystick.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        joystick.substrateColor = #colorLiteral(red: 0.7233663201, green: 0.7233663201, blue: 0.7233663201, alpha: 1)
        joystick.substrateBorderColor = #colorLiteral(red: 0.5723067522, green: 0.5723067522, blue: 0.5723067522, alpha: 1)
        joystick.substrateBorderWidth = 1.0
        joystick.stickColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        joystick.stickBorderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        joystick.stickBorderWidth = 2.0
        joystick.fade = 0.5
        
        joystick.trackingHandler = { joystickData in
            let dataAngle = joystickData.angle
            var angle: Double!
            if (dataAngle>CGFloat.pi/2 && dataAngle<CGFloat.pi*3/2){
                angle = 2*Double.pi - acos(sin(Double(joystickData.angle)))
            } else {
                angle = acos(sin(Double(joystickData.angle)))
            }
            self.move(angle: angle)
            
        }
        
        defaults = UserDefaults.standard
        
        // Get USER DEFAULTS data. ////////////
        // If there is a player id saved, set text field.
        if let playerId = defaults.string(forKey: playerIdKey) {
            self.playerId = playerId
        }
    }
    
    func move(angle: Double){
        let PI = Double.pi
        switch angle {
        case 0..<PI/6,11*PI/6..<2*PI:
            sendDirectionMessage(.right)
        case PI/6..<PI/3:
            if (previousDirection == .up){
               sendDirectionMessage(.right)
            } else {
               sendDirectionMessage(.up)
            }
        case PI/3..<2*PI/3:
            sendDirectionMessage(.up)
        case 2*PI/3..<5*PI/6:
            if (previousDirection == .up){
                sendDirectionMessage(.left)
            } else {
                sendDirectionMessage(.up)
            }
        case 5*PI/6..<7*PI/6:
            sendDirectionMessage(.left)
        case 7*PI/6..<8*PI/6:
            if (previousDirection == .down){
                sendDirectionMessage(.left)
            } else {
                sendDirectionMessage(.down)
            }
        case 8*PI/6..<10*PI/6:
            sendDirectionMessage(.down)
        case 10*PI/6..<11*PI/6:
            if (previousDirection == .down){
                sendDirectionMessage(.right)
            } else {
                sendDirectionMessage(.down)
            }
        default:
            print("error")
        }
        
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("✅ Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("🛑 Disconnected:", error ?? "No message")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print(text)
        let data: Data? = text.data(using: .utf8)
        guard let json = (try? JSONSerialization.jsonObject(with: data!, options: [])) as? [String:AnyObject] else{
            print("failed json")
            return
        }
        
        guard let players = json["players"] as? [String:AnyObject], let myPlayer = players[playerId] as? [String: AnyObject] else{
            print("couldn't find my player")
            return
        }
        
        guard let xLoc = myPlayer["x"] as? Double, let yLoc = myPlayer["y"] as? Double, let dir = myPlayer["direction"] as? Int else {
            print("couldn't find locations or direction")
            return
        }
        
        
        
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("<<< Received data:", data)
    }
    
    func sendDirectionMessage(_ code: DirectionCode) {
        // Get the raw string value from the DirectionCode enum
        // that we created at the top of this program.
        previousDirection = code
        sendMessage(code.rawValue)
    }
    
    func sendMessage(_ message: String) {
        
        // Construct server message and write to socket. ///////////
        let message = "\(playerId), \(message)"
        socket?.write(string: message) {
            // This is a completion block.
            // We can write custom code here that will run once the message is sent.
            //print("⬆️ sent message to server: ", message)
        }
        ///////////////////////////////////////////////////////////
    }
    
    @objc func willResignActive() {
        print("💡 Application will resign active. Disconnecting socket.")
        socket?.disconnect()
    }
    
    @objc func didBecomeActive() {
        print("💡 Application did become active. Connecting socket.")
        socket?.connect()
    }

}

