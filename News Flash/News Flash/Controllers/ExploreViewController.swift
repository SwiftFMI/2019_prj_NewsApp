//
//  ExploreViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 10.01.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import UIKit

class ExploreViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        setupNavigationBar()
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
}
