//
//  UserCreateVC.swift
//  MyOlympia
//
//  Created by Michael Russo on 8/8/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

class UserCreateVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImage: CircleImageView!  
    @IBOutlet weak var usernameField: FancyField!
    @IBOutlet weak var createAccountBtn: FancyButton!
    
    var emailField: String!
    var passwordField: String!
    var imagePicker : UIImagePickerController!
    var imageSelected = false
    var username: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameField.delegate = self
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameField.resignFirstResponder()
        return(true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
            imageSelected = true
            
        } else {
            print("image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func setUpUser(img: String) {
        
        let userData: Dictionary<String, AnyObject> = [
            "username": username! as AnyObject,
            "userImg": img as AnyObject,
            "isFeatured": false as AnyObject
        ] 
        let setLocation = DataService.ds.REF_USER_CURRENT
        setLocation.setValue(userData)
    }
    
    func uploadImg() {
        let img = profileImage.image
        username = usernameField.text
        
        if let imgData = UIImageJPEGRepresentation(img!, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "img/jpeg"
            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print("did not upload image")
                    
                } else {
                    print("uploaded image")
                    let downloadURl = metadata?.downloadURL()?.absoluteString
                    
                    if let url = downloadURl {
                        self.setUpUser(img: url)
                    }
                }
            }
        }
    }

    @IBAction func completeAccount(_ sender: Any) {
        
        guard let username = usernameField.text, username != "" else {
            print("a username must be entered")
            return
        }
        
        guard let _ = self.profileImage.image, self.imageSelected == true else {
            print("image must be selected")
            return
        }
        
        Auth.auth().createUser(withEmail: emailField, password: passwordField, completion: { (user,error) in
            
            if error != nil {
                print("cant create user \(String(describing: error))")
                
            } else {
                
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
            self.uploadImg()
        })
        dismiss(animated: true, completion: nil)
    }

    @IBAction func selectedImagePicker(_ sender: Any){
        present(imagePicker, animated: true, completion: nil)
    }
    
    func completeSignIn(id: String) {      
        DataService.ds.createFirebaseDBUser(uid: id)
        let keychainResult = KeychainWrapper.standard.set(id, forKey: "uid")
        print("data saved to keychain \(keychainResult)")
    }
}
