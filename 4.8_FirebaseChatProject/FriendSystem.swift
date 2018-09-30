//
//  FriendSystem.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth

class FriendSystem {
    
    static let system = FriendSystem()
    
    //MARK: - Firebase references
    
    let BASE_REF = Database.database().reference()
    let USER_REF = Database.database().reference().child("users")
    
    var CURRENT_USER_REF: DatabaseReference {
        let id = Auth.auth().currentUser!.uid
        return USER_REF.child("\(id)")
    }
    
    var CURRENT_USER_FRIENDS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("friends")
    }
    
    var CURRENT_USER_REQUESTS_REF: DatabaseReference {
        return CURRENT_USER_REF.child("requests")
    }
    
    var CURRENT_USER_ID: String {
        let id = Auth.auth().currentUser!.uid
        return id
    }
    
    var CURRENT_USER_NAME: String {
        let name = Auth.auth().currentUser!.displayName
        return name!
    }
    
    
    func getCurrentUser(_ completion: @escaping (UserClass) -> Void) {
        CURRENT_USER_REF.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let id = snapshot.key
            completion(UserClass(userEmail: email, userID: id, name: name))
        })
    }
    
    func getUser(_ userID: String, completion: @escaping (UserClass) -> Void) {
        USER_REF.child(userID).observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let id = snapshot.key
            completion(UserClass(userEmail: email, userID: id, name: name))
        })
    }
    
    
    func createAccount(email: String, password: String, name: String, completion: @escaping (_ success: Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
            if (error == nil) {
                var userInfo = [String : AnyObject]()
                userInfo = ["email": email as AnyObject, "name": name as AnyObject]
                self.CURRENT_USER_REF.setValue(userInfo)
                completion(true)
            } else {
                completion(false)
            }
            if let user = user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                
                changeRequest.commitChanges(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                })
            }
        }
    }
    
        
        func setUserName(_ user: User, name: String) {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            
            changeRequest.commitChanges { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                AuthenticationManager.sharedInstance.didLogIn(user: user)
                
            }
        }
    
    
    func loginAccount(_ email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in //AuthDataResult?
            if (error == nil) {
                //Success
                completion(true)
            } else {
                if let error = error  {
                    if error._code == AuthErrorCode.userNotFound.rawValue {
                        //Alert
                    } else if error._code == AuthErrorCode.wrongPassword.rawValue {
                        //Wrong Password Alert
                    }
                } else {
                    //Message - error.localizeddescription
                }
                completion(false)
                print(error!)
            }
            
        }
    }
    
    
    func logoutAccount() {
        let firebaseAuth = Auth.auth()
        
        do {
            try firebaseAuth.signOut()
            AuthenticationManager.sharedInstance.loggedIn = false
            
        } catch let signoutError as NSError {
            print("Error signing out: \(signoutError)")
        }
        //try! Auth.auth().signOut() --- Old Code
    }
    
    
    //MARK: - Requests
    
    //Sends Friend Request to the user with the specified id
    func sendRequestToUser(_ userID: String) {
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).setValue(true)
        
    }
    //Unfriends the user with the specified id
    func removeFriend(_ userID: String) {
        CURRENT_USER_REF.child("friends").child(userID).removeValue()
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).removeValue()
    }
    
    
    //Accept Friend Request from user with userID
    func acceptFriendRequest(_ userID: String) {
        CURRENT_USER_REF.child("requests").child(userID).removeValue()
        CURRENT_USER_REF.child("friends").child(userID).setValue(true)
        USER_REF.child(userID).child("friends").child(CURRENT_USER_ID).setValue(true)
        USER_REF.child(userID).child("requests").child(CURRENT_USER_ID).removeValue()
    }
    
    
    //MARK: - All Users
    var userList = [UserClass]()
    
    func addUserObserver(_ update: @escaping () -> Void) {
        FriendSystem.system.USER_REF.observe(DataEventType.value, with: { (snapshot) in
            self.userList.removeAll()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                guard let dictionary = child.value as? [String:AnyObject] else {
                    print("Dictionary Empty - UserObserver")
                    return
                }
                
                guard let email = dictionary["email"] as? String else {
                    print("Thinks Dictionary Is blank?!?!?!")
                    return
                }
                
                guard let name = dictionary["name"] as? String else {
                    return
                }
                
                //let email = dictionary["email"] as? String
                //let email = child.childSnapshot(forPath: "email").value as! String
                if email != Auth.auth().currentUser?.email! {
                    self.userList.append(UserClass(userEmail: email, userID: child.key, name: name))
                    print("ID's from Friend System AddUserObserver: \(child.key)")
                }
            }
            update()
        })
    }
    
    func removeUserObserver() {
        USER_REF.removeAllObservers()
        
    }
    
    
    
    //MARK: - All Friends
    
    var friendsList = [UserClass]()
    
    func addFriendObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_FRIENDS_REF.observe(DataEventType.value, with: { (snapshot) in
            self.friendsList.removeAll()
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.friendsList.append(user)
                    update()
                })
            }
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    
    //Remove Observers
    func removeFriendObserver() {
        CURRENT_USER_FRIENDS_REF.removeAllObservers()
    }
    
    
    //MARK: - All Requests
    //List of all the friend requests the current user has
    var requestList = [UserClass]()
    
    func addRequestObserver(_ update: @escaping () -> Void) {
        CURRENT_USER_REQUESTS_REF.observe(DataEventType.value, with: { (snapshot) in
            
            //self.requestList.removeAll()
            
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let id = child.key
                self.getUser(id, completion: { (user) in
                    self.requestList.append(user)
                    update()
                })
            }
            if snapshot.childrenCount == 0 {
                update()
            }
        })
    }
    
    func removeRequestObserver() {
        CURRENT_USER_REQUESTS_REF.removeAllObservers()
    }
}

//LOG OUT CODE:

/* func loginAccount(_ email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
 Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
 
 if (error == nil) {
 // Success
 completion(true)
 } else {
 // Failure
 completion(false)
 print(error!)
 }
 
 })
 }*/

/*@IBAction func logOut(sender: UIBarButtonItem) {
 let firebaseAuth = Auth.auth()
 do {
 try firebaseAuth.signOut()
 AuthenticationManager.sharedInstance.loggedIn = false
 dismiss(animated: true, completion: nil)
 } catch let signOutError as NSError {
 print ("Error signing out: \(signOutError)")
 }
 }
 }*/

/* CREATE ACCOUNT CODE:
 //_ user: User,
 //    func createAccount(_ user: User, email: String, name: String, completion: @escaping (_ success: Bool) -> Void) {
 //        let user = User
 //        let changeRequest = user!.createProfileChangeRequest()
 //        changeRequest.displayName = name
 //
 //        changeRequest.commitChanges { (error) in
 //            if let error = error {
 //                print(error.localizedDescription)
 //                return
 //            }
 //            AuthenticationManager.sharedInstance.didLogIn(user: user!)
 //        }
 
 //        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
 //            if (error == nil) {
 //                //Success
 //                var userInfo = [String : AnyObject]()
 //                userInfo = ["email": email as AnyObject, "name": name as AnyObject]
 //                self.USER_REF.setValue(userInfo)
 //                completion(true)
 //            } else {
 //                //Failure
 //                completion(false)
 //            }
 //        }
 //END OF CREATE ACCOUNT
 
 /*var userInfo = [String : AnyObject]()
 userInfo = ["email": email as AnyObject, "name": name as AnyObject]
 self.CURRENT_USER_REF.setValue(userInfo)
 completion(true)
 } else {
 //Failure
 completion(false)*/*/
