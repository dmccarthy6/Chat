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
        messageSentTo = user
    }
    
    
    //MARK: - Properties
    
    var messages: [Message] = []
    var ref: DatabaseReference!
    private var databaseHandle: DatabaseHandle!
    var member: Member!
    var user: UserClass?
    var messageSentTo: String?
    
    var messageID: String = {
        var uuid = UUID().uuidString
        return uuid
    }()
    
    //MARK: - Outlets
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //Create a Member
        createMember()
        
        messageDelegates()
        
        let vc = FriendsListTableViewController()
        vc.delegate = self
        
    }

    override func viewWillAppear(_ animated: Bool) {
        
        view.backgroundColor = UIColor.orange
        loadMessages()
    }
    
    func messageDelegates() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        ref = Database.database().reference()
    }
    
    func loadMessages() {
        //Get Current UserID - Show messages for that user.
        let currentUserID = FriendSystem.system.CURRENT_USER_ID
        print("This is Current UserID: \(currentUserID)")
        
        messages.removeAll()
        databaseHandle = ref.child("messages").observe(.childAdded, with: { (snapshot) -> Void in
            if let value = snapshot.value as? [String : AnyObject] {
                let senderId = value[""] //This is Sender Name
                let text = value["text"]
                let name = value["name"]
            }
            
            
        })
    }
    
    func createMember() {
        let currentName = FriendSystem.system.CURRENT_USER_NAME
        let currentID = FriendSystem.system.CURRENT_USER_ID
        let color = UIColor.blue
        
        member = Member(name: currentName, color: color, senderID: currentID)
    }
        
        
        
        
        
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
        
        //Logout Here
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
        member.senderID = FriendSystem.system.CURRENT_USER_ID
        //COMMENTED ABOVE 9/24 - Changed below id: & displayName: values)
        
        print("MessageSentTo from, ChatVC CurrentSender(): \(messageSentTo!)")
        return Sender(id: member.senderID, displayName: messageSentTo!)
        
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
        let messageRef = FriendSystem.system.CURRENT_USER_REF.child("messages").childByAutoId()
        
        let message = Message(member: member, text: text, messageID: self.messageID)
        

        let fireMsg = [
            "text" : text,
            "senderId": currentSender().id,
            "name" : currentSender().displayName
        ]

        messageRef.setValue(fireMsg)
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
