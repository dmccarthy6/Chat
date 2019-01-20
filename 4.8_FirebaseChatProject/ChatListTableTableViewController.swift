//
//  ChatListTableTableViewController.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/28/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import UIKit
import MessageKit

protocol MessageDelegate {
    func messageSentTo(user: String)
}

class ChatListTableTableViewController: UITableViewController {
    
    //MARK: - Properties
    var messageRecipient: String?
    var listOfMessages = [String]()
    var friendID: String?
    var user = UserClass()
    //var delegate: MessageDelegate?

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       getToId()
        let title = FriendSystem.system.CURRENT_USER_NAME
        navigationItem.title = "\(title)'s Messages"

        listOfMessages.append(messageRecipient!)
        tableView.reloadData()
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FriendSystem.system.friendsList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)

        let friends = FriendSystem.system.friendsList
        let friendName = friends[indexPath.row].name!
        cell.textLabel?.text = friendName
        //cell.detailTextLabel?.text = "Message Text Here"
        
        return cell
        
    }
    

    
    //MARK: - Table View Delegate
    
   
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatsList" {
            let chatVC = segue.destination as! ChatViewController
            chatVC.toId = self.friendID!
        } else {
            print("DID NOT HIT PREPARE FOR SEGUE IN CHAT LIST VC")
        }

    }
    
    
    //MARK: - IB Actions
    
    @IBAction func composeButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "chatVCSegue", sender: self)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func getToId() {
        FriendSystem.system.CHAT_ROOM_REF.observe(.childAdded) { (snapshot) in
            let id = snapshot.key
            print("This is ID from getToId(): \(id)")
        }
    }
    
}

