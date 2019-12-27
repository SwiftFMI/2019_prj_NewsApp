//
//  TestViewController.swift
//  Feed Me
//
//  Created by Emanuil Gospodinov on 27.12.19.
//  Copyright © 2019 Emanuil Gospodinov. All rights reserved.
//

import UIKit
import Koloda

class TestViewController: UIViewController {

   @IBOutlet weak var kolodaView: KolodaView!

   override func viewDidLoad() {
       super.viewDidLoad()

       kolodaView.dataSource = self
       kolodaView.delegate = self
   }

}

extension TestViewController: KolodaViewDelegate {
    
}

extension TestViewController: KolodaViewDataSource {
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let view = UIView()
        view.backgroundColor = UIColor.red
        
        return view
    }
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return 10
    }
    
    
}
