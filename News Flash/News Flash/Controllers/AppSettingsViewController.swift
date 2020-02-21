//
//  AppSettingsViewController.swift
//  News Flash
//
//  Created by Emanuil Gospodinov on 27.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit

class AppSettingsViewController: UIViewController {

    @IBOutlet weak var countrySpecificSwitch: UISwitch!
    @IBOutlet weak var countryPickerView: UIPickerView!
    @IBOutlet weak var doneButton: UIButton!
    
    var isCountrySpecific = UserRepository.fetch(key: .isCountrySpecific) as? Bool ?? false
    var languageIndex = Constants.Languages.short.firstIndex(of: UserRepository.fetch(key: .resultLanguage) as? String ?? "") ?? 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureElements()
        
        countryPickerView.delegate = self
        countryPickerView.dataSource = self

        countryPickerView.selectRow(languageIndex, inComponent: 0, animated: true)
        
        countrySpecificSwitch.isOn = isCountrySpecific
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UserRepository.store(key: .isCountrySpecific, value: isCountrySpecific)
        UserRepository.store(key: .resultLanguage, value: Constants.Languages.short[languageIndex])
    }
    
    @IBAction func countrySpecificSwitchPressed(_ sender: UISwitch) {
        isCountrySpecific.toggle()
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Helper Functions
extension AppSettingsViewController {
    func configureElements() {
        stylePrimaryButton(doneButton)
    }
}

// MARK: Picker View
extension AppSettingsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Constants.Languages.full.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Constants.Languages.full[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        languageIndex = row
    }
}
