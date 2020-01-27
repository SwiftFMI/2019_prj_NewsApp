//
//  UserRepository.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 31.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation

enum Key: String, CaseIterable {
    case firstname, lastname, country, interests, email, isCountrySpecific, resultLanguage
    func make() -> String {
        return self.rawValue
    }
}

class UserRepository {
    
    static func store(key: Key, value: Any) {
        UserDefaults.standard.set(value, forKey: key.make())
    }
    
    static func fetch(key: Key) -> Any? {
        return UserDefaults.standard.value(forKey: key.make())
    }
    
    static func checkFor(key: Key) -> Bool {
        return UserDefaults.standard.object(forKey: key.make()) != nil
    }
    
    static func removeUserInfo() {
        Key.allCases.map { $0.make() }.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
    
    static func addObserver(_ observer: NSObject, for key: Key) {
        UserDefaults.standard.addObserver(observer, forKeyPath: key.make(), options: .new, context: nil)
    }
    
    static func removeObserver(_ observer: NSObject, for key: Key) {
        UserDefaults.standard.removeObserver(observer, forKeyPath: key.make())
    }
}
