//
//  SearchResultsTableViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 10.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import SafariServices
import Loaf

class SearchResultsTableViewController: UITableViewController {

    @IBOutlet var resultsTableView: UITableView!
    
    private var currentPage: Int = 1
    private var currentQuery: String = ""
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    private var keepLoading = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureTableView()
        
//        configureNoFlashTopNavigationBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        imageCache.removeAllObjects()
        News.shared.searchResults = []
    }
    
    deinit {
        imageCache.removeAllObjects()
        News.shared.searchResults = []
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return News.shared.searchResults.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(Constants.TableCell.newArticleHeight)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == News.shared.searchResults.count {
            resultsTableView.deselectRow(at: indexPath, animated: true)
            return
        }
        
        let urlAddress = News.shared.searchResults[indexPath.row].url ?? ""
        
        guard let url = URL(string: urlAddress) else { return }
        
        // Open URL in Safari inside the app
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == News.shared.searchResults.count && keepLoading {
            let cell = resultsTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticleLoading, for: indexPath)
            
            if currentQuery != "" {
                currentPage += 1
                loadNewsForPage()
            }
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticle, for: indexPath) as! NewsArticleTableViewCell
        
        cell.newsImage.image = UIImage(named: "Palceholder Image")
        cell.newsImage.isHidden = false
        
        if News.shared.searchResults.count > indexPath.row,
            let url = URL(string: News.shared.searchResults[indexPath.row].urlToImage ?? "") {
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
        
        cell.titleLabel.text = News.shared.searchResults[indexPath.row].title
        cell.descriptionLabel.text = News.shared.searchResults[indexPath.row].description
        cell.sourceLabel.text = News.shared.searchResults[indexPath.row].source?.name
        cell.saved = News.shared.savedUrls.contains(News.shared.searchResults[indexPath.row].url ?? "")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let cell = resultsTableView.cellForRow(at: indexPath) as! NewsArticleTableViewCell
        
        let label: String = cell.saved ? "Unsave" : "Save"
        let image: UIImage = cell.saved ? UIImage(systemName: "bookmark.fill")! : UIImage(systemName: "bookmark")!
        let color: UIColor = cell.saved ? UIColor(named: "Gray")! : UIColor(named: "Secondary Button Color")!
        
        let action = UIContextualAction(style: .normal, title: label, handler: { (action, view, completionHandler) in
            let article = News.shared.searchResults[indexPath.row]
            
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .normal, title: "Share",
          handler: { (action, view, completionHandler) in
            guard let urlAddress = News.shared.searchResults[indexPath.row].url, let url = URL(string: urlAddress) else {
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

// MARK: Search Delegate
extension SearchResultsTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        resultsTableView.isHidden = true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentQuery = searchBar.text ?? ""
        resultsTableView.isHidden = false
        News.shared.searchResults = []
        loadNewsForPage()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        News.shared.searchResults = []
        resultsTableView.reloadData()
    }
}

// MARK: Safari Delegate
extension SearchResultsTableViewController: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        if let selectedRow = resultsTableView.indexPathForSelectedRow {
            resultsTableView.deselectRow(at: selectedRow, animated: true)
        }
    }
}

// MARK: Helper Functions
extension SearchResultsTableViewController {
    func configureTableView() -> Void {
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        
        resultsTableView.register(UINib(nibName: Constants.Xib.newsArticleCell, bundle: nil), forCellReuseIdentifier: Constants.TableCell.newsArticle)
        resultsTableView.register(UINib(nibName: Constants.Xib.newsArticleLoadingCell, bundle: nil), forCellReuseIdentifier: Constants.TableCell.newsArticleLoading)
    }
    
    func loadNewsForPage() {
        
        News.shared.searchNews(page: currentPage, q: currentQuery) { [unowned self] (news) in
            
            if let news = news {
                self.keepLoading = true
                
                News.shared.searchResults += news
                
                DispatchQueue.main.async {
                    self.resultsTableView.reloadData()
                }
            } else {
                self.keepLoading = false
                
                DispatchQueue.main.async {
                    self.showMessage("Could not load the articles", style: .warning)
                }
            }
        }
    }
    
    func showMessage(_ message: String, style: Loaf.State) {
        Loaf(message, state: style, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
    
//    func configureNoFlashTopNavigationBar() {
//
//        let barImage = UIImage(named: "No Flash Bar")
//        let barImageView = UIImageView(image: barImage)
//        barImageView.frame = CGRect(x: 0, y: -75, width: 414, height: getHeaderImageHeightForCurrentDevice() + 20)
//
//        view.addSubview(barImageView)
//
//    }
//
//    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
//
//        if UIScreen.main.nativeBounds.height >= 2436 { // iPhone X and up
//            return BaseViewController.HEADER_VIEW_X_HEIGHT
//        } else {
//            return BaseViewController.HEADER_VIEW_HEIGHT
//        }
//
//    }
    
}

