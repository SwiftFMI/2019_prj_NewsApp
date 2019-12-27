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

class HomeViewController: UIViewController {

    @IBOutlet weak var topNewsKolodaView: KolodaView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureComponents()
        
        // Configure table view propperties
        topNewsKolodaView.delegate = self
        topNewsKolodaView.dataSource = self
        
        News.shared.getTopNews { (news) in
            News.shared.topNews = news
            
            DispatchQueue.main.async {
                self.topNewsKolodaView.reloadData()
            }
            
        }
    }
    
    func configureComponents() {
        undoButton.tintColor = UIColor(named: "Secondary Color")
        saveButton.tintColor = UIColor(named: "Primary Color")
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle.fill.badge.minus"), style: .plain, target: self, action: #selector(handleSignOut))
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            // navigating to Auth views
            let authVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.authVC) as! UINavigationController
            authVC.isNavigationBarHidden = true
            
            self.view.window?.rootViewController = authVC
            self.view.window?.makeKeyAndVisible()
        } catch let error {
            print("Failed to sign out with error", error)
        }
    }
    
    @objc func handleSignOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func undoButtonPressed(_ sender: UIButton) {
        topNewsKolodaView.revertAction()
    }
}

// MARK: Koloda View
extension HomeViewController: KolodaViewDelegate {
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
//      koloda.reloadData()
        print("Reached end of card stack")
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        let alert = UIAlertController(title: "Congratulation!", message: "Now you're \(index)", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default))
      self.present(alert, animated: true)
    }
}

extension HomeViewController: KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = NewsArticleView()
        
        view.title.text = News.shared.topNews?.articles[index].title ?? ""
        
        if let url = URL(string: News.shared.topNews?.articles[index].urlToImage ?? "") {
            view.image.load(url: url)
        } else {
            view.image.image = UIImage(named: "Placeholder Image")
        }
        
        view.desc.text = News.shared.topNews?.articles[index].description ?? ""
        
        return view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return News.shared.topNews?.articles.count ?? 0
    }
    
    
}

// MARK: UIImageView load image from url
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
