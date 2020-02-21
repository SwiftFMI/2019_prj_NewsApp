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
import Loaf
import Reachability

class FlashCardsViewController: BaseViewController {

    @IBOutlet weak var topNewsKolodaView: KolodaView!
    @IBOutlet weak var reloadKolodaStackView: UIStackView!
    
    private let imageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure table view propperties
        topNewsKolodaView.delegate = self
        topNewsKolodaView.dataSource = self
        
        // Hide Koloda Reload View
        reloadKolodaStackView.isHidden = true
        
        News.shared.getTopNews { [unowned self] (news) in
            News.shared.topNews = news ?? []
            
            DispatchQueue.main.async {
                self.topNewsKolodaView.reloadData()
            }
        }
        
        updateNavigationBarTitle()
        
        // Observe for changes in the country of the user
        UserRepository.addObserver(self, for: .country)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        News.shared.topNews = []
        imageCache.removeAllObjects()
    }
    
    deinit {
        News.shared.topNews = []
        imageCache.removeAllObjects()
        
        if isViewLoaded {
            UserRepository.removeObserver(self, for: .country)
        }
    }
    
    @IBAction func reloadKolodaViewButtonPressed(_ sender: UIButton) {
        News.shared.getTopNews { [unowned self] (news) in
            News.shared.topNews = news ?? []

            DispatchQueue.main.async {
                self.topNewsKolodaView.resetCurrentCardIndex()
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
        reloadKolodaStackView.isHidden = false
    }
    
    func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat? {
        return 0.15
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
        let view = NewsArticleCardView(cardColorIndex: index % 4)
        
        view.delegate = self
        
        view.titleLabel.text = News.shared.topNews[index].title
        view.titleLabel.font = UIFont.init(name: "TrebuchetMS-Bold", size: 18)
        view.titleLabel.textAlignment = .center
        view.sourceLabel.text = News.shared.topNews[index].source?.name
        view.descriptionLabel.font = UIFont.init(name: "TrebuchetMS", size: 15)
        view.descriptionLabel.text = News.shared.topNews[index].description
        
        if let url = News.shared.topNews[index].url {
            view.saved = News.shared.savedUrls.contains(url)
        }
        
        if let url = URL(string: News.shared.topNews[index].urlToImage ?? "") {
            if let cachedImage = imageCache.object(forKey: NSString(string: url.absoluteString)) {
                view.cardImageView.image = cachedImage
            } else {
                view.cardImageView.load(url: url) { (image) in
                    self.imageCache.setObject(image, forKey: NSString(string: url.absoluteString))
                }
            }
        } else {
            view.cardImageView.image = UIImage(named: "Placeholder Image")
        }
        
        return view
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
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

// MARK: Helper Functions
extension FlashCardsViewController {
    func updateNavigationBarTitle() {
        let country = UserRepository.fetch(key: .country) as? [String: String]
        self.navigationItem.title = "Top Titles for " + (country?["full"] ?? "")
    }
    
}

// MARK: News Article Card Delegate
extension FlashCardsViewController: NewsArticleCardDelegate {
    func bringBackCard() {
        topNewsKolodaView.revertAction()
    }
    
    func shareUrl() {
        guard let urlAddress = News.shared.topNews[topNewsKolodaView.currentCardIndex].url, let url = URL(string: urlAddress) else { return }
       
        let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        present(ac, animated: true)
    }
    
    func saveArticle(completion: @escaping (Bool) -> ()) {
        let articleId = topNewsKolodaView.currentCardIndex
        let article = News.shared.topNews[articleId]
        
        News.shared.saveArticle(article) { [unowned self] (isSaved) in
            if isSaved {
                self.showMessage("Article saved!", style: .success)
                completion(true)
            } else {
                self.showMessage("Could not save article!", style: .error)
                completion(false)
            }
        }
    }
    
    func unsaveArticle(completion: @escaping (Bool) -> ()) {
        let articleId = topNewsKolodaView.currentCardIndex
        let articleUrl = News.shared.topNews[articleId].url ?? ""
        
        News.shared.unsaveArticle(articleUrl) { [unowned self] (isUnsaved) in
            if isUnsaved {
                self.showMessage("Article unsaved!", style: .success)
                completion(true)
            } else {
                self.showMessage("Could not unsave article!", style: .error)
                completion(false)
            }
        }
    }
}

// MARK: User Defaults Observer Handler
extension FlashCardsViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if UserRepository.checkFor(key: .country) {
            updateNavigationBarTitle()
            
            News.shared.getTopNews { [unowned self] (news) in
                News.shared.topNews = news ?? []
                
                DispatchQueue.main.async {
                    self.topNewsKolodaView.resetCurrentCardIndex()
                }
            }
        }
    }
}
