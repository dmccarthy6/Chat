//
//  FriendsListTableViewController.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import UIKit


protocol MessageDelegate {
    func messageSentTo(user: String)
}

class FriendsListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: - Properties:
    var recipientName: String?
    var delegate: MessageDelegate?
    
    
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
            
            self.performSegue(withIdentifier: "showChatsList", sender: self)

        }
        
        return cell!
    }
    
    func sendMessageRecipient(indexPath: IndexPath) {
        guard let messageReceived = FriendSystem.system.friendsList[indexPath.row].name else {
            print("MESSAGE RECEIED IS BLANK")
            return
        }
        recipientName = messageReceived
        self.delegate?.messageSentTo(user: recipientName!)//Force Unwrapping - be careful!
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "" {
            let vc: ChatListTableTableViewController = segue.destination as! ChatListTableTableViewController
            vc.delegate = self
        }
    }
 
}


/*cell!.setFunction {
 let messageReceived = FriendSystem.system.friendsList[indexPath.row].name
 
 if self.delegate != nil {
 self.delegate?.messageSentTo(user: messageReceived!)
 }
 
 
 self.performSegue(withIdentifier: "showChat", sender: self)
 }
 
 return cell!
 }*/
