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
    let fromId = FriendSystem.system.CURRENT_USER_ID
    var myUser = UserClass()
    
    var messageID: String = {
        var uuid = UUID().uuidString
        return uuid
    }()
    
    var user: UserClass? {
        didSet {
            navigationItem.title = user?.name
        }
    }
    
    var MESSAGE_RECEIVER_REF: DatabaseReference {
        let id = self.toId!
        return FriendSystem.system.USER_REF.child("\(id)")
    }
    
    //MARK: - Outlets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messageDelegates()
        
        print("This is ToID from Chat VC (Value Passed): \(toId!)")
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
        
        let currentUser = self.fromId
        guard let chatReceiver = self.toId else { return }
        let chatRoomId = (currentUser < chatReceiver) ? currentUser + "_" + chatReceiver : chatReceiver + "_" + currentUser
        
        FriendSystem.system.CHAT_ROOM_REF.observe(.childAdded, with: { (snapshot) in
            print("HIT INSIDE REFERENCE")
            let id = snapshot.key
            if id.contains(currentUser) && id.contains(chatReceiver) {
                FriendSystem.system.CHAT_ROOM_REF.child(chatRoomId).observe(.childAdded, with: { (snapshot) in
                    print("This works")
                    if let dictionary = snapshot.value as? [String:AnyObject] {
                        print("Hit IF STATEMENT")
                        //let toId = dictionary["toId"] as! String
                        let fromId = dictionary["fromId"] as! String
                        let text = dictionary["text"] as! String
                        let name = dictionary["name"] as! String
                        let sender = Sender(id: fromId, displayName: name)
                        let message = Message(text: text, sender: sender, messageId: self.messageID, date: Date())
                        self.messages.append(message)
                        print("THIS IS SNAPSHOT - \(dictionary)")
                        
                        DispatchQueue.main.async {
                            self.messagesCollectionView.reloadData()
                            self.messagesCollectionView.scrollToBottom()
                        }
                    }
                })
            } else {
                print("There are no messages for this user")
                return
            }
        })
    }
    
    
    
    
    
    @IBAction func logoutButtonTapped(_ sender: UIBarButtonItem) {
        FriendSystem.system.logoutAccount()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
} //CLASS



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
        guard let childToId = self.toId else {return}
        let childFromId = self.fromId
        
        let chatRoomId = (childFromId < childToId) ? childFromId + "_" + childToId : childToId + "_" + childFromId
        
        let messageRef = FriendSystem.system.CHAT_ROOM_REF.child(chatRoomId).childByAutoId()
        let toId = self.toId!
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



//        let toId = self.toId
//        let query = FriendSystem.system.USER_REF.child("messages").queryEqual(toValue: toId!)
//        query.observe(.value) { (snapshot) in
//            for child in snapshot.children {
//                if let database = snapshot.value as? [String : AnyObject] {
//                    let toId = database["toId"] as! String
//                    let fromId = database["fromId"] as! String
//                    let name = database["name"] as! String
//                    let message = database["text"] as! String
//
//                    let date = Date()
//                    let sender = Sender(id: fromId, displayName: name)
//                    let messageId = self.messageID
//
//                    let userMessages = Message(text: message, sender: sender, messageId: messageId, date: date)
//                    self.messages.append(userMessages)
//
//                    DispatchQueue.main.async {
//                        self.messagesCollectionView.reloadData()
//                        self.messagesCollectionView.scrollToBottom()
//                    }
//                }
//
//            }
//        }
//    }


//        /* databaseHandle = */MESSAGE_RECEIVER_REF.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
//            if let value = snapshot.value as? [String : AnyObject] {
//                print("Load Messages Snapshot - \(snapshot)")
//                let toId = value["toId"] as! String
//                let fromId = value["fromId"] as! String
//                let text = value["text"] as! String
//                let name = value["name"] as! String
//                //let messageId = value["messageId"] as! String
//                let sender = Sender(id: fromId, displayName: name)
//                let date = Date()
//                let message = Message(text: text, sender: sender, messageId: self.messageID, date: date)
//
//                //let message = Message(toId: toId, fromId: fromId, name: name, text: text, messageID: self.messageID)
//                self.messages.append(message)
//
//                DispatchQueue.main.async {
//                    self.messagesCollectionView.reloadData()
//                    self.messagesCollectionView.scrollToBottom()
//                }
//            }
//        })
//    }

/*/* databaseHandle = */FriendSystem.system.BASE_REF.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
 if let value = snapshot.value as? [String : AnyObject] {
 print("Load Messages Snapshot - \(snapshot)")
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
 
 DispatchQueue.main.async {
 self.messagesCollectionView.reloadData()
 self.messagesCollectionView.scrollToBottom()
 }
 }
 })
 }*/
/*func loadApplicants() {
 let jobID = job.postID
 let appRef = ref.child("jobs").child(jobID!).child("applicants")
 appRef.queryOrderedByKey().observeSingleEvent(of: .childAdded, with: { (snapshot) in
 if let applicants = snapshot.value! as? [String:AnyObject] {
 for (value) in applicants {
 self.authService.fetchApplicants(applicantID: "\(value!)", completion: { (users) in
 self.usersArray = users
 self.tableView.reloadData()
 })
 }
 }
 })
 }*/

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

