//
//  HomeViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 23/08/2022.
//

import UIKit

class HomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        randomHomeText()
    }
    
    @IBOutlet weak var homeText: UILabel!
    
    private func randomHomeText() {
        if let goGo = encouragement.randomElement() {
            homeText.text = "\(goGo)"
        } else {
            homeText.text = ""
        }
    }
}
