//
//  CategoryViewController.swift
//  News Flash
//
//  Created by Emanuil Gospodinov on 23.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import SafariServices
import Loaf

class CategoryViewController: UIViewController {

    @IBOutlet weak var articlesTableView: UITableView!
    
    let imageCache = NSCache<NSString, UIImage>()
    
    var category: String?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureTableView()
    }

    override func viewDidDisappear(_ animated: Bool) {
        // reset the news array
        News.shared.categoryNews = []
    }
    
    override func didReceiveMemoryWarning() {
        News.shared.categoryNews = []
        imageCache.removeAllObjects()
    }
    
    deinit {
        News.shared.categoryNews = []
        imageCache.removeAllObjects()
    }
}

// MARK: Helper Functions
extension CategoryViewController {
    func configureTableView() {
        articlesTableView.delegate = self
        articlesTableView.dataSource = self
        
        articlesTableView.register(UINib(nibName: Constants.Xib.newsArticleLoadingCell, bundle: nil), forCellReuseIdentifier: Constants.TableCell.newsArticleLoading)
        articlesTableView.register(UINib(nibName: Constants.Xib.newsArticleCell, bundle: nil), forCellReuseIdentifier: Constants.TableCell.newsArticle)
        
        articlesTableView.refreshControl = self.refreshControl
    }
    
    func loadNewsByCategory(_ category: String) {
        News.shared.getByCategory(category, includeCountry: true) { [unowned self] (data) in
            News.shared.categoryNews = data ?? []
            
            DispatchQueue.main.async {
                self.articlesTableView.reloadData()
            }
        }
    }
    
    func showMessage(_ message: String, style: Loaf.State) {
        Loaf(message, state: style, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
    
    @objc func handleRefresh() {
        if let category = self.category {
            loadNewsByCategory(category)
        }
    }
}

// MARK: Table View
extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return News.shared.categoryNews.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.TableCell.newArticleHeight)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = articlesTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticle, for: indexPath) as! NewsArticleTableViewCell
        
        cell.newsImage.image = UIImage(named: "Palceholder Image")
        cell.newsImage.isHidden = false
        
        if let url = URL(string: News.shared.categoryNews[indexPath.row].urlToImage ?? "") {
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
        
        cell.titleLabel.text = News.shared.categoryNews[indexPath.row].title
        cell.descriptionLabel.text = News.shared.categoryNews[indexPath.row].description
        cell.sourceLabel.text = News.shared.categoryNews[indexPath.row].source?.name
        cell.saved = News.shared.savedUrls.contains(News.shared.categoryNews[indexPath.row].url ?? "")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlAddress = News.shared.categoryNews[indexPath.row].url ?? ""
        
        guard let url = URL(string: urlAddress) else { return }
        
        // Open URL in Safari inside the app
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let cell = articlesTableView.cellForRow(at: indexPath) as! NewsArticleTableViewCell
        
        let label: String = cell.saved ? "Unsave" : "Save"
        let image: UIImage = cell.saved ? UIImage(systemName: "bookmark.fill")! : UIImage(systemName: "bookmark")!
        let color: UIColor = cell.saved ? UIColor(named: "Gray")! : UIColor(named: "Secondary Button Color")!
        
        let action = UIContextualAction(style: .normal, title: label, handler: { (action, view, completionHandler) in
            let article = News.shared.categoryNews[indexPath.row]
            
            if cell.saved {
                // unsave
                News.shared.unsaveArticle(article.url ?? "") { (isUnsaved) in
                    if isUnsaved {
                        cell.saved = false
                        self.showMessage("Article unsaved!", style: .success)
                    } else {
                        self.showMessage("Could not unsave article!", style: .error)
                    }
                }
            } else {
                // save
                News.shared.saveArticle(article) { (isSaved) in
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
            guard let urlAddress = News.shared.categoryNews[indexPath.row].url, let url = URL(string: urlAddress) else {
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
extension CategoryViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let selectedCell = articlesTableView.indexPathForSelectedRow {
            articlesTableView.deselectRow(at: selectedCell, animated: true)
        }
    }
}
