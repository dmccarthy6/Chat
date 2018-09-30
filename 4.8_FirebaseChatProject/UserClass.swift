//
//  UserClass.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import Foundation
import UIKit

class UserClass {
    
    var email: String!
    var id: String!
    var name: String!
    
    init(userEmail: String, userID: String, name: String) {
        self.email = userEmail
        self.id = userID
        self.name = name
    }

    
}
