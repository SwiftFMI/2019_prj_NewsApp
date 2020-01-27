//
//  Authentication.swift
//  News Flash
//
//  Created by Emanuil Gospodinov on 23.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import Foundation
import Firebase

final class Authentication {
    typealias MessageCompletion = (String?) -> ()
    typealias BasicCompletion = (Bool) -> ()
    
    static func login(email: String, password: String, completion: @escaping MessageCompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                completion(error.localizedDescription)
            } else {
                // success -> go to home
                
                // store user data
                Firestore.firestore().collection("users").document(result!.user.uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        
                        
                        UserRepository.store(key: .lastname, value: document["lastname"] as! String)
                        UserRepository.store(key: .firstname, value: document["firstname"] as! String)
                        UserRepository.store(key: .country, value: (document["country"] as! [String: String]))
                        UserRepository.store(key: .interests, value: (document["interests"] as! [String]))
                        UserRepository.store(key: .email, value: email)
                        UserRepository.store(key: .resultLanguage, value: "en")
                        UserRepository.store(key: .isCountrySpecific, value: true)
                        
                        completion(nil)
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    static func signOut(completion: @escaping BasicCompletion) {
        do {
            try Auth.auth().signOut()
            
            UserRepository.removeUserInfo()
            
            completion(true)
        } catch {
            completion(false)
        }
    }
    
    static func updateUserData() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).getDocument { (data, _) in
            if let data = data, data.exists {
                UserRepository.store(key: .firstname, value: data["firstname"]!)
                UserRepository.store(key: .lastname, value: data["lastname"]!)
                UserRepository.store(key: .email, value: Auth.auth().currentUser!.email!)
                UserRepository.store(key: .country, value: data["country"] as! [String: String])
                UserRepository.store(key: .interests, value: data["interests"] as! [String])
            }
        }
    }
    
    static func signUpBasics(firstName: String, lastName: String, email: String, password: String, country: [String: String], completion: @escaping MessageCompletion) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                completion(error.localizedDescription)
            } else {
                let db = Firestore.firestore()
                
                db.collection("users").document(result!.user.uid).setData(["firstname": firstName, "lastname": lastName, "country": country]) { (error) in
                    if let _ = error {
                        completion("User data could not be saved.")
                    } else {
                        // success -> move to the next step
                        
                        UserRepository.store(key: .firstname, value: firstName)
                        UserRepository.store(key: .lastname, value: lastName)
                        UserRepository.store(key: .country, value: country)
                        UserRepository.store(key: .email, value: email)
                        UserRepository.store(key: .resultLanguage, value: "en")
                        UserRepository.store(key: .isCountrySpecific, value: true)
                        
                        completion(nil)
                    }
                }
            }
        }
    }
    
    static func signUpInterests(interests: [String], completion: @escaping MessageCompletion) {
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser!.uid).setData(["interests": interests], merge: true) { (error) in
            if let _ = error {
                completion("Interests could not be saved.")
            } else {
                completion(nil)
            }
        }
    }
}
