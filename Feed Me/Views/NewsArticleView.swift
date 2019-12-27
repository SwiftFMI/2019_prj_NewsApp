//
//  NewsArticleView.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 27.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Koloda

class NewsArticleView: UIView {
    
    var headerContainer: UIView! = {
        var perm = UIView()
        
        perm.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    var title: UILabel! = {
        let perm = UILabel()
        perm.textColor = UIColor.white
        perm.numberOfLines = 0
        perm.font = UIFont.boldSystemFont(ofSize: 20)
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    var desc: UILabel! = {
        let perm = UILabel()
        perm.textColor = UIColor.black
        perm.numberOfLines = 0
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    var image: UIImageView! = {
        let perm = UIImageView()
        
        perm.layer.cornerRadius = 20
        perm.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        perm.clipsToBounds = true
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = UIColor(named: "Secondary Color")
        layer.cornerRadius = 20
        
        headerContainer.addSubview(title)
        
        addSubview(image)
        addSubview(headerContainer)
        addSubview(desc)
        
        image.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        image.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 9/16).isActive = true
        
        headerContainer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        headerContainer.bottomAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        headerContainer.heightAnchor.constraint(equalTo: title.heightAnchor, constant: 40).isActive = true
        
        title.leadingAnchor.constraint(equalTo: title.superview!.leadingAnchor, constant: 20).isActive = true
        title.trailingAnchor.constraint(equalTo: title.superview!.trailingAnchor, constant: -20).isActive = true
        title.bottomAnchor.constraint(equalTo: title.superview!.bottomAnchor, constant: -20).isActive = true
        
        desc.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        desc.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        desc.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 30).isActive = true
    }
}
