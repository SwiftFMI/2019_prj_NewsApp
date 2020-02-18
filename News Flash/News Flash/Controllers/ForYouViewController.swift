//
//  AllNewsViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 1.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import SafariServices
import Loaf

class ForYouViewController: BaseViewController {

    @IBOutlet weak var newsTableView: UITableView!
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var currentPage: Int = 1
    
    private var keepLoading = true
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("loaded")
        
        configureTableView()
        
        loadNewsForPage()
        
        // Observe for changes in the interests of the user
        UserRepository.addObserver(self, for: .interests)
        UserRepository.addObserver(self, for: .resultLanguage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        News.shared.allNews = []
        imageCache.removeAllObjects()
    }
    
    deinit {
        News.shared.allNews = []
        imageCache.removeAllObjects()
        
        if isViewLoaded {
            UserRepository.removeObserver(self, for: .interests)
            UserRepository.removeObserver(self, for: .resultLanguage)
        }
    }
}

// MARK: Helper Functions
extension ForYouViewController {
    @objc func handleRefresh() {
        // reset the page count
        currentPage = 1
        
        News.shared.getAllNews(page: currentPage) { [unowned self] (news) in
            if let news = news {
                self.keepLoading = true
                
                News.shared.allNews = news
                
                DispatchQueue.main.async {
                    self.newsTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
            } else {
                self.keepLoading = false
                DispatchQueue.main.async {
                    self.showMessage("Could not load the articles", style: .warning)
                }
            }
        }
    }
    
    func configureTableView() {
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        newsTableView.refreshControl = self.refreshControl
        
        newsTableView.register(UINib(nibName: Constants.Xib.newsArticleLoadingCell, bundle: nil), forCellReuseIdentifier: Constants.TableCell.newsArticleLoading)
        newsTableView.register(UINib(nibName: Constants.Xib.newsArticleCell, bundle: nil), forCellReuseIdentifier: Constants.TableCell.newsArticle)
    }
    
    func loadNewsForPage() {
        News.shared.getAllNews(page: currentPage) { [unowned self] (news) in
            if let news = news {
                self.keepLoading = true
                
                News.shared.allNews += news
                
                DispatchQueue.main.async {
                    self.newsTableView.reloadData()
                }
            } else {
                self.keepLoading = false
                DispatchQueue.main.async {
                    self.showMessage("Could not load the articles", style: .warning)
                }
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
        return CGFloat(Constants.TableCell.newArticleHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == News.shared.searchResults.count {
            newsTableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let urlAddress = News.shared.allNews[indexPath.row].url ?? ""
        
        guard let url = URL(string: urlAddress) else { return }
        
        // Open URL in Safari inside the app 
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == News.shared.allNews.count && self.keepLoading {
            let cell = newsTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticleLoading, for: indexPath)
            
            currentPage += 1
            
            loadNewsForPage()
            
            return cell
        }
        
        let cell = newsTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticle, for: indexPath) as! NewsArticleTableViewCell
        
        cell.newsImage.image = UIImage(named: "Palceholder Image")
        cell.newsImage.isHidden = false
        
        if let urlString = News.shared.allNews[indexPath.row].urlToImage, let url = URL(string: urlString) {
            if let cachedImage = imageCache.object(forKey: NSString(string: url.absoluteString)) {
                cell.newsImage.image = cachedImage
            } else {
                cell.newsImage.load(url: url) { (image) in
                    self.imageCache.setObject(image, forKey: NSString(string: url.absoluteString))
                }
            }
        } else {
            cell.newsImage.isHidden = true
        }
        
        cell.titleLabel.text = News.shared.allNews[indexPath.row].title
        cell.descriptionLabel.text = News.shared.allNews[indexPath.row].description
        cell.sourceLabel.text = News.shared.allNews[indexPath.row].source?.name
        cell.saved = News.shared.savedUrls.contains(News.shared.allNews[indexPath.row].url ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = newsTableView.cellForRow(at: indexPath) as! NewsArticleTableViewCell
        
        let label: String = cell.saved ? "Unsave" : "Save"
        let image: UIImage = cell.saved ? UIImage(systemName: "bookmark.fill")! : UIImage(systemName: "bookmark")!
        let color: UIColor = cell.saved ? UIColor(named: "Gray")! : UIColor(named: "Secondary Button Color")!
        
        let action = UIContextualAction(style: .normal, title: label, handler: { (action, view, completionHandler) in
            let article = News.shared.allNews[indexPath.row]
            
            if cell.saved {
                // unsave
                News.shared.unsaveArticle(article.url ?? "") { [unowned self] (isUnsaved) in
                    if isUnsaved {
                        cell.saved = false
                        self.showMessage("Article unsaved!", style: .success)
                    } else {
                        self.showMessage("Could not unsave article!", style: .error)
                    }
                }
            } else {
                // save
                News.shared.saveArticle(article) { [unowned self] (isSaved) in
                    if isSaved {
                        cell.saved = true
                        self.showMessage("Article saved!", style: .success)
                    } else {
                        self.showMessage("Could not save article!", style: .error)
                    }
                }
            }
            completionHandler(true)
        })
        
        action.image = image
        action.backgroundColor = color
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Share",
          handler: { (action, view, completionHandler) in
            guard let urlAddress = News.shared.allNews[indexPath.row].url, let url = URL(string: urlAddress) else {
                completionHandler(false)
                return
            }
          
            let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(ac, animated: true)
            completionHandler(true)
        })
        
        action.image = UIImage(systemName: "square.and.arrow.up")
        action.backgroundColor = UIColor(named: "Secondary Button Color")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: Safari VC Delegate
extension ForYouViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let selectedCell = newsTableView.indexPathForSelectedRow {
            newsTableView.deselectRow(at: selectedCell, animated: true)
        }
    }
}

// MARK: User Defaults Observer Handler
extension ForYouViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if UserRepository.checkFor(key: .interests), UserRepository.checkFor(key: .resultLanguage) {
            handleRefresh()
        }
    }
}
