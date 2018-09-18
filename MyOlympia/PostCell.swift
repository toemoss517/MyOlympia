//
//  PostCell.swift
//  MyOlympia
//
//  Created by Michael Russo on 8/6/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import SwiftKeychainWrapper

class PostCell: UITableViewCell {
    
    @IBOutlet weak var userImg: CircleImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var seeComments: UIButton!
    @IBOutlet weak var postSettings: UIButton!
    
    var delegate: MyCustomCellDelegator!
    var post: Post!
    var comments = [Comment]()
    var comment: Comment!
    var likesRef: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    func configCell(post: Post, img: UIImage? = nil, userImg: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        self.likesLbl.text = "\(post.likes)"
        self.username.text = post.username
        self.caption.text = post.caption
        self.date.text = post.date
        
        DataService.ds.REF_POSTS.child(post.postKey).child("comments").observe(.value, with: {(snapshot) in
            
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                self.comments = []
                
                for data in snapshot {
                    print(data)
                    
                    if let commentDict = data.value as? Dictionary<String, AnyObject> {
                        let key = data.key
                        let comment = Comment(commentKey: key, commentData: commentDict)
                        self.comments.append(comment)
                    }
                }
            }
            self.seeComments.setTitle("See Comments (\(self.comments.count))", for: .normal)
        })
    
        if img != nil {
            self.postImg.image = img
            
        } else {
            let ref = Storage.storage().reference(forURL: post.postImg)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil {
                    print("unable to download image from firebase storage")
                    
                } else {
                    
                    if let imgData = data {
                        
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.postImg as NSString)
                        }
                    }
                }
            })
        }
        
        if userImg != nil {
            self.postImg.image = userImg
            
        } else {
            let ref = Storage.storage().reference(forURL: post.userImg)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                
                if error != nil {
                    print("unable to load image")
                    
                } else {
                    
                    if let imgData = data {
                        
                        if let img = UIImage(data: imgData) {
                            self.userImg.image = img
                        }
                    }
                }
            })
        }
        
        //check if liked by current user
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
                
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    @objc func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
                
            } else {
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
    func setPostKey() {
        
        let postKeyData: Dictionary<String, AnyObject> = [
            "postKey": self.post.postKey as AnyObject,
        ]
        let setLocation = DataService.ds.REF_USER_CURRENT.child("postKeys")
        setLocation.setValue(postKeyData)
    }
    
    @IBAction func seeComTapped(_ sender: Any) {
        self.setPostKey()        
        self.delegate.commentsPopUp()
    }
    
    @IBAction func postSettingsTapped(_ sender: Any) {  
        self.setPostKey()
        self.delegate.postSettingsPopUp()
    }
}
