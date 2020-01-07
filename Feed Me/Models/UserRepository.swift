//
//  UserRepository.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 31.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation

// TODO: Store email as well

enum Key: String, CaseIterable {
    case firstname, lastname, country, interests, email
    func make() -> String {
        return self.rawValue
    }
}

class UserRepository {
    
    static let shared = UserRepository()

    let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func store(key: Key, value: Any) {
        userDefaults.set(value, forKey: key.make())
    }
    
    func fetch(key: Key) -> Any? {
        return userDefaults.value(forKey: key.make())
    }
    
    func removeUserInfo() {
        Key
            .allCases
            .map { $0.make() }
            .forEach { key in
                userDefaults.removeObject(forKey: key)
        }
    }
}
