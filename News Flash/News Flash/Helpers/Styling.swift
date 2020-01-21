//
//  Styling.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 24.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation
import UIKit
import SkyFloatingLabelTextField

// MARK: Buttons
func stylePrimaryButton(_ button: UIButton) {
    styleButton(button, textColor: UIColor.white, bgColor: UIColor(named: "Primary Color")!)
}

func stylePrimaryTextButton(_ button: UIButton) {
    button.setTitleColor(UIColor(named: "Primary Color"), for: .normal)
}

func styleSecondaryButton(_ button: UIButton) {
    styleButton(button, textColor: UIColor.black, bgColor: UIColor(named: "Gray")!)
}

func styleDangerButton(_ button: UIButton) {
    styleButton(button, textColor: .white, bgColor: .red)
}

func styleButton(_ button: UIButton, textColor: UIColor, bgColor: UIColor) {
    button.setTitleColor(textColor, for: .normal)
    button.backgroundColor = bgColor
    button.layer.cornerRadius = button.frame.height * 0.5
    button.clipsToBounds = true
}

// MARK: Pills
func stylePrimaryPill(_ button: UIButton) {
    stylePill(button, textColor: UIColor(named: "Primary Color")!, borderColor: UIColor(named: "Primary Color")!)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
}

func styleSecondaryPill(_ button: UIButton) {
    stylePill(button, textColor: UIColor.white, borderColor: UIColor(named: "Gray")!)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
}

func stylePill(_ button: UIButton, textColor: UIColor, borderColor: UIColor) {
    button.setTitleColor(textColor, for: .normal)
    
    button.backgroundColor = UIColor(named: "Gray")
    
    button.layer.borderColor = borderColor.cgColor
    button.layer.borderWidth = 3
    button.layer.cornerRadius = 10
}


// MARK: Text Fields
func styleTextField(_ field: SkyFloatingLabelTextField) {
    field.lineColor = .gray
    field.selectedLineColor = UIColor(named: "Primary Color")!
    field.selectedLineHeight = 2
    field.lineHeight = 1
    field.textColor = .label
    field.disabledColor = .gray
    
    field.selectedTitleColor = UIColor(named: "Primary Color")!
}
