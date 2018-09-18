//
//  SignInVC.swift
//  MyOlympia
//
//  Created by Michael Russo on 8/6/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if let _ = KeychainWrapper.standard.string(forKey: "uid") {
            goToFeedVC()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        return(true)
    }
    
    func goToCreateUserVC(){
        performSegue(withIdentifier: "SignUp", sender: nil)
    }
    
    func goToFeedVC() {
        performSegue(withIdentifier: "ToFeed", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "SignUp" {
            
            if let destination = segue.destination as? UserCreateVC {
                
                if emailField.text != nil {
                          destination.emailField = emailField.text
                }
                
                if passwordField.text != nil {
                    destination.passwordField = passwordField.text
                }
            }
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user,error) in
                
                if error == nil {
                    
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                    
                } else {
                   
                    guard let emailEntered = self.emailField.text, emailEntered != "" else {
                        print("an email must be entered")
                        return
                    }
                    
                    guard let passwordEntered = self.passwordField.text, passwordEntered != "" else {
                        print("a password must be entered")
                        return
                    }
                    self.goToCreateUserVC()
                }
            })
        }
    }
    
    func completeSignIn(id: String) {   
        DataService.ds.createFirebaseDBUser(uid: id)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: "uid")
        print("data saved to keychain \(keychainResult)")
        self.goToFeedVC()
    }
    

    @IBAction func resetPasswordPopUp(_ sender: Any) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbResetPasswordID") as! ResetPasswordVC
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
    }
}
    
