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
            fetchUserAndSetNavBarTitle()
        }
    }
    
    func fetchUserAndSetNavBarTitle() {
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid ).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                //self.navigationItem.title = dictionary["name"] as? String
                
                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
        
    }
    
    func setupNavBarWithUser(user: User) {
//        let titleView = UIView()
//        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
//        titleView.backgroundColor = UIColor.red
//
//        let containerView = UIView()
//        containerView.translatesAutoresizingMaskIntoConstraints = false
//        titleView.addSubview(containerView)
//
//        let profileImageView = UIImageView()
//        profileImageView.translatesAutoresizingMaskIntoConstraints = false
//        profileImageView.contentMode = .scaleAspectFill
//        profileImageView.layer.cornerRadius = 20
//        profileImageView.clipsToBounds = true
//        if let profileImageUrl = user.profileImageUrl {
//            profileImageView.loadImageUsingCacheWithUrlStrind(urlString: profileImageUrl)
//        }
//
//        containerView.addSubview(profileImageView)
//
//        //ios 9 constraint anchors
//        //need x,y,width,height anchors
//        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
//        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
//        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
//        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
//        let nameLabel = UILabel()
//
//        containerView.addSubview(nameLabel)
//        nameLabel.text = user.name
//        nameLabel.translatesAutoresizingMaskIntoConstraints = false
//        //need x,y,width,height anchors
//        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
//        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
//        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
//        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
//
//        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
//        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
//
//        self.navigationItem.titleView = titleView
//
//        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showChatController)))
//        titleView.isUserInteractionEnabled = true
//
//    }
    
    let button = UIButton(type: .system)
    button.setTitle(user.name, for: .normal)
    button.addTarget(self, action: #selector(showChatController), for: .touchUpInside)
    
    self.navigationItem.titleView = button
}
    
    @objc func showChatController() {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewLayout())
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logOutError {
            print(logOutError)
        }
        
        
        
        let loginController = LoginController()
        loginController.messagesController = self
        loginController.modalPresentationStyle = .fullScreen
        present(loginController, animated: true, completion: nil)
    }

}
