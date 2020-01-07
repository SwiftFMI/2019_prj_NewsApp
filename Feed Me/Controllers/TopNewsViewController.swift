//
//  HomeViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 25.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase
import Koloda

// TODO: open web pages when a card is clicked

class TopNewsViewController: UIViewController {

    @IBOutlet weak var topNewsKolodaView: KolodaView!
    @IBOutlet weak var topTitlesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table view propperties
        topNewsKolodaView.delegate = self
        topNewsKolodaView.dataSource = self
        
        News.shared.getTopNews { (news) in
            News.shared.topNews = news
            
            DispatchQueue.main.async {
                self.topNewsKolodaView.reloadData()
            }
        }
        
        let userCountry = (UserRepository().fetch(key: .country) as! [String: String])["full"]
        topTitlesLabel.text = "Top Titles for " + (userCountry ?? "")
        
        // Observe for changes in the country of the user
        UserDefaults.standard.addObserver(self, forKeyPath: "country", options: .new, context: nil)
    }
    
    private func formatDate(_ date: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "dd.MM.yyyy"

        guard let _ = dt else { return nil }
        
        return dateFormatter.string(from: dt!)
    }
}

// MARK: Koloda View
extension TopNewsViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
//      koloda.reloadData()
        print("Reached end of card stack")
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let alert = UIAlertController(title: "Congratulation!", message: "Now you're \(index)", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      self.present(alert, animated: true)
    }
}

extension TopNewsViewController: KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = NewsArticleCardView(cardColorIndex: index % 5)
        
        view.delegate = self
        
        view.title.text = News.shared.topNews?.articles[index].title ?? ""
        view.authorLabel.text = News.shared.topNews?.articles[index].author ?? ""
        view.publishedAtLabel.text = formatDate(News.shared.topNews?.articles[index].publishedAt ?? "")
        view.desc.text = News.shared.topNews?.articles[index].description ?? ""
        
        if let url = URL(string: News.shared.topNews?.articles[index].urlToImage ?? "") {
            view.image.load(url: url)
        } else {
            view.image.image = UIImage(named: "Placeholder Image")
        }
        
        return view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return News.shared.topNews?.articles.count ?? 0
    }
}

// MARK: CanBringBackCard Protocol
extension TopNewsViewController: CanBringBackCard {
    func bringBackCard() {
        topNewsKolodaView.revertAction()
    }
}

// MARK: User Defaults Observer Handler
extension TopNewsViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        topTitlesLabel.text = "Top Titles for " + ((UserRepository.shared.fetch(key: .country) as! [String: String])["full"] ?? "")
        
        News.shared.getTopNews { (news) in
            News.shared.topNews = news
            
            DispatchQueue.main.async {
                self.topNewsKolodaView.reloadData()
            }
        }
    }
}

// MARK: UIImageView load image from url
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
