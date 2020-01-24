//
//  AllNewsTableViewCell.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 1.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit

class NewsArticleTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    var saved: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        configure()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

// MARK: Helper Functions
extension NewsArticleTableViewCell {
    func configure() {
        newsImage.layer.cornerRadius = 5
        newsImage.clipsToBounds = true
    }
}
