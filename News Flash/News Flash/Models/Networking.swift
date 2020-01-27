//
//  Networking.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 27.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation
import Firebase

// API KEY: 2407b50324ed42dfadd1366a2f426651

final class Networking {
    typealias NewsCompletion = ([Article]?) -> ()
    typealias SavedCompletion = ([Article]?) -> ()
    typealias BasicCompletion = (Bool) -> ()
    
    static func getNewsByCategory(category: String, includeCountry: Bool, completion: @escaping NewsCompletion) {
        var urlString = "https://newsapi.org/v2/top-headlines?category=\(category)"
        
        if includeCountry {
            let countryCode = (UserRepository.fetch(key: .country) as! [String: String])["short"] ?? ""
            urlString.append("&country=\(countryCode)")
        }
        
        let url = URL(string: urlString)!
        
        var request = URLRequest(url: url)
        request.addValue("2407b50324ed42dfadd1366a2f426651", forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(ArticleResults.self, from: data)
                
                completion(result.articles)
            } catch {
                print("Could not parse JSON response")
                completion(nil)
            }
        }.resume()
    }
    
    static func getLocalTopNews(completion: @escaping NewsCompletion) {
        let countryCode = (UserRepository.fetch(key: .country) as! [String: String])["short"] ?? ""
        
        let url = URL(string: "https://newsapi.org/v2/top-headlines?country=\(countryCode)")!
        var request = URLRequest(url: url)
        request.addValue("2407b50324ed42dfadd1366a2f426651", forHTTPHeaderField: "X-Api-Key")

        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(ArticleResults.self, from: data)
                
                completion(result.articles)
            } catch {
                print("Could not parse JSON response")
                completion(nil)
            }
            
        }.resume()
    }
    
    static func getLocalAllNews(page: Int, completion: @escaping NewsCompletion) {
        let interests = UserRepository.fetch(key: .interests) as! [String]
        var query = ""
        
        for index in 0..<interests.count {
            query += interests[index]
            if (index < interests.count - 1) {
                query += "%20OR%20"
            }
        }
        
        let preferredLanguage = UserRepository.fetch(key: .resultLanguage) as! String
        
        let url = URL(string: "https://newsapi.org/v2/everything?sortBy=publishedAt&qInTitle=\(query)&language=\(preferredLanguage)&page=\(page)")!
        
        var request = URLRequest(url: url)
        request.addValue("2407b50324ed42dfadd1366a2f426651", forHTTPHeaderField: "X-Api-Key")
        
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let result = try JSONDecoder().decode(ArticleResults.self, from: data)
                
                completion(result.articles)
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
                
                completion(result.articles)
            } catch {
                print("Could not parse JSON response")
                completion(nil)
            }
        }.resume()
    }
    
    static func saveArticle(_ article: Article, completion: @escaping BasicCompletion) {
        let db = Firestore.firestore()
        
        let data : [String: Any] = [
            "source": article.source?.name ?? "",
            "title": article.title ?? "",
            "description": article.description ?? "",
            "url": article.url ?? "",
            "urlToImage": article.urlToImage ?? "",
            "savedAt": FieldValue.serverTimestamp()
        ]
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("saved").addDocument(data: data) { (error) in
            if let _ = error {
                completion(false)
            } else {
                News.shared.savedNews.insert(article, at: 0)
                News.shared.savedUrls.append(article.url ?? "")
                
                completion(true)
            }
        }
    }
    
    static func unsaveArticle(_ url: String, completion: @escaping BasicCompletion) {
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("saved").whereField("url", isEqualTo: url).getDocuments { (data, error) in
            if let _ = error {
                completion(false)
            } else {
                for document in data!.documents {
                    document.reference.delete()
                }
                
                // filter the saved arrays
                News.shared.savedNews = News.shared.savedNews.filter {$0.url != url}
                News.shared.savedUrls = News.shared.savedUrls.filter {$0 != url}
                
                completion(true)
            }
        }
        
    }
    
    static func getSavedNews(completion: @escaping SavedCompletion) {
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("saved").order(by: "savedAt", descending: true).getDocuments { (data, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            News.shared.savedUrls = []
        
            var result: [Article] = []
            
            for document in data.documents {
                let article = Article.init(
                    source: Source(id: nil, name: document["source"] as? String) ,
                    title: document["title"] as? String,
                    description: document["description"] as? String,
                    url: document["url"] as? String,
                    urlToImage: document["urlToImage"] as? String
                )
                
                News.shared.savedUrls.append(document["url"] as! String)
                
                result.append(article)
            }
            
            completion(result)
        }
    }
    
    static func updateSavedUrls() {
        let db = Firestore.firestore()
        
        db.collection("users").document(Auth.auth().currentUser!.uid).collection("saved").getDocuments { (data, error) in
            guard let data = data, error == nil else {
                return
            }
            
            News.shared.savedUrls = []
            
            for document in data.documents {
                News.shared.savedUrls.append(document["url"] as! String)
            }
        }
    }
}
