//
//  Post.swift
//  MyOlympia
//
//  Created by Michael Russo on 8/6/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Post {
    
    private var _username: String!
    private var _userImg: String!
    private var _postImg: String!
    private var _caption: String!
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: DatabaseReference!
    private var _date: String!
    private var _isFeatured: Bool!
    
    var username: String {
        return _username
    }
    
    var userImg: String {
        return _userImg
    }
    
    var postImg: String {
        
        get {
            return _postImg
            
        } set {
            _postImg = newValue
        }
    }
    
    var caption: String {
        return _caption
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var date: String {
        return _date
    }
    
    var isFeatured: Bool {
        return _isFeatured
    }
    
    init(imgUrl: String, likes: Int, username: String, userImg: String, caption: String, date: String, isFeatured: Bool) {
        self._likes = likes
        self._postImg = imgUrl
        self._username = username
        self._userImg = userImg
        self._caption = caption
        self._date = date
        self._isFeatured = isFeatured
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        _postKey = postKey
        
        if let username = postData["username"] as? String {
            self._username = username
        }
        
        if let userImg = postData["userImg"] as? String {
            self._userImg = userImg
        }
        
        if let postImage = postData["imageUrl"] as? String {
            self._postImg = postImage
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let date = postData["date"] as? String {
            self._date = date
        }
        
        if let isFeatured = postData["isFeatured"] as? Bool {
            self._isFeatured = isFeatured
        }
        
        _postRef = Database.database().reference().child("posts").child(_postKey)
    }
    
    //called in PostCell
    func adjustLikes(addLike: Bool) {
        
        if addLike {
            _likes = _likes + 1
            
        } else {
            _likes = _likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
}
