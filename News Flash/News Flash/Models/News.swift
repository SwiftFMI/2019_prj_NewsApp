//
//  News.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 27.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation

final class News {
    typealias NewsCompletion = ([Article]?) -> ()
    typealias SavedCompletion = ([Article]?) -> ()
    typealias BasicCompletion = (Bool) -> ()
    
    static let shared = News()
    
    var topNews: [Article] = []
    var allNews: [Article] = []
    var searchResults: [Article] = []
    var savedNews: [Article] = []
    var savedUrls: [String] = []
    var categoryNews: [Article] = []
    
    func getTopNews(completion: @escaping NewsCompletion) {
        Networking.getLocalTopNews(completion: completion)
    }
    
    func getAllNews(page: Int, completion: @escaping NewsCompletion) {
        Networking.getLocalAllNews(page: page, completion: completion)
    }
    
    func searchNews(page: Int, q: String, completion: @escaping NewsCompletion) {
        Networking.getSearchResults(page: page, q: q, completion: completion)
    }
    
    func getSavedNews(completion: @escaping SavedCompletion) {
        Networking.getSavedNews(completion: completion)
    }
    
    func saveArticle(_ article: Article, completion: @escaping BasicCompletion) {
        Networking.saveArticle(article, completion: completion)
    }
    
    func unsaveArticle(_ url: String, completion: @escaping BasicCompletion) {
        Networking.unsaveArticle(url, completion: completion)
    }
    
    func updateSavedUrls() -> Void {
        Networking.updateSavedUrls()
    }
    
    func getByCategory(_ category: String, includeCountry: Bool, completion: @escaping NewsCompletion) {
        Networking.getNewsByCategory(category: category, includeCountry: includeCountry, completion: completion)
    }
}

struct Article: Decodable {
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
}

struct ArticleResults: Decodable {
    let articles: [Article]
}
