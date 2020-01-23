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
    
    static func login(email: String, password: String, completion: @escaping MessageCompletion) {
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if let error = error {
                completion(error.localizedDescription)
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
                        
                        completion(nil)
                    } else {
                        print("Document does not exist")
                    }
                }
            }
        }
    }
    
    static func updateUserData() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid).getDocument { (data, _) in
            if let data = data, data.exists {
                UserRepository.shared.store(key: .firstname, value: data["firstname"]!)
                UserRepository.shared.store(key: .lastname, value: data["lastname"]!)
                UserRepository.shared.store(key: .email, value: Auth.auth().currentUser!.email!)
                UserRepository.shared.store(key: .country, value: data["country"] as! [String: String])
                UserRepository.shared.store(key: .interests, value: data["interests"] as! [String])
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
                        let userRepo = UserRepository()
                        
                        userRepo.store(key: .firstname, value: firstName)
                        userRepo.store(key: .lastname, value: lastName)
                        userRepo.store(key: .country, value: country)
                        userRepo.store(key: .email, value: email)
                        
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
