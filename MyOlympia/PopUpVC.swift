//
//  PopUpVC.swift
//  MyOlympia
//
//  Created by Michael Russo on 11/11/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class PopUpVC: UIViewController {

    @IBOutlet weak var deletePostBtn: UIButton!
    @IBOutlet weak var reportPostBtn: UIButton!
    
    var posts = [Post]()
    var post: Post!
    var postKey: String!
    var usernamePost: String!
    var usernameCurrentUser: String!
    let SHADOW_GRAY: CGFloat = 120.0 / 255.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.showAnimate()
        
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as! Dictionary<String, AnyObject>
            self.usernameCurrentUser = data["username"] as! String
            DataService.ds.REF_USER_CURRENT.child("postKeys").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let data = snapshot.value as! Dictionary<String, AnyObject>
                self.postKey = data["postKey"] as! String
                DataService.ds.REF_POSTS.child(self.postKey).observeSingleEvent(of: .value, with: { (snapshot) in
                    
                    let data = snapshot.value as! Dictionary<String, AnyObject>
                    self.usernamePost = data["username"] as! String
                    
                    if self.usernamePost != self.usernameCurrentUser {
                        self.deletePostBtn.backgroundColor = UIColor(red: self.SHADOW_GRAY, green: self.SHADOW_GRAY, blue: self.SHADOW_GRAY, alpha: 0.8)
                    }
                })
            })
        })
    }
    
    @IBAction func exitPopUp(_ sender: Any) {
        self.removeAnimate()
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
    
    func postReportedPostsToFirebase() {
        
        let reportedPost: Dictionary<String, AnyObject> = [     
            "postKey": postKey as AnyObject
        ]
        let firebaseReportedPost = DataService.ds.REF_REPORTED_POSTS.childByAutoId()
        firebaseReportedPost.setValue(reportedPost)
    }
    
    @IBAction func deletePostTapped(_ sender: Any) {
        
        if usernamePost == usernameCurrentUser {
        DataService.ds.REF_POSTS.child(self.postKey).removeValue()
        self.deletePostBtn.backgroundColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.8)
            self.removeAnimate()
        }
    }
    
    @IBAction func reportPostTapped(_ sender: Any) {
        self.postReportedPostsToFirebase()
        self.reportPostBtn.backgroundColor = UIColor(red: SHADOW_GRAY, green: SHADOW_GRAY, blue: SHADOW_GRAY, alpha: 0.8)     
        self.removeAnimate()
    }
}
