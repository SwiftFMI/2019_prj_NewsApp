//
//  ProfileCollectionViewCell.swift
//  News Flash
//
//  Created by Victoria Tsvetanova on 28.02.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit

class ProfileCollectionViewCell: UICollectionViewCell {
    
    static let CELL_IDENTIFIER = "ProfileCollectionViewCell"

    @IBOutlet var textLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func populate(with text: String, with imageName: String) {
        
        textLabel.text = text
        imageView.image = UIImage(named: imageName)
        
    }

}
