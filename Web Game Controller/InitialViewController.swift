//
//  InitialViewController.swift
//  Web Game Controller
//
//  Created by Timothy on 3/4/19.
//  Copyright © 2019 Timothy. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var startButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        nicknameTextField.delegate = self
        startButton.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    
    // MARK: TextField Delegate Functions
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        startButton.isEnabled = !text.isEmpty
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as? GameViewController
        vc?.playerId = nicknameTextField.text!
    }
}
