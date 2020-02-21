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
    
    // Constants
    static let HEADER_VIEW_HEIGHT: CGFloat = 85
    static let HEADER_VIEW_X_HEIGHT: CGFloat = 120
    static let FLASH_LOGO_HEIGHT: CGFloat = 30
    static let FLASH_LOGO_WIDTH: CGFloat = 25
    
    let reachability = try! Reachability()
    var barImageView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeTopNavigationBar()
        configureTopNavigationBar(withLogo: true)
        
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
    
    func configureTopNavigationBar(withLogo: Bool) {
        
        let barImage = UIImage(named: "No Flash Bar")
        barImageView = UIImageView(image: barImage)
        
        barImageView = UIImageView(image: barImage)
        barImageView.frame = CGRect(x: 0, y: 0, width: 414, height: getHeaderImageHeightForCurrentDevice())

        view.addSubview(barImageView)
        
        if withLogo {
            
            let flashImage = UIImage(named: "Flash Image")
            let flashImageView = UIImageView(image: flashImage)
            flashImageView.frame = CGRect(x: 30, y: getHeaderImageHeightForCurrentDevice() / 2 - BaseViewController.FLASH_LOGO_HEIGHT / 2, width: BaseViewController.FLASH_LOGO_WIDTH, height: BaseViewController.FLASH_LOGO_HEIGHT)
            view.addSubview(flashImageView)
        }
        
    }
    
    func configureNoFlashTopNavigationBar() {
        
        barImageView.removeFromSuperview()
        
        let barImage = UIImage(named: "No Flash Bar")
        barImageView = UIImageView(image: barImage)
        barImageView.frame = CGRect(x: 0, y: 0, width: 414, height: getHeaderImageHeightForCurrentDevice() + 60)
        
        view.addSubview(barImageView)
        
    }
    
    func getHeaderImageHeightForCurrentDevice() -> CGFloat {
        
        if UIScreen.main.nativeBounds.height >= 2436 { // iPhone X and up
            return BaseViewController.HEADER_VIEW_X_HEIGHT
        } else {
            return BaseViewController.HEADER_VIEW_HEIGHT
        }
        
    }
    
}

