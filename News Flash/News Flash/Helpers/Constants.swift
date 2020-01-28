//
//  Constants.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 25.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Foundation

struct Constants {
    struct Storyboard {
        static let homeVC = "HomeVC"
        static let loginVC = "LoginVC"
        static let singUpBasicsVC = "SignUpBasicsVC"
        static let signUpInterestsVC = "SignUpInterestsVC"
        static let authVC = "AuthVC"
        static let loggedVC = "LoggedVC"
        static let searchResultsVC = "SearchResultsVC"
        static let categoryVC = "CategoryVC"
    }
    
    struct TableCell {
        static let newsArticle = "NewsArticle"
        static let newsArticleLoading = "NewsArticleLoading"
        static let newArticleHeight = 130
    }
    
    struct NewsCategories {
        static let titles = ["business", "entertainment", "health", "science", "sports", "technology"]
        static let images = [UIImage(systemName: "briefcase.fill"), UIImage(systemName: "gamecontroller.fill"), UIImage(systemName: "bandage.fill"), UIImage(systemName: "wrench.fill"), UIImage(systemName: "sportscourt.fill"), UIImage(systemName: "desktopcomputer")]
    }
    
    struct Xib {
        static let newsArticleLoadingCell = "NewsArticleLoadingTableViewCell"
        static let newsArticleCell = "NewsArticleTableViewCell"
        static let flashCard = "FlashCardView"
    }
    
    static let cardColors = [
        UIColor(named: "Card Purple"),
        UIColor(named: "Card Orange"),
        UIColor(named: "Card Pink"),
        UIColor(named: "Card Yellow")
    ]
    
    struct Languages {
        static let full = ["Arabic", "Chinese", "Dutch", "English", "French", "German", "Hebrew", "Italian", "Norwegian", "Portuguese", "Russian", "Spanish"]
        
        static let short = ["ar", "zh", "nl", "en", "fr", "de", "he", "it", "no", "pt", "ru", "es"]
    }
    
    struct Countries {
        static let short = [
            "ae",
            "ar",
            "at",
            "au",
            "be",
            "bg",
            "br",
            "ca",
            "ch",
            "cn",
            "co",
            "cu",
            "cz",
            "de",
            "eg",
            "fr",
            "gb",
            "gr",
            "hk",
            "hu",
            "id",
            "ie",
            "il",
            "in",
            "it",
            "jp",
            "kr",
            "lt",
            "lv",
            "ma",
            "mx",
            "my",
            "ng",
            "nl",
            "no",
            "nz",
            "ph",
            "pl",
            "pt",
            "ro",
            "rs",
            "ru",
            "sa",
            "se",
            "sg",
            "si",
            "sk",
            "th",
            "tr",
            "tw",
            "ua",
            "us",
            "ve",
            "za"
        ]
        
        static let full = [
            "United Arab Emirates",
            "Armenia",
            "Austria",
            "Australia",
            "Belgium",
            "Bulgaria",
            "Brazil",
            "Canada",
            "Switzerland",
            "China",
            "Colombia",
            "Cuba",
            "Czech Republic",
            "Germany",
            "Egypt",
            "France",
            "Great Britain",
            "Greece",
            "Hong Kong",
            "Hungary",
            "Indonesia",
            "Ireland",
            "Israel",
            "India",
            "Italy",
            "Japan",
            "South Korea",
            "Lithuania",
            "Latvia",
            "Morocco",
            "Mexico",
            "Malasia",
            "Nigeria",
            "Netherlands",
            "Norway",
            "New Zeland",
            "Philippines",
            "Poland",
            "Portugal",
            "Romania",
            "Serbia",
            "Russia",
            "Saudi Arabia",
            "Sweden",
            "Singapore",
            "Slovenia",
            "Slovakia",
            "Thailand",
            "Turkey",
            "Taiwan",
            "Ukraine",
            "United States",
            "Venezuela",
            "South Africa"
        ]
    }
}
