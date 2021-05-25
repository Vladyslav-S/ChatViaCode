//
//  User.swift
//  ChatViaCode
//
//  Created by MACsimus on 24.05.2021.
//

import UIKit

class User: NSObject {
    var name: String?
    var email: String?
    var profileImageUrl: String?
    
    init(dictionary: [AnyHashable: Any]) {
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
}
