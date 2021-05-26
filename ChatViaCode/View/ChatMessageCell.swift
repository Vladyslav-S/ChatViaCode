//
//  ChatMessageCell.swift
//  ChatViaCode
//
//  Created by MACsimus on 27.05.2021.
//


import UIKit

class ChatMessageCell: UICollectionViewCell {
    
    let texView: UITextView = {
        let tv = UITextView()
        tv.text = "Some sample the text"
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(texView)
        //constraints x,y,w,h
        texView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        texView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        texView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        texView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
