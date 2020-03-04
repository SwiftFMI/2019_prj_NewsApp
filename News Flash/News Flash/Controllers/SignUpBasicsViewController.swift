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
import TransitionButton
import SkyFloatingLabelTextField

class SignUpBasicsViewController: BaseViewController {

    @IBOutlet weak var nextButton: TransitionButton!
    @IBOutlet weak var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var countryPickerView: UIPickerView!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureElements()
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
    }

    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        nextButton.startAnimation()
        
        if let errorMessage = validateFields() {
            nextButton.stopAnimation(animationStyle: .shake) { [unowned self] in
                self.nextButton.cornerRadius = self.nextButton.frame.height * 0.5
            }
            showError(message: errorMessage)
        } else {
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let country = [
                "short": Constants.Countries.short[countryPickerView.selectedRow(inComponent: 0)],
                "full": Constants.Countries.full[countryPickerView.selectedRow(inComponent: 0)]
            ]
            
            Authentication.signUpBasics(firstName: firstName, lastName: lastName, email: email, password: password, country: country) { [unowned self] (message) in
                if let message = message {
                    self.nextButton.stopAnimation(animationStyle: .shake) {
                        self.nextButton.cornerRadius = self.nextButton.frame.height * 0.5
                    }
                    // an error occured while creating the user
                    self.showError(message: message)
                } else {
                    self.nextButton.stopAnimation(animationStyle: .normal) {
                        let signUpInterestsVC = self.storyboard?.instantiateViewController(identifier: Constants.Storyboard.signUpInterestsVC) as! SignUpInterestsViewController
                        self.present(signUpInterestsVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
}

// MARK: Picker View
extension SignUpBasicsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.Countries.full.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.Countries.full[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        view.endEditing(true)
    }
}

// MARK: Text Field
extension SignUpBasicsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Helper Functions
extension SignUpBasicsViewController {
    func configureElements() {
        nextButton.spinnerColor = .white
        
        firstNameTextField.placeholder = "First Name"
        firstNameTextField.title = "First Name"
        firstNameTextField.delegate = self
        firstNameTextField.returnKeyType = .done
        
        lastNameTextField.placeholder = "Last Name"
        lastNameTextField.title = "Last Name"
        lastNameTextField.delegate = self
        lastNameTextField.returnKeyType = .done
        
        emailTextField.placeholder = "Email"
        emailTextField.title = "Email"
        emailTextField.delegate = self
        emailTextField.returnKeyType = .done
        
        passwordTextField.placeholder = "Password"
        passwordTextField.title = "Password"
        passwordTextField.delegate = self
        passwordTextField.returnKeyType = .done
        
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

}

// MARK: Touch Events
extension SignUpBasicsViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
