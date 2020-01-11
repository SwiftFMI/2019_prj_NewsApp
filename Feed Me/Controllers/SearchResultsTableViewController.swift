//
//  SearchResultsTableViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 10.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import SafariServices

class SearchResultsTableViewController: UITableViewController {

    @IBOutlet var resultsTableView: UITableView!
    
    var currentPage: Int = 1
    var currentQuery: String = ""
    
    let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        resultsTableView.delegate = self
        resultsTableView.dataSource = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return News.shared.searchResults.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let urlAddress = News.shared.searchResults[indexPath.row].url ?? ""
        
        guard let url = URL(string: urlAddress) else { return }
        
        // Open URL in Safari inside the app
        let safariVC = SFSafariViewController(url: url)
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .overFullScreen
        present(safariVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == News.shared.searchResults.count - 1 {
            let cell = resultsTableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticleLoading, for: indexPath)
            
            currentPage += 1
            
            loadNewsForPage()
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.TableCell.newsArticle, for: indexPath) as! NewsArticleTableViewCell
        
        cell.titleLabel.text = News.shared.searchResults[indexPath.row].title
        cell.descLabel.text = News.shared.searchResults[indexPath.row].description

        if let url = URL(string: News.shared.searchResults[indexPath.row].urlToImage ?? "") {
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

// MARK: Search Delegate
extension SearchResultsTableViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        currentQuery = searchBar.text ?? ""
        loadNewsForPage()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        News.shared.searchResults = []
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
    func loadNewsForPage() {
        print("Query: \(currentQuery) --- Page: \(currentPage)")
        News.shared.searchNews(page: currentPage, q: currentQuery) { (news) in
            News.shared.searchResults += news?.articles ?? []
            
            DispatchQueue.main.async {
                self.resultsTableView.reloadData()
            }
        }
    }
}
