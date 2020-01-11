//
//  EditUserInterestsViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 7.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class EditUserInterestsViewController: UIViewController {

    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var entertainmentButton: UIButton!
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var scienceButton: UIButton!
    @IBOutlet weak var sportsButton: UIButton!
    @IBOutlet weak var technologyButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var interests = UserRepository.shared.fetch(key: .interests) as! [String]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureElements()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Update User Defaults
        UserRepository.shared.store(key: .interests, value: interests)
        
       // Update Database
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).updateData(["interests": interests])
    }
    
    @IBAction func toggleInterest(_ sender: UIButton) {
        let interest = sender.titleLabel?.text?.lowercased() ?? ""
        
        if interests.contains(interest) {
            interests = interests.filter { $0 != interest }
            styleSecondaryPill(sender)
        } else {
            interests.append(interest)
            stylePrimaryPill(sender)
        }
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Helper Functions
extension EditUserInterestsViewController {
    func configureElements() {
        if interests.contains("business") {
            stylePrimaryPill(businessButton)
        } else {
            styleSecondaryPill(businessButton)
        }
        
        if interests.contains("entertainment") {
            stylePrimaryPill(entertainmentButton)
        } else {
            styleSecondaryPill(entertainmentButton)
        }
        
        if interests.contains("health") {
            stylePrimaryPill(healthButton)
        } else {
            styleSecondaryPill(healthButton)
        }
        
        if interests.contains("science") {
            stylePrimaryPill(scienceButton)
        } else {
            styleSecondaryPill(scienceButton)
        }
        
        if interests.contains("sports") {
            stylePrimaryPill(sportsButton)
        } else {
            styleSecondaryPill(sportsButton)
        }
        
        if interests.contains("technology") {
            stylePrimaryPill(technologyButton)
        } else {
            styleSecondaryPill(technologyButton)
        }
        
        stylePrimaryButton(doneButton)
    }
}
