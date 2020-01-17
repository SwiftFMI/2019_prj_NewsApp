//
//  SignUpInterestsViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 31.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpInterestsViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var entertainmentButton: UIButton!
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var scienceButton: UIButton!
    @IBOutlet weak var sportsButton: UIButton!
    @IBOutlet weak var technologyButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var selectedInterests: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.isHidden = true
        loadingView.isHidden = true
        styleElements()
    }

    @IBAction func interestButtonPressed(_ sender: UIButton) {
        toggleSelectedPill(sender)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let db = Firestore.firestore()
        
        showLoading()
        
        db.collection("users").document(currentUser.uid).setData(["interests": selectedInterests], merge: true) { (error) in
            self.hideLoading()
            
            if let _ = error {
                // user data could not be saved
                self.showError(message: "Interests could not be saved.")
            } else {
                // success -> go to home page
                
                let userRepo = UserRepository()
                userRepo.store(key: .interests, value: self.selectedInterests)
                
                let loggedVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.loggedVC) as! UITabBarController

                self.view.window?.rootViewController = loggedVC
                self.view.window?.makeKeyAndVisible()
                 
            }
        }
    }
}

// MARK: Helper Functions
extension SignUpInterestsViewController {
    func styleElements() {
        let buttons = [businessButton, entertainmentButton, healthButton, scienceButton, sportsButton, technologyButton]
        
        for button in buttons {
            if let btn = button {
                styleSecondaryPill(btn)
            }
        }
        
        stylePrimaryButton(nextButton)
    }
    
    func toggleSelectedPill(_ button: UIButton) -> Void {
        guard let interest = button.titleLabel?.text?.lowercased() else { return }
        
        if selectedInterests.contains(interest) {
            styleSecondaryPill(button)
            
            guard let index = selectedInterests.firstIndex(of: interest) else { return }
            selectedInterests.remove(at: index)
        } else {
            stylePrimaryPill(button)
            selectedInterests.append(interest)
        }
    }
    
    func showError(message: String) {
        errorLabel.text = message
        errorLabel.isHidden = true
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        loadingView.isHidden = false
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
        loadingView.isHidden = true
    }
}
