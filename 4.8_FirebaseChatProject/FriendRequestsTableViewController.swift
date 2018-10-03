//
//  FriendRequestsTableViewController.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import UIKit

class FriendRequestsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FriendSystem.system.addRequestObserver {
            print("Request List From View Did Load in Reqiests VC: \(FriendSystem.system.requestList)")
            self.tableView.reloadData()
        }
        
        let bundle = Bundle(for: type(of: self))
        let cellNib = UINib(nibName: "UserCell", bundle: bundle)
        self.tableView.register(cellNib, forCellReuseIdentifier: "UsersCell")
        
        tableView.delegate = self
        tableView.dataSource = self
    }


    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return FriendSystem.system.requestList.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell", for: indexPath) as? UserCell

        if cell == nil {
            tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
            cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell
        }
        
        cell!.emailLabel.text = FriendSystem.system.requestList[indexPath.row].email
        cell!.cellButton.setTitle("Accept", for: UIControlState())
        
        cell!.setFunction {
            let id = FriendSystem.system.requestList[indexPath.row].id
            FriendSystem.system.acceptFriendRequest(id!)
            
            //Segue to Friends List Here?
        }
        
        let id = FriendSystem.system.requestList[indexPath.row].id
        print("ID from Friend Requests: \(id!)")
        
        return cell!
    }
   

   

}
