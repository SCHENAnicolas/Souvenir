//
//  ConversionViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 23/08/2022.
//

import UIKit

class ConversionViewController: UIViewController {
    
//    MARK: - Properties
    private var currenciesArray: [Currency]?
    private var conversionIndex = 0
    private var conversion = Conversion()
    
//    MARK: - IBOutlet
    @IBOutlet weak var fromCurrencyName: UILabel!
    @IBOutlet weak var toCurrencyName: UILabel!
    @IBOutlet weak var fromCurrencyCode: UILabel!
    @IBOutlet weak var toCurrencyCode: UIButton!
    @IBOutlet weak var fromCurrencyAmount: UITextField!
    @IBOutlet weak var toCurrencyAmount: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conversionRate: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var relaunch: UIButton!
    @IBOutlet weak var convert: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRoundCornerToLabel()
        activityIndicator.startAnimating()
        currencyAPICall()
    }
    
//    MARK: - IBAction
    @IBAction func toCurrencyButton(_ sender: Any) {
        getCurrencyInstruction()
    }
    
    @IBAction func relaunchButton(_ sender: Any) {
        currencyAPICall()
    }
    
    @IBAction func convertButton(_ sender: Any) {
        let amountToConvert: Double? = Double(fromCurrencyAmount.text!)
        let conversionRate = currenciesArray![conversionIndex].rate
        guard let amountToConvert = amountToConvert else {
            return
        }
        let result: String? = String(conversion.calculation(amountToConvert, conversionRate))
        toCurrencyAmount.text = result
    }
    
//    MARK: - Function
    private func getCurrencyInstruction() {
        performSegue(withIdentifier: "currencySelection", sender: self)
    }
    
    private func toggleActivityIndicator(shown: Bool) {
        if shown == true {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        conversionRate.isHidden = shown
        dateLabel.isHidden = shown
        activityIndicator.isHidden = !shown
        toCurrencyCode.isEnabled = !shown
        convert.isEnabled = !shown
    }
    
    private func toggleRelaunchMode() {
        activityIndicator.isHidden = true
        relaunch.isHidden = false
    }
    
    private func currencyAPICall() {
        toggleActivityIndicator(shown: true)
        ConversionService.shared.currencyAPICall { currencies in
            self.toggleActivityIndicator(shown: false)
            self.relaunch.isHidden = true
            self.currenciesArray = currencies
        } errorHandler: {
            self.presentAlert()
            self.toggleRelaunchMode()
        }
    }
    
    private func presentAlert() {
        let alertVC = UIAlertController(title: "Error", message: "The server didn't respond", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}


// MARK: - Keyboard
extension ConversionViewController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        fromCurrencyAmount.resignFirstResponder()
    }
}

// MARK: - Delegate
extension ConversionViewController: ConversionPopUpDelegate {
    func didSelectCurrency(index: Int) {
        guard let currencies = currenciesArray else {
            return
        }
        let currency = currencies[index]
        toCurrencyCode.setTitle("\(currency.code)", for: .normal)
        toCurrencyName.text = currency.name
        conversionRate.text = "Conversion rate :\n\(currency.rate)"
        conversionIndex = index
    }
}

extension ConversionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let currencySelection = segue.destination as? ConversionPopUpViewController {
            currencySelection.delegate = self
            currencySelection.currenciesArray = currenciesArray
        }
    }
}

// MARK: - Label
extension ConversionViewController {
    
    private func labelRoundCornered(_ label: UILabel) {
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8.0
    }
    
    /// Method to add round corners to specified label
    private func addRoundCornerToLabel() {
        labelRoundCornered(fromCurrencyCode)
        labelRoundCornered(toCurrencyAmount)
    }
}
