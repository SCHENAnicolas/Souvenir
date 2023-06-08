//
//  HomeViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 23/08/2022.
//

import UIKit

class HomeViewController: UIViewController {
    private let service = HomeService()
    
    // MARK: - IBOutlet
    @IBOutlet weak var homeText: UILabel!
    @IBOutlet weak var homeImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        randomHomeText()
        getImage()
    }
    
    // MARK: - IBAction
    @IBAction func newImageButton(_ sender: Any) {
        self.activityIndicator.isHidden = false
        homeImageView.image = nil
        getImage()
    }
    
    // MARK: - Service's functions
    private func randomHomeText() {
        guard let cheers = service.cheers.randomElement() else {
            homeText.text = ""
            return }
        homeText.text = cheers
    }
    
    private func getImage() {
        service.getImage { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case let .success(picture):
                    self?.homeImageView.image = UIImage.init(data: picture)
                    self?.activityIndicator.isHidden = true
                case let .failure(error):
                    self?.presentAlert(error.rawValue)
                }
            }
        }
    }
}

// MARK: - Present Alert Extension
extension UIViewController {
    func presentAlert(_ message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
