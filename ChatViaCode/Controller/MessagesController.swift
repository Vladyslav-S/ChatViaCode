//
//  ViewController.swift
//  ChatViaCode
//
//  Created by MACsimus on 24.05.2021.
//

import UIKit
import Firebase

class MessagesController: UITableViewController {

    let cellId = "cellId"
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(handleNewMessage))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))

        checkIfUserIsLoggedIn()

        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

        //   observeMessages()
    }

    var messages = [Message]()
    var messagesDictionary = [String: Message]()

    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in

            let messageId = snapshot.key
            let messageReference = Database.database().reference().child("messages").child(messageId)

            messageReference.observeSingleEvent(of: .value, with: { (snapshot) in

                if let dictionary = snapshot.value as? [String: AnyObject] {
                    let message = Message(dictionary: dictionary)

                    //self.messages.append(message)

                    if let chatPartnerId = message.chatPartnerId() {
                        self.messagesDictionary[chatPartnerId] = message

                        self.messages = Array(self.messagesDictionary.values)
                        self.messages.sort { (message1, message2) -> Bool in

                            //guard let timestamp1 = message1.timestamp, let timestamp2 = message2.timestamp else { return false }

                            //return timestamp1.intValue > timestamp2.intValue
                            return message1.timestamp!.intValue > message2.timestamp!.intValue
                        }
                    }
                    //                    DispatchQueue.main.async {
                    //                        self.tableView.reloadData()
                    //                    }
                    self.timer?.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
                }

            }, withCancel: nil)

        }, withCancel: nil)
    }

    var timer: Timer?
    @objc func handleReloadTable () {
        DispatchQueue.main.async {
            print("R E L O A D E D")
            self.tableView.reloadData()
        }
    }

    func observeMessages() {
        let ref = Database.database().reference().child("messages")
        ref.observe(.childAdded, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {

                let message = Message(dictionary: dictionary)
                //self.messages.append(message)

                if let toId = message.toId {
                    self.messagesDictionary[toId] = message

                    self.messages = Array(self.messagesDictionary.values)
                    self.messages.sort { (message1, message2) -> Bool in

                        //guard let timestamp1 = message1.timestamp, let timestamp2 = message2.timestamp else { return false }

                        //return timestamp1.intValue > timestamp2.intValue
                        return message1.timestamp!.intValue > message2.timestamp!.intValue
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                //                self.timer?.invalidate()
                //                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.handleReloadTable), userInfo: nil, repeats: false)
            }
        }, withCancel: nil)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell

        let message = messages[indexPath.row]
        cell.message = message

        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]

        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref .observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String: AnyObject ]else {
                return
            }

            let user = User(dictionary: dictionary)
            user.id = chatPartnerId
            self.showChatControllerForUser(user: user)


        }, withCancel: nil)
        //        showChatControllerForUser(user: <#T##User#>)
    }

    func fetchUserAndSetNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid ).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)


            if let dictionary = snapshot.value as? [String: AnyObject] {
                //self.navigationItem.title = dictionary["name"] as? String

                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user: user)
                //self.showChatControllerForUser(user: user)
            }

        }, withCancel: nil)

    }

    func setupNavBarWithUser(user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        tableView.reloadData()

        observeUserMessages()

        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        //        titleView.backgroundColor = UIColor.red

        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)

        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlStrind(urlString: profileImageUrl)
        }

        containerView.addSubview(profileImageView)

        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let nameLabel = UILabel()

        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true

        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true

        self.navigationItem.titleView = titleView

    }

    @objc func handleNewMessage() {
        let newMessageController = NewMessageController()
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        //        navController.modalPresentationStyle = .fullScreen
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

    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            //for some reason uid = nil
            return
        }

        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in

            if let dictionary = snapshot.value as? [String: AnyObject] {
                //                self.navigationItem.title = dictionary["name"] as? String

                let user = User(dictionary: dictionary)
                self.setupNavBarWithUser(user: user)
            }

        }, withCancel: nil)
    }

    @objc func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())

        chatLogController.user = user
        //chatLogController.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(chatLogController, animated: true)
    }

    @objc func handleLogout() {

        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }

        let loginController = LoginController()
        loginController.messagesController = self

        loginController.modalPresentationStyle = .fullScreen
        present(loginController, animated: true, completion: nil)
    }

}
