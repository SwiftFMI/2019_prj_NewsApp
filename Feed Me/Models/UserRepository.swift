//
//  UserRepository.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 31.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation

enum Key: String, CaseIterable {
    case firstname, lastname, country, interests, email
    func make() -> String {
        return self.rawValue
    }
}

class UserRepository {
    
    static let shared = UserRepository()
    
    func store(key: Key, value: Any) {
        UserDefaults.standard.set(value, forKey: key.make())
    }
    
    func fetch(key: Key) -> Any? {
        return UserDefaults.standard.value(forKey: key.make())
    }
    
    func checkFor(key: Key) -> Bool {
        return UserDefaults.standard.object(forKey: key.make()) != nil
    }
    
    func removeUserInfo() {
        Key.allCases.map { $0.make() }.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
