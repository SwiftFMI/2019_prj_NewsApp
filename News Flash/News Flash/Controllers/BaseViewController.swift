//
//  BaseViewController.swift
//  News Flash
//
//  Created by Victoria Tsvetanova on 18.02.20.
//  Copyright © 2020 Emanuil Gospodinov. All rights reserved.
//

import Foundation
import Reachability
import Loaf

class BaseViewController: UIViewController {
    
    let reachability = try! Reachability()
    var barImageView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeTopNavigationBar()
        configureTopNavigationBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do {
            try reachability.startNotifier()
        } catch {
            print("Could not start reachability notifier")
        }
        
    }
    
    @objc func reachabilityChanged(note: Notification) {
        
        if reachability.connection == .unavailable {
            showMessage("No internet connection!", style: .warning)
        }
        
    }
    
    func showMessage(_ message: String, style: Loaf.State) {
        Loaf(message, state: style, location: .bottom, presentingDirection: .vertical, dismissingDirection: .vertical, sender: self).show()
    }
    
    func showError(message: String) {
        Loaf(message, state: .error, sender: self).show()
    }
    
    func removeTopNavigationBar() {
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        
    }
    
    func configureTopNavigationBar() {

        let barImage = UIImage(named: "Flash Bar")
        barImageView = UIImageView(image: barImage)
        
        self.barImageView = UIImageView(image: barImage)
        self.barImageView.frame = CGRect(x: 0, y: 0, width: 414, height: 85)

        view.addSubview(barImageView)
        
    }
    
    func configureNoFlashTopNavigationBar(isHigher: Bool) {
        
        var topBarHeight = 0
        
        if isHigher {
            topBarHeight = 150
        } else {
            topBarHeight = 85
        }
        
        barImageView.removeFromSuperview()
        
        let barImage = UIImage(named: "No Flash Bar")
        barImageView = UIImageView(image: barImage)
        barImageView.frame = CGRect(x: 0, y: 0, width: 414, height: topBarHeight)
        
        view.addSubview(barImageView)
        
    }
    
}

