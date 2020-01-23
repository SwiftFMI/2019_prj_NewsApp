//
//  News.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 27.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import Foundation

struct Source: Decodable {
    let id: String?
    let name: String?
    let description: String?
    let url: String?
    let category: String?
    let language: String?
    let country: String?
}

struct Article: Decodable {
    let source: Source?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    let saved: Bool?
}

struct ArticleResults: Decodable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

struct SourceResults: Decodable {
    let status: String
    let sources: [Source]
}

final class News {
    typealias NewsCompletion = (ArticleResults?) -> ()
    typealias SavedCompletion = ([Article]?) -> ()
    typealias BasicCompletion = (Bool) -> ()
    
    static let shared = News()
    
    var topNews: [Article] = []
    var allNews: [Article] = []
    var searchResults: [Article] = []
    var savedNews: [Article] = []
    var savedUrls: [String] = []
    
    var newsSources: SourceResults?
    
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
}
