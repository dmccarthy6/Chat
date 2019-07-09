//
//  UserMessage.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/24/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import MessageKit

//struct UserMessage {
//    var text: String
//    var userName:
//}
let member = Member(name: FriendSystem.system.CURRENT_USER_NAME, senderID: FriendSystem.system.CURRENT_USER_ID)
struct Member {
    var name: String
    var senderID: String
}

//struct Message {
//    let toId: String
//    let fromId: String
//    let name: String
//    var text: String
//    let messageID: String
//}
//
//extension Message: MessageType {
//    var messageId: String {
//        return UUID().uuidString
//    }
//
//    var sender: Sender {
//
//        return Sender(id: member.senderID, displayName: member.name)
//    }
//
//
//
//    var sentDate: Date {
//        return Date()
//    }
//
//    var kind: MessageKind {
//        return .text(text)
//    }

    
struct Message: MessageType {
    var messageId: String
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
}

//class UserMessage: MessageType {
//    var sender: Sender
//    var messageId: String//unique id for message
//    var sentDate: Date
//    var kind: MessageKind
//    var text: String
//
//
//
//    init(sender: Sender, messageId: String, sentDate: Date, kind: MessageKind, text: String) {
//        //MessageKind = text or attributedText
//        self.sender = sender
//        self.messageId = messageId
//        self.sentDate = sentDate
//        self.kind = kind
//        self.text = text
//    }
//
//    convenience init(sender: Sender, messageId: String, sentDate: Date, messageKind: MessageKind) {
//        self.init(sender: sender, messageId:  messageId, sentDate: sentDate, messageKind: .text(text))
//    }
//
//}

