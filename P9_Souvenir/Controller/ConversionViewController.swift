//
//  ConversionViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 23/08/2022.
//

import UIKit

class ConversionViewController: UIViewController {
    //        var currencyIndex = 0
    private var selectedCurrencyField: String?
    
    @IBOutlet weak var fromCurrencyName: UILabel!
    @IBOutlet weak var toCurrencyName: UILabel!
    @IBOutlet weak var fromCurrencyCode: UIButton!
    @IBOutlet weak var toCurrencyCode: UIButton!
    @IBOutlet weak var fromCurrencyAmount: UITextField!
    @IBOutlet weak var toCurrencyAmount: UITextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        appel réseau taux de conversion et symbols
    }
    
    @IBAction func fromCurrencyButton(_ sender: Any) {
        selectedCurrencyField = "from"
        getCurrencyInstruction()
    }
    
    @IBAction func toCurrencyButton(_ sender: Any) {
        selectedCurrencyField = "to"
        getCurrencyInstruction()
    }
    
    
    
    private func getCurrencyInstruction() {
        performSegue(withIdentifier: "currencySelection", sender: self)
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
        if selectedCurrencyField == "from" {
            fromCurrencyCode.setTitle("\(currencyCode[index])", for: .normal)
            fromCurrencyName.text = currencyName[index]
        } else if selectedCurrencyField == "to" {
            toCurrencyCode.setTitle("\(currencyCode[index])", for: .normal)
            toCurrencyName.text = currencyName[index]
        }
        selectedCurrencyField = nil
    }
}

extension ConversionViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let currencySelection = segue.destination as? ConversionPopUpViewController {
            currencySelection.delegate = self
        }
    }
}
