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
    
    
}

