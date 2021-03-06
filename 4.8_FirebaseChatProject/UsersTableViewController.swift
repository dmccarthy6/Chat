//
//  UsersTableViewController.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import UIKit
import Firebase

class UsersTableViewController: UIViewController, UITableViewDelegate {

    //MARK: - IB Outlets:
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var currentUserLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bundle = Bundle(for: type(of: self))
        let cellNib = UINib(nibName: "UserCell", bundle: bundle)
        self.tableView.register(cellNib, forCellReuseIdentifier: "UsersCell")

        FriendSystem.system.getCurrentUser { (user) in
            let name = user.name
            self.currentUserLabel.textColor = .red
            self.currentUserLabel.font.withSize(25)
           self.currentUserLabel.text = "\(name!)"
        }

        FriendSystem.system.addUserObserver {
            self.tableView.reloadData()
        }
    }
    

    //MARK: - IB Actions
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            AuthenticationManager.sharedInstance.loggedIn = false
            
        } catch let signoutError as NSError {
            print("Error signing out: \(signoutError)")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func sendAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}


extension UsersTableViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendSystem.system.userList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //Create Cell
        var cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell", for: indexPath) as? UserCell
        
        if cell == nil {
            self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UsersCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell") as? UserCell
        }
        cell!.emailLabel.text = FriendSystem.system.userList[indexPath.row].email
        
        cell?.setFunction {
            let id = FriendSystem.system.userList[indexPath.row].id
            let name = FriendSystem.system.userList[indexPath.row].name
            FriendSystem.system.sendRequestToUser(id!)
            self.sendAlert(title: "Request Sent", message: "Friend request sent to \(name!)")
        }
        return cell!
    }
}
