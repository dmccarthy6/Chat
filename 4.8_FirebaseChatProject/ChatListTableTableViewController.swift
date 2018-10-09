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
       // print("User ID from User Class: \(user.id!)")
        //print("Friend Name from local - Chat List VC \(user.name)")
        
        let title = FriendSystem.system.CURRENT_USER_NAME
        navigationItem.title = "\(title)'s Messages"
        
//        let friends = UserClass(userEmail: <#String#>, userID: <#String#>, name: <#String#>)
//        listOfMessages.append(friends.name)
        listOfMessages.append(messageRecipient!)
        tableView.reloadData()
    }
    
//        if delegate != nil {
//            //delegate?.messageSentTo(user: "John")
//        }
//    func messageSentTo(user: String) {
//        print("USER IS: \(user)")
//        messageRecipient = user
//        
//    }
    
   

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listOfMessages.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)

        let cellText = listOfMessages[indexPath.row]
        cell.textLabel?.text = cellText
        cell.detailTextLabel?.text = "Message Text Here"
        print("Chat List TVC TO ID: \(self.friendID!)")
        return cell
        
    }
    

    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
   override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 65
    }
    
    
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showChatsList" {
            
            let chatVC = segue.destination as! ChatViewController
            chatVC.toId = self.friendID!
            print("Chat List VC TOID PASSED ID: \(self.friendID!)")
        } else {
            print("DID NOT HIT PREPARE FOR SEGUE IN CHAT LIST VC")
        }

    }
    
    
    //MARK: - IB Actions
    
    @IBAction func composeButtonTapped(_ sender: Any) {
//        let chatViewController = ChatViewController()
//        present(chatViewController, animated: true, completion: nil)
        self.performSegue(withIdentifier: "chatVCSegue", sender: self)
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

