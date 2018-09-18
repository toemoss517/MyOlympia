//
//  SettingsVC.swift
//  MyOlympia
//
//  Created by Michael Russo on 10/20/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class SettingsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var profileImageSettings: CircleImageView!
    @IBOutlet weak var pwdField: FancyField!
    @IBOutlet weak var codeField: FancyField!
    
    var imagePickerSettings : UIImagePickerController!
    var imageSelectedSettings = false
    var usernameSettings: String!
    var userImgSettings: String!
    var post: Post!
    var newPassword: String!
    let isFeaturedCode = "5j39hsj9PK"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerSettings = UIImagePickerController()
        imagePickerSettings.delegate = self
        imagePickerSettings.allowsEditing = true
        
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in

            let data = snapshot.value as! Dictionary<String, AnyObject>
            self.usernameSettings = data["username"] as! String
            self.userImgSettings = data["userImg"] as! String
        })
    }
    
    func makeUserFeatured (img: String, bool: Bool) {
        
        let userData: Dictionary<String, AnyObject> = [
            
            "username": usernameSettings as AnyObject,
            "userImg": img as AnyObject,
            "isFeatured": bool as AnyObject
        ]
        let setLocation = DataService.ds.REF_USER_CURRENT
        setLocation.setValue(userData)
    }

    @IBAction func codeBtnTapped(_ sender: Any) {
        
        if codeField.text == "5j39hsj9PK" {
            self.makeUserFeatured(img: userImgSettings, bool: true)
            codeField.text = ""
        }
    }
    
    @IBAction func updatePasswordTapped(_ sender: Any) {
        newPassword = pwdField.text
        Auth.auth().currentUser?.updatePassword(to: newPassword) { (error) in
            
            if error != nil {
                print("error, password not updated")
                
            } else {
                self.pwdField.text = ""
                print("password updated")
            }
        }
    }
    
    @IBAction func selectedImagePickerSettings(_ sender: Any) {
        present(imagePickerSettings, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
                if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                    profileImageSettings.image = image
                    imageSelectedSettings = true
        
                } else {
                    print("image wasnt selected")
                }
                imagePickerSettings.dismiss(animated: true, completion: nil)
            }
    
    func changeUserImg(img: String) {
        
        let userData: Dictionary<String, AnyObject> = [
            "username": usernameSettings as AnyObject,
            "userImg": img as AnyObject,
            "isFeatured": false as AnyObject
        ]
        let setLocation = DataService.ds.REF_USER_CURRENT
        setLocation.setValue(userData)
    }
    
    func uploadImg() {
    
        guard let img = profileImageSettings.image, imageSelectedSettings == true else {
            
            print("image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "img/jpeg"
            Storage.storage().reference().child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print("did not upload image")
                    
                } else {
                    print("uploaded")
                    let downloadURl = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURl {
                        
                        self.changeUserImg(img: url)
                    }
                }
            }
        }
    }

    @IBAction func exitSettingsTapped(_ sender: Any) { 
        self.uploadImg()
        performSegue(withIdentifier: "ToFeed3" , sender: nil)
    }
}
