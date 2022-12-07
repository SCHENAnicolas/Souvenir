//
//  ConversionViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 23/08/2022.
//

import UIKit

private enum Alert: String {
    case noFromCurrency = "Must choose the currency to convert"
    case noToCurrency = "Must choose the currency to convert into"
    case noAmount = "Amount required"
    case noResponse = "The server didn't respond"
}

class ConversionViewController: UIViewController {

    // MARK: - Properties
    private var currenciesArray: [Currency]?
    private let service = ConversionService()
    private var selectedButton: UIButton?
    private var selectedLabel: UILabel?

    // MARK: - IBOutlet
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

    // MARK: - IBAction
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

    // MARK: - Function
    private func conversionAPICall() {
        self.toggleConvertMode(shown: true)
        guard let toCurrencyCode = toCurrencyCode.currentTitle else {
            self.presentAlert(Alert.noToCurrency.rawValue)
            self.toggleConvertMode(shown: false)
            return
        }
        guard let fromCurrencyCode = fromCurrencyCode.currentTitle else {
            self.presentAlert(Alert.noFromCurrency.rawValue)
            self.toggleConvertMode(shown: false)
            return
        }
        guard let fromCurrencyAmount = fromCurrencyAmount.text,
        let amountToConvert = Double(fromCurrencyAmount) else {
            self.presentAlert(Alert.noAmount.rawValue)
            self.toggleConvertMode(shown: false)
            return
        }
        service.conversionAPICall(toCurrencyCode, fromCurrencyCode, amountToConvert) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(convertedResult):
                    self.toggleConvertMode(shown: false)
                    self.dateLabel.text = convertedResult.date
                    self.conversionRate.text = convertedResult.rate
                    self.toCurrencyAmount.text = convertedResult.result
                case let .failure(error):
                    self.presentAlert(error.rawValue)
                }
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
        service.currencyAPICall { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(symbols):
                    self.toggleActivityIndicator(shown: false)
                    self.currenciesArray = symbols
                case .failure(_):
                    self.toggleRelaunchMode()
                    self.presentAlert(Alert.noResponse.rawValue)
                }
            }
        }
    }
}

// MARK: - Present Alert
extension UIViewController {
    func presentAlert(_ message: String) {
        let alertVC = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
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
