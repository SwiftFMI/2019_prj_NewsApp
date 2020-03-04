//
//  ProfileViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 30.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Firebase
import TransitionButton

class ProfileViewController: BaseViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var editDetailsButton: UIButton!
    @IBOutlet weak var editInterestsButton: UIButton!
    @IBOutlet weak var appSettingsButton: UIButton!
    @IBOutlet weak var signOutButton: TransitionButton!
    @IBOutlet weak var signInButton: TransitionButton!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var collectionView: UICollectionView!
    
    var images = [String]()
    var messages = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib.init(nibName: ProfileCollectionViewCell.CELL_IDENTIFIER, bundle: nil), forCellWithReuseIdentifier: ProfileCollectionViewCell.CELL_IDENTIFIER)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        configureElements()
        fillCarouselInfoArrays()
        
        // Observe for changes in the first name of the user
        UserRepository.addObserver(self, for: .firstname)
        startTimer()
        collectionView.reloadData()
        
    }
    
    deinit {
        if isViewLoaded {
            UserRepository.removeObserver(self, for: .firstname)
        }
    }
    
    func fillCarouselInfoArrays() {
        
        images.append("WalkingManCarousel")
        images.append("BrainCarousel")
        images.append("NewsCarousel")
        messages.append("Be Connected, Be Informed")
        messages.append("Dig in the topics you love")
        messages.append("Choose your interests and what news to see")
        
        
    }
    
    func startTimer() {

        _ =  Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: true)
    }


    @objc func scrollAutomatically(_ timer1: Timer) {
        
        for cell in collectionView.visibleCells {
            
            if let indexPath = collectionView.indexPath(for: cell),
                indexPath.row < 3 {
                let indexPath1 = IndexPath.init(row: indexPath.row + 1, section: 0)
                collectionView.scrollToItem(at: indexPath1, at: .right, animated: true)
            } else {
                let indexPath1 = IndexPath.init(row: 0, section: 0)
                collectionView.scrollToItem(at: indexPath1, at: .left, animated: true)
            }
            
        }
        
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginViewController
        self.present(vc, animated: true, completion: nil)
        
    }
    
    @IBAction func signOutButtonPressed(_ sender: UIButton) {
        signOutButton.startAnimation()
        
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { (_) in
            self.signOut()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            self.signOutButton.stopAnimation()
            self.signOutButton.layer.cornerRadius = self.signOutButton.frame.height * 0.5
            self.signOutButton.clipsToBounds = true
        })
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: Helper Functions
extension ProfileViewController {
    func signOut() -> Void {
        Authentication.signOut { [unowned self] (isSingedOut) in
            if isSingedOut {
                self.signOutButton.stopAnimation(animationStyle: .expand) { [unowned self] in
                    // navigating to Auth views
                    
                    UserRepository.removeUserInfo()
                    
                    let authVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Storyboard.authVC) as! UINavigationController
                    authVC.isNavigationBarHidden = true
                    
                    self.view.window?.rootViewController = authVC
                    self.view.window?.makeKeyAndVisible()
                }
            } else {
                self.signOutButton.stopAnimation()
                self.showMessage("Could not sign out!", style: .error)
            }
        }
    }
    
    func configureElements() {
        
        if UserRepository.fetch(key: .firstname) == nil {
            
            stackView.isHidden = true
            signOutButton.isHidden = true
            stylePrimaryButton(signInButton)
            
        } else {
            
            styleSecondaryButton(editDetailsButton)
            styleSecondaryButton(editInterestsButton)
            styleSecondaryButton(appSettingsButton)
            styleDangerButton(signOutButton)
            signInButton.isHidden = true
            collectionView.isHidden = true
            
        }
        
        styleDangerButton(signOutButton)
        updateNavigationBarTitle()
        
    }
    
    func updateNavigationBarTitle() {
        self.navigationItem.title = "Hello " + (UserRepository.fetch(key: .firstname) as? String ?? "Stranger")
    }

}

// MARK: User Defaults Observer Handler
extension ProfileViewController {
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if UserRepository.checkFor(key: .firstname) {
            self.updateNavigationBarTitle()
        }
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.CELL_IDENTIFIER,
                                                      for: indexPath) as! ProfileCollectionViewCell
        
        cell.populate(with: messages[indexPath.row], with: images[indexPath.row])
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width)
        let cellHeight = floor(screenSize.height)

        return CGSize(width: cellWidth, height: cellHeight)

    }
    
}
