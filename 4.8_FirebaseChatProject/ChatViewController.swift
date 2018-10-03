//
//  ChatViewController.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageKit

class ChatViewController: MessagesViewController, MessageDelegate {
    
    //Delegate Function To Get Sender Name
    func messageSentTo(user: String) {
        print("This is user: \(user)")
        messageSentTo = user
    }
    
    //MARK: - Properties
    
    var messages: [Message] = []
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    var messageSentTo: String?
    var toId: String?
    var messagesDictionary = [String : Message]()
    
    var messageID: String = {
        var uuid = UUID().uuidString
        return uuid
    }()
    
    var user: UserClass? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    
    //MARK: - Outlets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadMessages()
    }
    
    func messageDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    func loadMessages() {
        messages.removeAll()
        /* databaseHandle = */FriendSystem.system.USER_REF.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
            if let value = snapshot.value as? [String : AnyObject] {
                let toId = value["toId"] as! String
                let fromId = value["fromId"] as! String
                let text = value["text"] as! String
                let name = value["name"] as! String
                //let messageId = value["messageId"] as! String
                let sender = Sender(id: fromId, displayName: name)
                let date = Date()
                let message = Message(text: text, sender: sender, messageId: self.messageID, date: date)
                
                //let message = Message(toId: toId, fromId: fromId, name: name, text: text, messageID: self.messageID)
                self.messages.append(message)
                
                //                guard let toIdSelected = self.toId else { return }
                //                FriendSystem.system.USER_REF.child("messages").queryEqual(toValue: toIdSelected).observe(.childAdded, with: { (snapshot) in
                //                    if let dictionary = snapshot.value as? [String : AnyObject] {
                //                        let toId = dictionary["toId"] as! String
                //                        let fromId = dictionary["fromId"] as! String
                //                        let text = dictionary["text"] as! String
                //                        let name = dictionary["name"] as! String
                //
                //                        let message = Message(toId: toId, fromId: fromId, name: name, text: text, messageID: self.messageID)
                //                        self.messages.append(message)
                //                    }
                //                })
                //self.messagesDictionary[message.toId] = message
                //self.messages = Array(self.messagesDictionary.values)
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        })
    }
    
    
    /*if let value = snapshot.value as? [String : AnyObject] {
     let senderId = value["senderId"] as! String //This is Sender Name
     let text = value["text"] as! String
     let name = value["name"] as! String
     let currentUserID = FriendSystem.system.CURRENT_USER_ID
     
     if senderId == currentUserID {
     let message = Message(member: self.member, text: text, messageID: self.messageID)
     self.messages.append(message)
     } else {
     print("This user doesn't have any messages")
     }*/
    
    //OLD:
    //        messages.removeAll() //ref.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
    //        databaseHandle = FriendSystem.system.CURRENT_USER_REF.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
    //            if let value = snapshot.value as? [String:AnyObject] {
    //                let id = value["senderId"] as! String
    //                let text = value["text"] as! String
    //                let name = value["senderDisplayName"] as! String
    //
    //                //let sender = Sender(id: id, displayName: name)
    //
    //
    //                //let message = UserMessage(text: text, sender: sender, messageId: id, date: Date())
    //                let newMessage = Message(member: self.member, text: text, messageID: self.messageID)
    //                self.messages.append(newMessage)
    //
    //                DispatchQueue.main.async {
    //                    self.messagesCollectionView.reloadData()
    //                    self.messagesCollectionView.scrollToBottom()
    //                }
    //            }
    //        })
    //   }
    
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        FriendSystem.system.logoutAccount()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
}



//MARK: - Extensions

//Provide the data to display in messagesVC
extension ChatViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender { //Curent User = Sender
        let id = FriendSystem.system.CURRENT_USER_ID
        let displayName = FriendSystem.system.CURRENT_USER_NAME
        return Sender(id: id, displayName: displayName)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
        
    }
    
    //ADDED 9/24
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 12
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName, attributes: [.font: UIFont.systemFont(ofSize: 12)])
    }
}

//Responds when the send button is tapped
extension ChatViewController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        let messageRef = FriendSystem.system.USER_REF.child("messages").childByAutoId()
        let toId = self.toId
        let fromId = FriendSystem.system.CURRENT_USER_ID
        let name = currentSender().displayName
        let sender = Sender(id: fromId, displayName: name)
        let date = Date()
        let message = Message(text: text, sender: sender, messageId: self.messageID, date: date)
        //let message = Message(toId: toId!, fromId: fromId, name: name, text: text, messageID: self.messageID)
        
        let newMessage = [
            "text" : text,
            "toId": toId,
            "fromId" : currentSender().id,
            "name" : currentSender().displayName
        ]
        
        messageRef.setValue(newMessage)
        messages.append(message)
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom(animated: true)
        
    }
}

extension ChatViewController: MessagesDisplayDelegate, MessagesLayoutDelegate {
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 250
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return .orange
        } else {
            return .lightGray
        }
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        if isFromCurrentSender(message: message) {
            return UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
        } else {
            return UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
        }
    }
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    //    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
    //        let message = messages[indexPath.section]
    //        let color = message.member.color
    //        avatarView.backgroundColor = color
    //    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return .white
        } else {
            return .darkText
        }
    }
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if isFromCurrentSender(message: message) {
            return .bubbleTail(.bottomRight, .curved)
        } else {
            return .bubbleTail(.bottomLeft, .curved)
        }
    }
}
