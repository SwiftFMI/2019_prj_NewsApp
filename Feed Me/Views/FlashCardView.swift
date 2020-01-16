//
//  FlashCardView.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 11.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit

class FlashCardView: UIView {
    
    @IBOutlet var rootView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    
    var delegate: NewsArticleCardDelegate?
    var saved: Bool = false
    private var cardColorIndex: Int = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    convenience init (cardColorIndex: Int) {
        self.init(frame:CGRect.zero)
        self.cardColorIndex = cardColorIndex
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        saved = !saved
        setSaveButtonImage()
    }
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        delegate?.shareUrl()
    }
    @IBAction func backButtonPressed(_ sender: UIButton) {
        delegate?.bringBackCard()
    }
}

// MARK: Helper Functions
extension FlashCardView {
    func commonInit() -> Void {
        UINib(nibName: Constants.Xib.flashCard, bundle: .main).instantiate(withOwner: self, options: nil)
        self.addSubview(rootView)
        self.rootView.translatesAutoresizingMaskIntoConstraints = false
        configure()
    }
    
    private func configure() -> Void {
        backgroundColor = Constants.cardColors[0]
        layer.cornerRadius = 20
        clipsToBounds = true
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.6
        layer.shadowOffset = .zero
        layer.shadowRadius = 10
        
        cardImageView.layer.cornerRadius = 20
        cardImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        cardImageView.clipsToBounds = true
    }
    
    private func setSaveButtonImage() {
        if saved {
            saveButton.tintColor = UIColor(named: "Saved Color")
            saveButton.setBackgroundImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        } else {
            saveButton.tintColor = UIColor(named: "Gray")
            saveButton.setBackgroundImage(UIImage(systemName: "bookmark"), for: .normal)
        }
    }
}
