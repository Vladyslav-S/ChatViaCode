//
//  ViewController.swift
//  ChatViaCode
//
//  Created by MACsimus on 24.05.2021.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        
        checkIfUserIsLoggedIn()
        
    }
    
    @objc func handleNewMessage() {
        
        let newMessageController = NewMessageController()
        let navController = UINavigationController(rootViewController: newMessageController)
        navController.modalPresentationStyle = .fullScreen
        present(navController, animated: true, completion: nil)
        
    }
    
    func checkIfUserIsLoggedIn() {
        // user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(handleLogout), with: self, afterDelay: 0)
            //handleLogout()         //Unbalanced calls to begin/end appearance transitions for <UINavigationController: 0x106817600>.
        } else {
            let uid = Auth.auth().currentUser?.uid
            Database.database().reference().child("users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                print(snapshot)
                
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.navigationItem.title = dictionary["name"] as? String
                }
                
            }, withCancel: nil)
        }
    }
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logOutError {
            print(logOutError)
        }
        
        
        
        let loginController = LoginController()
        loginController.modalPresentationStyle = .fullScreen
        present(loginController, animated: true, completion: nil)
    }

}
