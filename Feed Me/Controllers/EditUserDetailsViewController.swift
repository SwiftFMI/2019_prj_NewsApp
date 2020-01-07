//
//  EditUserDetailsViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 7.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase

// TODO: password editing

class EditUserDetailsViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
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
        
        // TODO: save the changes
        
        let firstName = firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let lastName = lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var updateFields: [String: Any] = [:]
        
        if firstName != "" {
            // save the new name
            UserRepository.shared.store(key: .firstname, value: firstName)
            
            updateFields["firstname"] = firstName
        }
        
        if lastName != "" {
            // save the new name
            UserRepository.shared.store(key: .lastname, value: lastName)
            
            updateFields["lastname"] = lastName
        }
        
        let country = [
            "short": Constants.countriesShort[countryPickerView.selectedRow(inComponent: 0)],
            "full": Constants.countries[countryPickerView.selectedRow(inComponent: 0)]
        ]
        
        UserRepository.shared.store(key: .country, value: country)
        
        updateFields["country"] = country
        
        
        // Update the database
        let db = Firestore.firestore()
        db.collection("users").document(Auth.auth().currentUser!.uid).updateData(updateFields)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: UIPickerView
extension EditUserDetailsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
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
extension EditUserDetailsViewController {
    func configureElements() {
        firstNameTextField.text = UserRepository().fetch(key: .firstname) as? String
        lastNameTextField.text = UserRepository().fetch(key: .lastname) as? String
        emailTextField.text = UserRepository().fetch(key: .email) as? String
        emailTextField.isUserInteractionEnabled = false
        
        let countryName = (UserRepository.shared.fetch(key: .country) as! [String: String])["short"] ?? ""
        let countryId = Constants.countriesShort.firstIndex(of: countryName) ?? 0
        
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
