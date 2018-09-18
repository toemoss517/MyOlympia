//
//  FeedVC.swift
//  MyOlympia
//
//  Created by Michael Russo on 8/13/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import SwiftKeychainWrapper

//used to implement view controller class references in PostCell
protocol MyCustomCellDelegator {   
    func postSettingsPopUp()
    func commentsPopUp()
}

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, MyCustomCellDelegator {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var addImage: UIImageView!
    @IBOutlet weak var segmentController: UISegmentedControl!
    
    var posts = [Post]()
    var post: Post!
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    var chosenIndex = 0
    var postKey: String!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
//        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        captionField.delegate = self
     
        DataService.ds.REF_POSTS.observe(.value, with: {(snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.posts = []
                for data in snapshot {
                    print(data)
                    
                    if let postDict = data.value as? Dictionary<String, AnyObject> {
                         let key = data.key
                         let post = Post(postKey: key, postData: postDict)
                         self.posts.append(post)
                         
                         //remove posts with dates older than yesterday by checking the day portion of date strings
                         let date = postDict["date"] as! String
                         let currentDate = Date()
                         let yesterdaysDate = Date().addingTimeInterval(60 * 60 * 24 * 6)
                         let dayBeforeYesterdaysDate = Date().addingTimeInterval(60 * 60 * 24 * 5)
                         let formatter = DateFormatter()
                         formatter.dateFormat = "HH:mm 'on' EEE"
                         let result = formatter.string(from: currentDate)
                         let result2 = formatter.string(from: yesterdaysDate)
                         let result3 = formatter.string(from: dayBeforeYesterdaysDate)
                         
                         if date.suffix(3) ==  result.suffix(3) || date.suffix(3) == result2.suffix(3) || date.suffix(3) == result3.suffix(3) {
                              print("valid date")
                         } else {
                              print("not valid date")
                              self.posts.removeLast()
                         }
                    }
                }
            }
            self.tableView.reloadData()
        })
    }

    @IBAction func indexChanged(_ sender: Any) {
        
        switch(segmentController.selectedSegmentIndex) {
        case 0:
            chosenIndex = 0
            break
        case 1:
            chosenIndex = 1
            break
        case 2:
            chosenIndex = 2
            break
        default:
            break
        }
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        captionField.resignFirstResponder()
        return(true)
    }
     
    func postSettingsPopUp() {
     let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbPopUpID") as! PopUpVC
     self.addChildViewController(popOverVC)
     popOverVC.view.frame = self.view.frame
     self.view.addSubview(popOverVC.view)
     popOverVC.didMove(toParentViewController: self)
    }
     
     func commentsPopUp() {
     let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbCommentID") as! CommentVC
     self.addChildViewController(popOverVC)
     popOverVC.view.frame = self.view.frame
     self.view.addSubview(popOverVC.view)
     popOverVC.didMove(toParentViewController: self)
     }
     
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     var postCount = posts.count
     var count = 0
     
     if chosenIndex == 2 {
          
          for post in posts {
               
               if post.isFeatured == true {
                    count += 1
                    postCount = count
               }
          }
          
     } else {
          
          for post in posts {
               
               if post.isFeatured == false {
                    count += 1
                    postCount = count
               }
          }
     }
     return postCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     var postOrder = posts.filter { $0.isFeatured == false }.reversed()[indexPath.row]
        
        if chosenIndex == 0 {
            postOrder = posts.filter { $0.isFeatured == false }.reversed()[indexPath.row]
            
        } else if chosenIndex == 1 {
            postOrder = posts.filter { $0.isFeatured == false }.sorted(by: { $0.likes > $1.likes })[indexPath.row]
            
        } else if chosenIndex == 2 {
            postOrder = posts.filter { $0.isFeatured == true }.reversed()[indexPath.row]
          
        } else {
            print("error, postOrder not changed")
        }
     
        let post = postOrder

        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.postImg as NSString) {
                cell.configCell(post: post, img: img)
                
            } else {
                cell.configCell(post: post)
            }
          
            cell.delegate = self
            return cell
            
        } else {
            return PostCell()
        }
    }
     
     @IBAction func postImageTapped(_ sender: AnyObject) {
          //        present(imagePicker, animated: true, completion: nil)
          let alert = UIAlertController(title: "Post Image", message: "Where would you like to get your image from?", preferredStyle: .alert)
          let cameraAction = UIAlertAction(title: "Camera", style: .destructive) { (alert: UIAlertAction!) -> Void in
               
               if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    self.imagePicker.sourceType = .camera;
                    self.imagePicker.allowsEditing = false
                    self.present(self.imagePicker, animated: true, completion: nil)
               }
               print("camera")
          }
          let photosAction = UIAlertAction(title: "Photos", style: .destructive) { (alert: UIAlertAction!) -> Void in
               
               if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    self.imagePicker.sourceType = .photoLibrary;
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true, completion: nil)
               }
               print("photos")
          }
          alert.addAction(cameraAction)
          alert.addAction(photosAction)
          present(alert, animated: true, completion:nil)
     }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            addImage.image = image
            imageSelected = true

        } else {
            print("a valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        
        guard let img = addImage.image, imageSelected == true else {
            print("an image must be selected")
            return
        }
        
        guard let caption = captionField.text, caption != "" else {
            print("a caption must be entered")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            Storage.storage().reference().child("post-pics").child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                
                if error != nil {
                    print("image did not save to firebase storage")
                    
                } else {
                    print("uploaded to firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                        self.captionField.resignFirstResponder()
                    }
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
          DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
               
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            let userImg = data["userImg"]
            let isFeatured = data["isFeatured"]
            let date = Date()
            let formatter = DateFormatter()
               formatter.dateFormat = "HH:mm 'on' EEE"
            let result = formatter.string(from: date)
            
            let post: Dictionary<String, AnyObject> = [
                "username": username as AnyObject,
                "userImg": userImg as AnyObject,
                "imageUrl": imgUrl as AnyObject,
                "likes": 0 as AnyObject,
                "caption": self.captionField.text as AnyObject,
                "isFeatured": isFeatured as AnyObject,
                "date": result as AnyObject,
            ]
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
               
            self.captionField.text = ""
            self.imageSelected = false
            self.addImage.image = UIImage(named: "add-image")
            self.tableView.reloadData()
            
        }) { (error) in
            
            print(error.localizedDescription)
        }
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        performSegue(withIdentifier: "ToSettings", sender: nil)
    }
    
    @IBAction func signOutTapped(_ sender: AnyObject) {
     let alert = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .alert)
     let logOutAction = UIAlertAction(title: "Log Out", style: .destructive) { (alert: UIAlertAction!) -> Void in
          let keychainResult = KeychainWrapper.standard.removeObject(forKey: "uid")
          print("id removed from keychain \(keychainResult)")
          try! Auth.auth().signOut()
          self.performSegue(withIdentifier: "ToSignIn", sender: nil)
          }
     let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (alert: UIAlertAction!) -> Void in
          print("canceld log out")
          }
     alert.addAction(logOutAction)
     alert.addAction(cancelAction)
     present(alert, animated: true, completion:nil)
    }
}
