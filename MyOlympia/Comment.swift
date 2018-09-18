//
//  Comment.swift
//  MyOlympia
//
//  Created by Michael Russo on 10/19/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Comment {
    
    private var _username: String!
    private var _comment: String!
    private var _likes: Int!
    private var _commentKey: String!
    private var _commentRef: DatabaseReference!
    
    var postKey: String!
    
    var username: String {
        return _username
    }
    
    var comment: String {
        return _comment
    }
    
    var likes: Int {
        return _likes
    }
    
    var commentKey: String {
        return _commentKey
    }
    
    init(likes: Int, username: String, comment: String) {
        self._likes = likes
        self._username = username
        self._comment = comment
    }
    
    init(commentKey: String, commentData: Dictionary<String, AnyObject>) {
        _commentKey = commentKey
        
        if let username = commentData["username"] as? String {
            self._username = username
        }
        
        if let likes = commentData["likes"] as? Int {
            self._likes = likes
        }
        
        if let comment = commentData["comment"] as? String {
            self._comment = comment
        }
        
        DataService.ds.REF_USER_CURRENT.child("postKeys").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as? Dictionary<String, AnyObject>
            self.postKey = data?["postKey"] as? String
            
            if self.postKey != nil {
                self._commentRef = Database.database().reference().child("posts").child(self.postKey).child("comments").child(self._commentKey)
            }
        })
    }
    
    //called in CommentCell
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            _likes = _likes + 1
            
        } else {         
            _likes = _likes - 1
        }   
        _commentRef.child("likes").setValue(_likes)
    }
}
