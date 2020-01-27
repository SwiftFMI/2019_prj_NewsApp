//
//  EditUserDetailsViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 7.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class EditUserDetailsViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var countryPickerView: UIPickerView!
    
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self
        
        configureElements()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var updateFields: [String: Any] = [:]
        
        if let firstName = firstName, firstName != "" {
            // save the new name
            UserRepository.store(key: .firstname, value: firstName)
            
            updateFields["firstname"] = firstName
        }
        
        if let lastName = lastName, lastName != "" {
            // save the new name
            UserRepository.store(key: .lastname, value: lastName)
            
            updateFields["lastname"] = lastName
        }
        
        let country = [
            "short": Constants.Countries.short[countryPickerView.selectedRow(inComponent: 0)],
            "full": Constants.Countries.full[countryPickerView.selectedRow(inComponent: 0)]
        ]
        
        UserRepository.store(key: .country, value: country)
        
        updateFields["country"] = country
        
        
        // Update the database
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(updateFields)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Text Field
extension EditUserDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: Picker View
extension EditUserDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.Countries.full.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.Countries.full[row]
    }
}

// MARK: Helper Functions
extension EditUserDetailsViewController {
    func configureElements() {
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
        
        firstNameTextField.text = UserRepository.fetch(key: .firstname) as? String
        lastNameTextField.text = UserRepository.fetch(key: .lastname) as? String
        emailTextField.text = UserRepository.fetch(key: .email) as? String
        emailTextField.isUserInteractionEnabled = false
        
        let countryName = (UserRepository.fetch(key: .country) as! [String: String])["short"] ?? ""
        let countryId = Constants.Countries.short.firstIndex(of: countryName) ?? 0
        
        countryPickerView.selectRow(countryId, inComponent: 0, animated: false)
        
        stylePrimaryButton(doneButton)
        styleTextField(firstNameTextField)
        styleTextField(lastNameTextField)
        styleTextField(emailTextField)
    }
}

// MARK: Touch Events
extension EditUserDetailsViewController {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
