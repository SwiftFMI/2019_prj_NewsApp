//
//  Styling.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 24.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation
import UIKit

func stylePrimaryButton(button: UIButton) {
    styleButton(button: button, textColor: UIColor.white, bgColor: UIColor(named: "Primary Color")!)
}

func styleSecondaryButton(button: UIButton) {
    styleButton(button: button, textColor: UIColor.black, bgColor: UIColor(named: "Secondary Color")!)
}

func styleButton(button: UIButton, textColor: UIColor, bgColor: UIColor) {
    button.setTitleColor(textColor, for: .normal)
    button.backgroundColor = bgColor
    button.layer.cornerRadius = button.frame.height * 0.5
}

func styleTextField(field: UITextField) {
    // corner radius
    field.layer.cornerRadius = field.frame.height * 0.5
    field.clipsToBounds = true
    // border
    field.layer.borderWidth = 2
    field.layer.borderColor = UIColor(named: "Secondary Color")?.cgColor
}
