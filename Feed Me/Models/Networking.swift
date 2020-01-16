//
//  Networking.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 27.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase

// TODO: Stop requesting data when before that it could not have been parsed
// TODO: Implement a Result Status Enum for the response

final class Networking {
    typealias NewsCompletion = (ArticleResults?) -> ()
    
    static func getLocalTopNews(completion: @escaping NewsCompletion) {
        let countryCode = (UserRepository.shared.fetch(key: .country) as! [String: String])["short"] ?? ""
        
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=" + countryCode)!
        var request = URLRequest(url: url)
        request.addValue("2407b50324ed42dfadd1366a2f426651", forHTTPHeaderField: "X-Api-Key")

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(ArticleResults.self, from: data)
                
                completion(result)
            } catch {
                print("Could not parse JSON response")
                completion(nil)
            }
            
        }.resume()
    }
    
    static func getLocalAllNews(page: Int, completion: @escaping NewsCompletion) {
        let interests = UserRepository().fetch(key: .interests) as! [String]
        var query = ""
        
        for index in 0..<interests.count {
            query += interests[index]
            if (index < interests.count - 1) {
                query += "%20OR%20"
            }
        }
        
        let url = URL(string: "https://newsapi.org/v2/everything?sortBy=relevancy&q=\(query)&page=\(page)")!
        
        var request = URLRequest(url: url)
        request.addValue("2407b50324ed42dfadd1366a2f426651", forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(ArticleResults.self, from: data)
                
                completion(result)
            } catch {
                print("Could not parse JSON response")
                completion(nil)
            }
            
        }.resume()
    }
    
    static func getSearchResults(page: Int, q: String, completion: @escaping NewsCompletion) {
        let urlQuery = q.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        
        let url = URL(string: "https://newsapi.org/v2/everything?page=\(page)&q=\(urlQuery)")!
        var request = URLRequest(url: url)
        request.addValue("2407b50324ed42dfadd1366a2f426651", forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(ArticleResults.self, from: data)
                
                completion(result)
            } catch {
                print("Could not parse JSON response")
                completion(nil)
            }
        }.resume()
    }
}

// API KEY: 2407b50324ed42dfadd1366a2f426651
