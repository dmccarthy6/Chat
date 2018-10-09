//
//  FriendsListTableViewController.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import UIKit
import Firebase

class FriendsListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: - Properties:
    var recipientName: String?
    var userID: String?
    var user = [UserClass]()
    var userClass = UserClass()
    
    
    //MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FriendSystem.system.addFriendObserver {
            self.tableView.reloadData()
        }
        
        let bundle = Bundle(for: type(of: self))
        let cellNib = UINib(nibName: "UserCell", bundle: bundle)
        self.tableView.register(cellNib, forCellReuseIdentifier: "UsersCell")
    }
    
    
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FriendSystem.system.friendsList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell", for: indexPath) as? UserCell
        
        if cell == nil {
            tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        }
        
        cell?.cellButton.setTitle("Chat", for: UIControlState())
        cell?.emailLabel.text = FriendSystem.system.friendsList[indexPath.row].email
        
        cell!.setFunction {
            
            guard let selectedFriend = FriendSystem.system.friendsList[indexPath.row].name else { return }
            self.recipientName = selectedFriend
            
            guard let id = FriendSystem.system.friendsList[indexPath.row].id else {
                print("Friends List VC - No ID from Friend")
                return
            }
            guard let email = FriendSystem.system.friendsList[indexPath.row].email else {
                print("Email value in Friends List VC is Nil")
                return
            }
            guard let name = FriendSystem.system.friendsList[indexPath.row].name else {
                print("Name value in Friends List VC is Nil")
                return
            }
            
            //Values To Pass
            self.userID = id
            self.recipientName = name
            
            print("Values Passed from Friends List TVC - ID: \(self.userID!), NAME: \(self.recipientName!)")
            
            self.performSegue(withIdentifier: "showChatsList", sender: self)
        }
        return cell!
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatsList" {
            let navController = segue.destination as! UINavigationController
            let chatListVC = navController.topViewController as! ChatListTableTableViewController
            chatListVC.messageRecipient = self.recipientName
            chatListVC.friendID = self.userID
        }
    }
    
}


//extension FriendsListTableViewController: MessageDelegate {
//    func messageSentTo(user: String) {
//        print("This is the user \(user)")
//    }
//
//
//}
