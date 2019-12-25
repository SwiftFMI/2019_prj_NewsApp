//
//  HomeViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 25.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        authenticateUser()
        configureComponents()
    }
    
    // check for logged user
    func authenticateUser() {
        if Auth.auth().currentUser == nil {
            goToLogin()
        }
    }
    
    func configureComponents() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.fill.badge.minus"), style: .plain, target: self, action: #selector(handleSignOut))
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            goToLogin()
        } catch let error {
            print("Failed to sign out with error", error)
        }
    }
    
    @objc func handleSignOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func goToLogin() {
        let loginVC = storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.loginVC) as! LoginViewController
        navigationController?.pushViewController(loginVC, animated: true)
    }
}
