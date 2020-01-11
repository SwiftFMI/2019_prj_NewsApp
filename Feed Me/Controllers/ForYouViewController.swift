//
//  AllNewsViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 1.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import SafariServices

class ForYouViewController: UIViewController {

    @IBOutlet weak var newsTableView: UITableView!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    var currentPage: Int = 1
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        newsTableView.addSubview(refreshControl)
        
        // make navigation bar title big
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadNewsForPage()
        
        // Observe for changes in the interests of the user
        UserDefaults.standard.addObserver(self, forKeyPath: "interests", options: .new, context: nil)
    }
}

// MARK: Helper Functions
extension ForYouViewController {
    @objc func handleRefresh() {
        // reset the page count
        currentPage = 1
        
        News.shared.getAllNews(page: currentPage) { (news) in
            News.shared.allNews = news?.articles ?? []
            
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func loadNewsForPage() {
        News.shared.getAllNews(page: currentPage) { (news) in
            News.shared.allNews += news?.articles ?? []
            
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
            }
        }
    }
}

// MARK: Table View
extension ForYouViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return News.shared.allNews.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlAddress = News.shared.allNews[indexPath.row].url ?? ""
        
        guard let url = URL(string: urlAddress) else { return }
        
        // Open URL in Safari inside the app 
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == News.shared.allNews.count {
            let cell = newsTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticleLoading, for: indexPath)
            
            currentPage += 1
            
            loadNewsForPage()
            
            return cell
        }
        
        let cell = newsTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticle, for: indexPath) as! NewsArticleTableViewCell
        
        cell.titleLabel.text = News.shared.allNews[indexPath.row].title
        cell.descLabel.text = News.shared.allNews[indexPath.row].description
        
        if let url = URL(string: News.shared.allNews[indexPath.row].urlToImage ?? "") {
            if let cachedImage = imageCache.object(forKey: NSString(string: url.absoluteString)) {
                cell.newsImage.image = cachedImage
            } else {
                cell.newsImage.load(url: url) { (image) in
                    self.imageCache.setObject(image, forKey: NSString(string: url.absoluteString))
                }
            }
            
        } else {
            cell.newsImage.image = UIImage(named: "Placeholder Image")
        }
        
        return cell
    }
}

// MARK: Safari VC Delegate
extension ForYouViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        dismiss(animated: true)
    }
}

// MARK: User Defaults Observation Handler
extension ForYouViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if UserRepository.shared.checkFor(key: .interests) {
            handleRefresh()
        }
    }
}
