//
//  Message.swift
//  ChatViaCode
//
//  Created by MACsimus on 26.05.2021.
//

import UIKit

class Message: NSObject {

    var fromId: String?
    var text: String?
    var timestamp: NSNumber?  //Int?
    var toId: String?
    
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
    }
}
