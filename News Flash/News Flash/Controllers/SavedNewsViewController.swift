//
//  SavedNewsViewController.swift
//  News Flash
//
//  Created by Emanuil Gospodinov on 23.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import SafariServices

class SavedNewsViewController: BaseViewController {

    @IBOutlet weak var savedNewsTableView: UITableView!
    @IBOutlet weak var nothingSavedView: UIView!
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nothingSavedView.isHidden = true
        
        configureTableView()

        News.shared.getSavedNews { [unowned self] (data) in
            News.shared.savedNews = data ?? []
            self.savedNewsTableView.reloadData()
            
            if News.shared.savedNews.isEmpty {
                self.nothingSavedView.isHidden = false
            } else {
                self.nothingSavedView.isHidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super .didReceiveMemoryWarning()
        
        News.shared.savedNews = []
        imageCache.removeAllObjects()
    }
    
    deinit {
        News.shared.savedNews = []
        imageCache.removeAllObjects()
    }
}

// MARK: Table View
extension SavedNewsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return News.shared.savedNews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.TableCell.newArticleHeight)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlAddress = News.shared.savedNews[indexPath.row].url ?? ""
        
        guard let url = URL(string: urlAddress) else { return }
        
        // Open URL in Safari inside the app
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticle, for: indexPath) as! NewsArticleTableViewCell
        
        cell.newsImage.image = UIImage(named: "Palceholder Image")
        cell.newsImage.isHidden = false
        
        if let url = URL(string: News.shared.savedNews[indexPath.row].urlToImage ?? "") {
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
        
        cell.titleLabel.text = News.shared.savedNews[indexPath.row].title
        cell.descriptionLabel.text = News.shared.savedNews[indexPath.row].description
        cell.sourceLabel.text = News.shared.savedNews[indexPath.row].source?.name
        cell.saved = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let article = News.shared.savedNews[indexPath.row]
        
        let action = UIContextualAction(style: .destructive, title: "Unsave") { (action, view, completion) in
            News.shared.unsaveArticle(article.url ?? "") { [unowned self] (isUnsaved) in
                if isUnsaved {
                    self.savedNewsTableView.deleteRows(at: [indexPath], with: .fade)
                    self.showMessage("Article unsaved!", style: .success)
                    
                    if News.shared.savedNews.isEmpty {
                        self.nothingSavedView.isHidden = false
                    } else {
                        self.nothingSavedView.isHidden = true
                    }
                    
                    completion(true)
                } else {
                    self.showMessage("Could not unsave article!", style: .error)
                    completion(false)
                }
            }
        }
        
        action.image = UIImage(systemName: "bookmark.fill")
        action.backgroundColor = UIColor(named: "Gray")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Share", handler: { (action, view, completionHandler) in
            guard let urlAddress = News.shared.savedNews[indexPath.row].url, let url = URL(string: urlAddress) else {
                completionHandler(false)
                return
            }
          
            let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            self.present(ac, animated: true)
            completionHandler(true)
        })
        
        action.image = UIImage(systemName: "square.and.arrow.up")
        action.backgroundColor = UIColor(named: "Seconday Button Color")
        
        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: Helper Functions
extension SavedNewsViewController {
    func configureTableView() -> Void {
        savedNewsTableView.delegate = self
        savedNewsTableView.dataSource = self
        
        savedNewsTableView.refreshControl = self.refreshControl
        
        savedNewsTableView.register(UINib(nibName: Constants.Xib.newsArticleLoadingCell, bundle: nil), forCellReuseIdentifier: Constants.TableCell.newsArticleLoading)
        savedNewsTableView.register(UINib(nibName: Constants.Xib.newsArticleCell, bundle: nil), forCellReuseIdentifier: Constants.TableCell.newsArticle)
    }
    
    @objc func handleRefresh() -> Void {
        News.shared.getSavedNews { [unowned self] (data) in
            News.shared.savedNews = data ?? []
            
            DispatchQueue.main.async {
                self.savedNewsTableView.reloadData()
                self.refreshControl.endRefreshing()
                
                if News.shared.savedNews.isEmpty {
                    self.nothingSavedView.isHidden = false
                } else {
                    self.nothingSavedView.isHidden = true
                }
            }
        }
    }

}

// MARK: Safari VC Delegate
extension SavedNewsViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let selectedCell = savedNewsTableView.indexPathForSelectedRow {
            savedNewsTableView.deselectRow(at: selectedCell, animated: true)
        }
    }
}
