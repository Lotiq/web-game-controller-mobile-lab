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

enum DirectionCode: String {
    case up = "0"
    case right = "1"
    case down = "2"
    case left = "3"
}

let playerIdKey = "PLAYER_ID"

class GameViewController: UIViewController, WebSocketDelegate{
    
    @IBOutlet weak var joystick: CDJoystick!
    
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
            self.move(angle: joystickData.angle)
        }
        
        defaults = UserDefaults.standard
        
        // Get USER DEFAULTS data. ////////////
        // If there is a player id saved, set text field.
        if let playerId = defaults.string(forKey: playerIdKey) {
            self.playerId = playerId
        }
    }
    
    func move(angle: CGFloat){
        let part = angle/CGFloat.pi
        if (part >= 1.75 && part <= 2) || (part >= 0 && part < 0.25){
            sendDirectionMessage(.up)
        } else if (part >= 0.25 && part < 0.75){
            sendDirectionMessage(.right)
        } else if (part >= 0.75 && part < 1.25){
            sendDirectionMessage(.down)
        } else {
            sendDirectionMessage(.left)
        }
    }
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("✅ Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("🛑 Disconnected:", error ?? "No message")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("⬇️ websocket did receive message:", text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("<<< Received data:", data)
    }
    
    func sendDirectionMessage(_ code: DirectionCode) {
        // Get the raw string value from the DirectionCode enum
        // that we created at the top of this program.
        sendMessage(code.rawValue)
    }
    
    func sendMessage(_ message: String) {
        
        // Construct server message and write to socket. ///////////
        let message = "\(playerId), \(message)"
        socket?.write(string: message) {
            // This is a completion block.
            // We can write custom code here that will run once the message is sent.
            print("⬆️ sent message to server: ", message)
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

