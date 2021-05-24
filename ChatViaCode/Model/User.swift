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
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
    }
}
