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
import SafariServices

class FlashCardsViewController: UIViewController {

    @IBOutlet weak var topNewsKolodaView: KolodaView!
    @IBOutlet weak var topTitlesLabel: UILabel!
    @IBOutlet weak var reloadKolodaStackView: UIStackView!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table view propperties
        topNewsKolodaView.delegate = self
        topNewsKolodaView.dataSource = self
        
        // Hide Koloda Reload View
        reloadKolodaStackView.isHidden = true
        
        News.shared.getTopNews { (news) in
            News.shared.topNews = news?.articles ?? []
            
            DispatchQueue.main.async {
                self.topNewsKolodaView.reloadData()
            }
        }
        
        let userCountry = (UserRepository.shared.fetch(key: .country) as! [String: String])["full"]
        topTitlesLabel.text = "Top Titles for " + (userCountry ?? "")
        
        // Observe for changes in the country of the user
        UserDefaults.standard.addObserver(self, forKeyPath: "country", options: .new, context: nil)
    }
    
    @IBAction func reloadKolodaViewButtonPressed(_ sender: UIButton) {
        News.shared.getTopNews { (news) in
            News.shared.topNews = news?.articles ?? []

            DispatchQueue.main.async {
                self.topNewsKolodaView.reloadData()
                self.reloadKolodaStackView.isHidden = true
            }
        }
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
extension FlashCardsViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
//        topNewsKolodaView.reloadData()
        reloadKolodaStackView.isHidden = false
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let urlAddress = News.shared.topNews[index].url ?? ""
        
        guard let url = URL(string: urlAddress) else { return }
        
        // Open URL in Safari inside the app
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .overFullScreen
        safariVC.delegate = self

        present(safariVC, animated: true)
    }
}

extension FlashCardsViewController: KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = NewsArticleCardView(cardColorIndex: index % 5)
        
        view.delegate = self
        
        view.title.text = News.shared.topNews[index].title
        view.authorLabel.text = News.shared.topNews[index].author
        view.publishedAtLabel.text = formatDate(News.shared.topNews[index].publishedAt ?? "")
        view.desc.text = News.shared.topNews[index].description
        
        if let url = URL(string: News.shared.topNews[index].urlToImage ?? "") {
            if let cachedImage = imageCache.object(forKey: NSString(string: url.absoluteString)) {
                view.image.image = cachedImage
            } else {
                view.image.load(url: url) { (image) in
                    self.imageCache.setObject(image, forKey: NSString(string: url.absoluteString))
                }
            }
        } else {
            view.image.image = UIImage(named: "Placeholder Image")
        }
        
        return view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return News.shared.topNews.count
    }
}

// MARK: Safari Services
extension FlashCardsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
    }
}

// MARK: NewsArticleCardDelegate
extension FlashCardsViewController: NewsArticleCardDelegate {
    func bringBackCard() {
        topNewsKolodaView.revertAction()
    }
    
    func shareUrl() {
        guard let urlAddress = News.shared.topNews[topNewsKolodaView.currentCardIndex].url, let url = URL(string: urlAddress) else { return }
       
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(ac, animated: true)
    }
}

// MARK: User Defaults Observer Handler
extension FlashCardsViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if UserRepository.shared.checkFor(key: .country) {
            topTitlesLabel.text = "Top Titles for " + ((UserRepository.shared.fetch(key: .country) as! [String: String])["full"] ?? "")
            
            News.shared.getTopNews { (news) in
                News.shared.topNews = news?.articles ?? []
                
                DispatchQueue.main.async {
                    self.topNewsKolodaView.reloadData()
                }
            }
        }
    }
}
