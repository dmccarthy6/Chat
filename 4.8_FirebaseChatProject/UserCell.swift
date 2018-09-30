//
//  UserCell.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import UIKit
import Foundation

class UserCell: UITableViewCell {

    //MARK: - Outlets
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var cellButton: UIButton!
    
    
 
    //MARK: - Properties
    var buttonFunc: (() -> (Void))!
    
    
    //MARK: - IB Actions
    @IBAction func cellButtonTapped(_ sender: UIButton) {
        buttonFunc()
    }
    
    func setFunction(_ function: @escaping () -> Void) {
        self.buttonFunc = function
    }
    
}
