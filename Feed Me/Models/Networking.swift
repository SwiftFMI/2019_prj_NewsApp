//
//  Networking.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 27.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation

final class Networking {
    typealias TopNewsCompletion = (ArticleResults?) -> ()
    
    static func getTopNews(completion: @escaping TopNewsCompletion) {
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=us")!
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
