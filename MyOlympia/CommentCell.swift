//
//  CommentCell.swift
//  MyOlympia
//
//  Created by Michael Russo on 10/19/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class CommentCell: UITableViewCell {

    @IBOutlet weak var username2: UILabel!
    @IBOutlet weak var likesLbl2: UILabel!
    @IBOutlet weak var likeImg2: UIImageView!
    @IBOutlet weak var comment2: UITextView!
    
    var comment: Comment!
    var likesRef: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped2))
        tap.numberOfTapsRequired = 1
        likeImg2.addGestureRecognizer(tap)
        likeImg2.isUserInteractionEnabled = true
    }

    func configCell(comment: Comment) {
        self.comment = comment
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(comment.commentKey)
        self.likesLbl2.text = "\(comment.likes)"
        self.username2.text = comment.username
        self.comment2.text = comment.comment
        
        //check if liked by current user
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.likeImg2.image = UIImage(named: "empty-heart")
                
            } else {
                self.likeImg2.image = UIImage(named: "filled-heart")
            }
        })
    }
    
    @objc func likeTapped2(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let _ = snapshot.value as? NSNull {
                self.likeImg2.image = UIImage(named: "filled-heart")
                self.comment.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
                
            } else {            
                self.likeImg2.image = UIImage(named: "empty-heart")
                self.comment.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
}
