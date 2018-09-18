//
//  ResetPasswordVC.swift
//  MyOlympia
//
//  Created by Michael Russo on 11/11/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class ResetPasswordVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.showAnimate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        return(true)
    }
    
    @IBAction func exitPopUp(_ sender: Any) {
        self.removeAnimate()
    }
    
    @IBAction func resetPasswordTapped(_ sender: Any) {
        let email = emailField.text
        Auth.auth().sendPasswordReset(withEmail: email!) { error in
            
            if error != nil {
                print("error, unidentified email")

            } else {
                print("sent recovery email")
                self.removeAnimate()
            }
        }
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.4, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    func removeAnimate() {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool)  in
            
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
    }
}

