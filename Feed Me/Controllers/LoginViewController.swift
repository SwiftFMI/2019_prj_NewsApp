//
//  LoginViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 24.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        styleElements()
        errorLabel.isHidden = true
        loadingView.isHidden = true
    }
   
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        // hide the keyboard
        view.endEditing(true)
        
        if let errorMessage = validateFields() {
            showError(message: errorMessage)
        } else {
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            showLoading()
            
            Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                
                if let error = error {
                    self.hideLoading()
                    self.showError(message: error.localizedDescription)
                } else {
                    // success -> go to home
                    
                    // store user data
                    Firestore.firestore().collection("users").document(result!.user.uid).getDocument { (document, error) in
                        if let document = document, document.exists {
                            UserRepository.shared.store(key: .firstname, value: document["firstname"]!)
                            UserRepository.shared.store(key: .lastname, value: document["lastname"]!)
                            UserRepository.shared.store(key: .country, value: (document["country"] as! [String: String]))
                            UserRepository.shared.store(key: .interests, value: (document["interests"] as! [String]))
                            UserRepository.shared.store(key: .email, value: email)
                            
                            self.hideLoading()
                            
                            let loggedVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.loggedVC) as! UITabBarController
                            
                            self.view.window?.rootViewController = loggedVC
                            self.view.window?.makeKeyAndVisible()
                        } else {
                            print("Document does not exist")
                        }
                    }
                }
            }
        }
    }
    
}

// MARK: Helper Functions
extension LoginViewController {
    func styleElements() {
        stylePrimaryButton(loginButton)
        stylePrimaryTextButton(signUpButton)
        styleTextField(emailTextField)
        styleTextField(passwordTextField)
    }
    
    func validateFields() -> String? {
        
        if  emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "All fields are required."
        }
        
        if !isValidPassword(passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return "You should choose a better password."
        }
        
        if !isValidEmail(emailTextField.text!) {
            return "You should enter a valid email address."
        }
        
        return nil
    }
    
     func isValidEmail(_ str: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: str)
    }
    
    public func isValidPassword(_ str: String) -> Bool {
        let passwordRegex = "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])[0-9a-zA-Z!@#$%^&*()\\-_=+{}|?>.<,:;~`’]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: str)
    }
    
    func showError(message: String) -> Void {
        errorLabel.text = message
        errorLabel.isHidden = false
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

// MARK: Touch Events
extension LoginViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
