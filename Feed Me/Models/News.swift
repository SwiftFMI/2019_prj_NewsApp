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
    static let shared = News()
    
    var topNews: ArticleResults?
    var allNews: [Article] = []
    var newsSources: SourceResults?
    
    func getTopNews(completion: @escaping (ArticleResults?) -> ()) {
        Networking.getLocalTopNews(completion: completion)
    }
    
    func getAllNews(page: Int, completion: @escaping (ArticleResults?) -> ()) {
        Networking.getLocalAllNews(page: page, completion: completion)
    }
}
