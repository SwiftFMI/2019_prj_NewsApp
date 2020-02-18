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
import TransitionButton

class SignUpInterestsViewController: BaseViewController {
    
    @IBOutlet weak var businessButton: UIButton!
    @IBOutlet weak var entertainmentButton: UIButton!
    @IBOutlet weak var healthButton: UIButton!
    @IBOutlet weak var scienceButton: UIButton!
    @IBOutlet weak var sportsButton: UIButton!
    @IBOutlet weak var technologyButton: UIButton!
    
    @IBOutlet weak var nextButton: TransitionButton!
    
    var selectedInterests: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureElements()
    }

    @IBAction func interestButtonPressed(_ sender: UIButton) {
        toggleSelectedPill(sender)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        nextButton.startAnimation()
        
        Authentication.signUpInterests(interests: selectedInterests) { [unowned self] (message) in
            if let message = message {
                self.nextButton.stopAnimation(animationStyle: .shake) { [unowned self] in
                    self.nextButton.layer.cornerRadius = self.nextButton.frame.height * 0.5
                }
                // user data could not be saved
                self.showError(message: message)
            } else {
                self.nextButton.stopAnimation(animationStyle: .expand) { [unowned self] in
                    UserRepository.store(key: .interests, value: self.selectedInterests)
                    
                    let loggedVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.loggedVC) as! UITabBarController

                    self.view.window?.rootViewController = loggedVC
                    self.view.window?.makeKeyAndVisible()
                }
            }
        }
    }
}

// MARK: Helper Functions
extension SignUpInterestsViewController {
    func configureElements() {
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
    
}
