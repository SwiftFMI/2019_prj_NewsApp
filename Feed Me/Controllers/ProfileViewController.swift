//
//  ProfileViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 30.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase

// TODO: Edit user

class ProfileViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editDetailsButton: UIButton!
    @IBOutlet weak var editInterestsButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        configureElements()
        
        // Observe for changes in the first name of the user
        UserDefaults.standard.addObserver(self, forKeyPath: "firstname", options: .new, context: nil)
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

}

// MARK: Helper Functions
extension ProfileViewController {
    func signOut() -> Void {
        do {
            try Auth.auth().signOut()
            
            // navigating to Auth views
            let authVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.authVC) as! UINavigationController
            authVC.isNavigationBarHidden = true
            
            // remove the local data
            UserRepository().removeUserInfo()
            
            self.view.window?.rootViewController = authVC
            self.view.window?.makeKeyAndVisible()
        } catch let error {
            print("Failed to sign out with error", error)
        }
    }
    
    func configureElements() {
        titleLabel.text = "Hello " + (UserRepository().fetch(key: .firstname) as! String)
        
        styleSecondaryButton(editDetailsButton)
        styleSecondaryButton(editInterestsButton)
        styleSecondaryButton(changePasswordButton)
        styleDangerButton(signOutButton)
    }
}

// MARK: User Defaults Observer Handler
extension ProfileViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        self.titleLabel.text = "Hello " + (UserRepository.shared.fetch(key: .firstname) as! String)
    }
}
