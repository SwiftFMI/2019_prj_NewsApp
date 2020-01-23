//
//  NewsArticleView.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 27.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Koloda

// TODO: saving articles for later logic
// TODO: change the font of the meta data

class NewsArticleCardView: UIView {
    
    var delegate: NewsArticleCardDelegate?
    
// MARK: Initializers
    var publishedAtLabel: UILabel! = {
        var perm = UILabel()
        
        perm.textColor = UIColor(named: "Gray")
        perm.font = UIFont(name: "Helvetica Neue", size: 14)
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    private var publishedAtImage: UIImageView! = {
        var perm = UIImageView()
        
        perm.image = UIImage(systemName: "clock")
        perm.tintColor = UIColor(named: "Gray")
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    var authorLabel: UILabel! = {
        var perm = UILabel()
        
        perm.textColor = UIColor(named: "Gray")
        perm.font = UIFont(name: "Helvetica Neue", size: 14)
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    private var authorImage: UIImageView! = {
        var perm = UIImageView()
        
        perm.image = UIImage(systemName: "person.fill")
        perm.tintColor = UIColor(named: "Gray")
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    private var titleContainer: UIView! = {
        var perm = UIView()
        
        perm.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    private var footerContainer: UIView! = {
        var perm = UIView()
        
        perm.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        
        perm.layer.cornerRadius = 20
        perm.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        perm.clipsToBounds = true
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    var title: UILabel! = {
        let perm = UILabel()
        perm.textColor = UIColor.white
        perm.numberOfLines = 0
        perm.font = UIFont.boldSystemFont(ofSize: 20)
        perm.numberOfLines = 4
        
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
    
    private var saveButton: UIButton! = {
        var perm = UIButton()
        
        perm.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
        perm.tintColor = UIColor(named: "Gray")
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    private var shareButton: UIButton! = {
        var perm = UIButton()
        
        perm.setBackgroundImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        perm.tintColor = UIColor(named: "Gray")
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    private var revertButton: UIButton! = {
        var perm = UIButton()
        
        perm.setBackgroundImage(UIImage(systemName: "backward"), for: .normal)
        perm.tintColor = UIColor(named: "Gray")
        
        // enable auto layout
        perm.translatesAutoresizingMaskIntoConstraints = false
        
        return perm
    }()
    
    var saved: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure(cardColorIndex: 0)
    }
    
    convenience init (cardColorIndex: Int) {
        self.init(frame:CGRect.zero)
        configure(cardColorIndex: cardColorIndex)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
// MARK: Configure Method
    func configure(cardColorIndex: Int) {
        backgroundColor = Constants.cardColors[cardColorIndex]
        layer.cornerRadius = 20
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        
        titleContainer.addSubview(title)
        footerContainer.addSubview(saveButton)
        footerContainer.addSubview(shareButton)
        footerContainer.addSubview(revertButton)
        
        addSubview(image)
        addSubview(titleContainer)
        addSubview(footerContainer)
        addSubview(publishedAtImage)
        addSubview(publishedAtLabel)
        addSubview(authorImage)
        addSubview(authorLabel)
        addSubview(desc)
        
        configureHeader()
        configureFooter()
        configureBody()
    }
    
// MARK: Configure Header
    private func configureHeader() {
        titleContainer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        titleContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        titleContainer.bottomAnchor.constraint(equalTo: image.bottomAnchor).isActive = true
        titleContainer.heightAnchor.constraint(equalTo: title.heightAnchor, constant: 40).isActive = true
        
        title.leadingAnchor.constraint(equalTo: title.superview!.leadingAnchor, constant: 20).isActive = true
        title.trailingAnchor.constraint(equalTo: title.superview!.trailingAnchor, constant: -20).isActive = true
        title.bottomAnchor.constraint(equalTo: title.superview!.bottomAnchor, constant: -20).isActive = true
        
        image.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        image.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        image.topAnchor.constraint(equalTo: topAnchor).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: 9/16).isActive = true
    }
    
// MARK: Configure Body
    private func configureBody() {
        publishedAtImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        publishedAtImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
        publishedAtImage.heightAnchor.constraint(equalTo: publishedAtImage.widthAnchor).isActive = true
        publishedAtImage.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 10).isActive = true
        
        publishedAtLabel.leadingAnchor.constraint(equalTo: publishedAtImage.trailingAnchor, constant: 5).isActive = true
        publishedAtLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        publishedAtLabel.centerYAnchor.constraint(equalTo: publishedAtImage.centerYAnchor).isActive = true
        
        authorImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        authorImage.widthAnchor.constraint(equalToConstant: 15).isActive = true
        authorImage.heightAnchor.constraint(equalTo: authorImage.widthAnchor).isActive = true
        authorImage.topAnchor.constraint(equalTo: publishedAtImage.bottomAnchor, constant: 5).isActive = true

        authorLabel.leadingAnchor.constraint(equalTo: authorImage.trailingAnchor, constant: 5).isActive = true
        authorLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        authorLabel.centerYAnchor.constraint(equalTo: authorImage.centerYAnchor).isActive = true
     
        desc.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        desc.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
        desc.topAnchor.constraint(equalTo: authorImage.bottomAnchor, constant: 10).isActive = true
        desc.bottomAnchor.constraint(lessThanOrEqualTo: footerContainer.topAnchor).isActive = true
    }
    
// MARK: Configure Footer
    private func configureFooter() {
        // constraints
        footerContainer.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        footerContainer.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        footerContainer.heightAnchor.constraint(equalTo: saveButton.heightAnchor, constant: 40).isActive = true
        footerContainer.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        saveButton.leadingAnchor.constraint(equalTo: saveButton.superview!.leadingAnchor, constant: 30).isActive = true
        saveButton.centerYAnchor.constraint(equalTo: saveButton.superview!.centerYAnchor).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        saveButton.widthAnchor.constraint(equalTo: saveButton.heightAnchor, multiplier: 0.8).isActive = true
        
        shareButton.leadingAnchor.constraint(equalTo: saveButton.trailingAnchor, constant: 20).isActive = true
        shareButton.centerYAnchor.constraint(equalTo: shareButton.superview!.centerYAnchor).isActive = true
        shareButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        shareButton.widthAnchor.constraint(equalTo: shareButton.heightAnchor, multiplier: 0.8).isActive = true
        
        revertButton.trailingAnchor.constraint(equalTo: revertButton.superview!.trailingAnchor, constant: -30).isActive = true
        revertButton.centerYAnchor.constraint(equalTo: revertButton.superview!.centerYAnchor).isActive = true
        revertButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        revertButton.heightAnchor.constraint(equalTo: revertButton.widthAnchor).isActive = true
        
        // actions
        revertButton.addTarget(self, action: #selector(bringPrevCard), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(toggleSaved), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(openShareSheet), for: .touchUpInside)
    }
    
    
    func setSaveButtonImage() {
        if saved {
            saveButton.tintColor = UIColor(named: "Saved Color")
            saveButton.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            saveButton.tintColor = UIColor(named: "Gray")
            saveButton.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    }
}

// MARK: Obj C Selectors
extension NewsArticleCardView {
    @objc func bringPrevCard() {
        delegate?.bringBackCard()
    }
    
    @objc func toggleSaved() {
        print("Saved status: \(saved)")
        if saved {
            delegate?.unsaveArticle() { (isUnsaved) in
                if isUnsaved {
                    self.saved = !self.saved
                    self.setSaveButtonImage()
                }
            }
        } else {
            delegate?.saveArticle() { (isSaved) in
                if isSaved {
                    self.saved = !self.saved
                    self.setSaveButtonImage()
                }
            }
        }
    }
    
    @objc func openShareSheet() {
        delegate?.shareUrl()
    }
}
