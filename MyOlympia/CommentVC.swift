//
//  CommentVC.swift
//  MyOlympia
//
//  Created by Michael Russo on 10/10/17.
//  Copyright © 2017 ToeMoss. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage

class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableViewComments: UITableView!
    @IBOutlet weak var commentField: FancyField!
    
    var comments = [Comment]()
    var comment: Comment!
    var posts = [Post]()
    var post: Post!
    var postKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showAnimate()

        tableViewComments.delegate = self
        tableViewComments.dataSource = self
        commentField.delegate = self
        
        DataService.ds.REF_USER_CURRENT.child("postKeys").observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as! Dictionary<String, AnyObject>
            self.postKey = data["postKey"] as! String

            DataService.ds.REF_POSTS.child(self.postKey).child("comments").observe(.value, with: {(snapshot) in
            
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
            self.tableViewComments.reloadData()
            })
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentField.resignFirstResponder()
        return(true)
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }

    func removeAnimate() {
         UIView.animate(withDuration: 0.2, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }, completion: {(finished : Bool)  in
            
            if (finished) {
                self.view.removeFromSuperview()
            }
        })
    }
    
    @IBAction func goBackTapped(_ sender: Any) {
        self.removeAnimate()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments.reversed()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            cell.configCell(comment: comment)
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 116
    }
    
    @IBAction func commentBtnTapped(_ sender: Any) {
        
        guard let comment = commentField.text, comment != "" else {       
            print("a comment must be entered")
            return
        }
        
        self.postToFirebaseCom()
        self.commentField.resignFirstResponder()
    }
    
    func postToFirebaseCom() {
        
        DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let data = snapshot.value as! Dictionary<String, AnyObject>
            let username = data["username"]
            DataService.ds.REF_USER_CURRENT.child("postKeys").observeSingleEvent(of: .value, with: { (snapshot) in
                
                let data = snapshot.value as! Dictionary<String, AnyObject>
                self.postKey = data["postKey"] as! String
            
            let comment: Dictionary<String, AnyObject> = [
                "username": username as AnyObject,
                "likes": 0 as AnyObject,
                "comment": self.commentField.text as AnyObject,
            ]
            let firebasePost = Database.database().reference().child("posts").child(self.postKey).child("comments").childByAutoId()
            firebasePost.setValue(comment)
            
            self.commentField.text = ""
            self.tableViewComments.reloadData()
            })        
        }) { (error) in
            
            print(error.localizedDescription)
        }
    }
}
