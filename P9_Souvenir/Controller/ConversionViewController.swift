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
    private let service = ConversionService()
    private var selectedButton: UIButton?
    private var selectedLabel: UILabel?
    
    //    MARK: - IBOutlet
    @IBOutlet weak var fromCurrencyName: UILabel!
    @IBOutlet weak var toCurrencyName: UILabel!
    @IBOutlet weak var fromCurrencyCode: UIButton!
    @IBOutlet weak var toCurrencyCode: UIButton!
    @IBOutlet weak var fromCurrencyAmount: UITextField!
    @IBOutlet weak var toCurrencyAmount: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var conversionRate: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var relaunch: UIButton!
    @IBOutlet weak var convert: UIButton!
    
    // MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        addRoundCornerToLabel()
        activityIndicator.startAnimating()
        currencyAPICall()
    }
    
    //    MARK: - IBAction
    @IBAction func fromCurrencyButton(_ sender: UIButton) {
        selectedButton = sender
        selectedLabel = fromCurrencyName
        getCurrencyInstruction()
    }
    
    @IBAction func toCurrencyButton(_ sender: UIButton) {
        selectedButton = sender
        selectedLabel = toCurrencyName
        getCurrencyInstruction()
    }
    
    @IBAction func relaunchButton(_ sender: Any) {
        currencyAPICall()
    }
    
    @IBAction func convertButton(_ sender: Any) {
        conversionAPICall()
    }
    
    //    MARK: - Function
    private func conversionAPICall() {
        self.toggleConvertMode(shown: true)
        guard let toCurrencyCode = toCurrencyCode.currentTitle,
              let fromCurrencyCode = fromCurrencyCode.currentTitle,
              let fromCurrencyAmount = fromCurrencyAmount.text,
              let amountToConvert = Double(fromCurrencyAmount) else {
                  self.toggleConvertMode(shown: false)
                  return
              }
        service.conversionAPICall(toCurrencyCode, fromCurrencyCode, amountToConvert) { success, convertedResult in
            DispatchQueue.main.async{
                self.toggleConvertMode(shown: false)
                self.dateLabel.text = convertedResult.date
                self.conversionRate.text = convertedResult.rate
                self.toCurrencyAmount.text = convertedResult.result
            }
        }
    }
    
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
        fromCurrencyCode.isEnabled = !shown
        fromCurrencyAmount.isEnabled = !shown
        convert.isEnabled = !shown
    }
    
    private func toggleRelaunchMode() {
        activityIndicator.isHidden = true
        relaunch.isHidden = false
    }
    
    private func toggleConvertMode(shown: Bool) {
        if shown == true {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        convert.isHidden = shown
        activityIndicator.isHidden = !shown
    }
    
    private func currencyAPICall() {
        toggleActivityIndicator(shown: true)
        self.relaunch.isHidden = true
        service.currencyAPICall { currencies in
            DispatchQueue.main.async{
                self.toggleActivityIndicator(shown: false)
                self.currenciesArray = currencies
            }
        } errorHandler: {
            DispatchQueue.main.async{
                self.presentAlert()
                self.toggleRelaunchMode()
            }
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
        selectedButton?.setTitle("\(currency.code)", for: .normal)
        selectedLabel?.text = currency.name
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
        labelRoundCornered(toCurrencyAmount)
    }
}
