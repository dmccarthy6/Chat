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

struct Member {
    var name: String
    var color: UIColor
    var senderID: String
}

struct Message {
    let member: Member
    let text: String
    let messageID: String
}

extension Message: MessageType {
    var messageId: String {
        return UUID().uuidString
    }
    
    var sender: Sender {
        return Sender(id: member.name, displayName: member.name)
    }
    
    
    
    var sentDate: Date {
        return Date()
    }
    
    var kind: MessageKind {
        return .text(text)
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
