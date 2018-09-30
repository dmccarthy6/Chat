//
//  ChatListTableTableViewController.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/28/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import UIKit
import MessageKit

class ChatListTableTableViewController: UITableViewController {
    
    //MARK: - Properties
    var messageRecipient: String?
    var userMessages: [Message] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
    
    
    func setDelegate() {
        let vc = FriendsListTableViewController()
        vc.delegate = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)

        let messageReceivedBy = messageRecipient
        print("Recipient is!!!!: \(String(describing: messageReceivedBy))")
        cell.textLabel?.text = messageReceivedBy

        
        return cell
    }
    

    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    
    //MARK: - IB Actions
    
    @IBAction func composeButtonTapped(_ sender: Any) {
        
        
        
    }
    
}

extension ChatListTableTableViewController: MessageDelegate {
    
    func messageSentTo(user: String) {
        print("USER IS: \(user)")
        messageRecipient = user
        setDelegate()
    }
}
