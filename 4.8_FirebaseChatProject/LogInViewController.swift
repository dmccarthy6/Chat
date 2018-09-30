//
//  LogInViewController.swift
//  4.8_FirebaseChatProject
//
//  Created by DYLAN MCCARTHY on 9/16/18.
//  Copyright © 2018 DYLAN MCCARTHY. All rights reserved.
//

import UIKit
import Firebase

class LogInViewController: UIViewController {

    //MARK: - Outlets
    
    //Sign Up Outlets
    @IBOutlet weak var signUpNameTextField: UITextField!
    @IBOutlet weak var signUpEmailTextField: UITextField!
    @IBOutlet weak var signUpPasswordTextField: UITextField!
    
    
    //Login Outlets
    @IBOutlet weak var loginEmailTextField: UITextField!
    @IBOutlet weak var loginPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    //MARK: - IB Actions
    
    @IBAction func didTapLoginButton(_ sender: UIButton) {
        
        //USER LOGGING IN - ALREADY HAS USERNAME ETC
        guard let email = loginEmailTextField.text, let password = loginPasswordTextField.text, let name = signUpNameTextField.text, email.characters.count > 0, password.characters.count > 6 else {
            self.showAlert(message: "Please Enter A User Name & Password")
            return
        }
        
        
        FriendSystem.system.loginAccount(email, password: password, completion: { (success) in
            if success {
                self.performSegue(withIdentifier: "signupComplete", sender: self)
            } else {
                print("Could Not Sign Up")
            }
        })
    }
    
    
    @IBAction func didTapSignUpButton(_ sender: UIButton) {
        let name = signUpNameTextField.text!
        let email = signUpEmailTextField.text!
        let password = signUpPasswordTextField.text!
        
        FriendSystem.system.createAccount(email: email, password: password, name: name) { (success) in
            if success {
                FriendSystem.system.loginAccount(email, password: password, completion: { (success) in
                    if success {
                        self.performSegue(withIdentifier: "signupComplete", sender: self)
                    } else {
                        print("Could Not Sign Up")
                    }
                })
            } else {
                print("Could Not Log In")
            }
        }
    }
    
    
    //ALERT FUNCTION
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Alert Title", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}
