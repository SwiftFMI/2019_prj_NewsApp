//
//  SignUpViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 25.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SignUpBasicsViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var countryPickerView: UIPickerView!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.isHidden = true
        loadingView.isHidden = true
        styleElements()
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
    }

    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        if let errorMessage = validateFields() {
            showError(message: errorMessage)
        } else {
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let country = [
                "short": Constants.countriesShort[countryPickerView.selectedRow(inComponent: 0)],
                "full": Constants.countries[countryPickerView.selectedRow(inComponent: 0)]
            ]
            
            showLoading()
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                self.hideLoading()
                
                if let error = error {
                    // an error occured while creating the user
                    self.showError(message: error.localizedDescription)
                } else {
                    let db = Firestore.firestore()
                    
                    db.collection("users").document(result!.user.uid).setData(["firstname": firstName, "lastname": lastName, "country": country]) { (error) in
                        if let _ = error {
                            // user data could not be saved
                            self.showError(message: "User data could not be saved.")
                        } else {
                            // success -> move to the next step
                            let userRepo = UserRepository()
                            
                            userRepo.store(key: .firstname, value: firstName)
                            userRepo.store(key: .lastname, value: lastName)
                            userRepo.store(key: .country, value: country)
                            userRepo.store(key: .email, value: email)
                            
                            let signUpInterestsVC = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.signUpInterestsVC) as! SignUpInterestsViewController
                            
                            self.navigationController?.pushViewController(signUpInterestsVC, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: UIPickerView
extension SignUpBasicsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.countries.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.countries[row]
    }
}

// MARK: Helper Functions
extension SignUpBasicsViewController {
    func styleElements() {
        styleTextField(passwordTextField)
        styleTextField(emailTextField)
        styleTextField(lastNameTextField)
        styleTextField(firstNameTextField)
        stylePrimaryButton(nextButton)
        stylePrimaryTextButton(loginButton)
    }
    
    func validateFields() -> String? {
        
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
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
extension SignUpBasicsViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
