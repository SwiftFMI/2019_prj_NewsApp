//
//  AllNewsTableViewCell.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 1.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit

class AllNewsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.y += 4
            frame.size.height -= 2 * 5
            frame.origin.x += 4
            frame.size.width -= 2 * 5
            super.frame = frame
      }
    }
    
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
extension AllNewsTableViewCell {
    func configure() {
        self.backgroundColor = UIColor(named: "Gray")
        self.layer.cornerRadius = 5
        self.clipsToBounds = true
        
        newsImage.layer.cornerRadius = 5
        newsImage.clipsToBounds = true
    }
}
