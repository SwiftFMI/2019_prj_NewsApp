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
import Loaf
import SkyFloatingLabelTextField
import TransitionButton

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var loginButton: TransitionButton!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureElements()
    }
    
    override func viewDidLayoutSubviews() {
        loginButton.frame = loginButton.superview!.bounds
    }
   
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        // hide the keyboard
        view.endEditing(true)
        
        loginButton.startAnimation()
        
        if let errorMessage = validateFields() {
            loginButton.stopAnimation(animationStyle: .shake) { [unowned self] in
                self.loginButton.layer.cornerRadius = self.loginButton.frame.height * 0.5
            }
            showError(message: errorMessage)
        } else {
            
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Authentication.login(email: email, password: password) { [unowned self] (message) in
                if let message = message {
                    self.loginButton.stopAnimation(animationStyle: .normal) { [unowned self] in
                        self.loginButton.layer.cornerRadius = self.loginButton.frame.height * 0.5
                    }
                    
                    self.showError(message: message)
                } else {
                    self.loginButton.stopAnimation(animationStyle: .expand) { [unowned self] in
                        let loggedVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.loggedVC) as! UITabBarController

                        self.view.window?.rootViewController = loggedVC
                        self.view.window?.makeKeyAndVisible()
                    }
                }
            }
        }
    }
}

// MARK: Helper Functions
extension LoginViewController {
    func configureElements() {
        loginButton.spinnerColor = .white
        
        emailTextField.placeholder = "Email"
        emailTextField.title = "Email"
        passwordTextField.placeholder = "Password"
        passwordTextField.title = "Password"
        
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
        Loaf(message, state: .error, sender: self).show()
    }
}

// MARK: Touch Events
extension LoginViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
