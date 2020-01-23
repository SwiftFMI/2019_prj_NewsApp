//
//  ExploreViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 10.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController {

    @IBOutlet weak var categoriesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        setupNavigationBar()
        setupTableView()
    }
}

// MARK: Helper Functions
extension ExploreViewController {
    func setupNavigationBar() {
        // Make title large
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // Set Up the Search Results VC
        let searchResultsVC = storyboard?.instantiateViewController(identifier: Constants.Storyboard.searchResultsVC) as! SearchResultsTableViewController

        // Set Up the Search Bar
        let searchController = UISearchController(searchResultsController: searchResultsVC)
        searchController.searchBar.delegate = searchResultsVC
        searchController.searchResultsUpdater = searchResultsVC
        searchController.searchBar.tintColor = UIColor(named: "Primary Color")
        searchController.searchBar.placeholder = "Search..."
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
    }
    
    func setupTableView() {
        categoriesTableView.delegate = self
        categoriesTableView.dataSource = self
    }
}

// MARK: Table View
extension ExploreViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.NewsCategories.titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nextVC = storyboard?.instantiateViewController(identifier: Constants.Storyboard.categoryVC) as! CategoryViewController
        
        nextVC.navigationItem.title = Constants.NewsCategories.titles[indexPath.row].capitalized
        nextVC.navigationItem.leftBarButtonItem?.tintColor = UIColor(named: "Primary Color")
        
        nextVC.category = Constants.NewsCategories.titles[indexPath.row]
        
        nextVC.loadNewsByCategory(Constants.NewsCategories.titles[indexPath.row])
        
        navigationController?.pushViewController(nextVC, animated: true)
        
        categoriesTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "categoryCell")
        
        cell.textLabel?.text = Constants.NewsCategories.titles[indexPath.row].capitalized
        cell.imageView?.image = Constants.NewsCategories.images[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}
