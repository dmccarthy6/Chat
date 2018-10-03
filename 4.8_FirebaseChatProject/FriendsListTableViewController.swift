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
    var friendID: String?
    
    
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
        
        sendMessageRecipient(indexPath: indexPath)
        
        cell!.setFunction {
            
            guard let selectedFriend = FriendSystem.system.friendsList[indexPath.row].name else { return }
            self.recipientName = selectedFriend
            self.performSegue(withIdentifier: "showChatsList", sender: self)

        }
        let id = FriendSystem.system.friendsList[indexPath.row].id
        print("ID from friends list - this it? \(id)")
        return cell!
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatsList" {
            let navController = segue.destination as! UINavigationController
            let chatListVC = navController.topViewController as! ChatListTableTableViewController
            chatListVC.messageRecipient = self.recipientName
            chatListVC.friendID = self.friendID
        }
    }
    
//    func checkForMessages() {
//        FriendSystem.system.CURRENT_USER_REF.observe(DataEventType.value, with: { (snapshot) -> Void in
//            if let value = snapshot.value as? [String : AnyObject] {
//
//                let messages = value["messages"] as! String
//                let id = value["id"] as! String
//                print("ID from data snapshot in checkForMessages\(id)")
//
//                if messages != "" {
//                    self.performSegue(withIdentifier: "showChatsList", sender: self)
//                } else {
//                    self.performSegue(withIdentifier: "chatCell", sender: self)
//                }
//            }
//        })
//    }
    
    func sendMessageRecipient(indexPath: IndexPath) {
        guard let messageReceived = FriendSystem.system.friendsList[indexPath.row].name else {
            print("MESSAGE RECEIED IS BLANK")
            return
        }
        recipientName = messageReceived
        
        guard let id = FriendSystem.system.friendsList[indexPath.row].id else {return}
        friendID = id
        
    }
    
 
}


extension FriendsListTableViewController: MessageDelegate {
    func messageSentTo(user: String) {
        print("This is the user \(user)")
    }
    
    
}
