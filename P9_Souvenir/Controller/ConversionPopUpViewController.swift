//
//  ConversionPopUpViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 05/09/2022.
//

import UIKit

protocol ConversionPopUpDelegate: AnyObject {
    func didSelectCurrency(index: Int)
}

class ConversionPopUpViewController: UIViewController {
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var fromCurrencyPickerView: UIPickerView!
    
    var delegate: ConversionPopUpDelegate?
    
    @IBAction func dismiss(_ sender: Any) {
        let index = returnIndex()
        delegate?.didSelectCurrency(index: index)
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRoundCornerToLabel()
    }
    
    private func returnIndex() -> Int {
        let index = fromCurrencyPickerView.selectedRow(inComponent: 0)
        return index
    }
}

// MARK: - Label
extension ConversionPopUpViewController {
    
    private func labelRoundCornered(_ label: UILabel) {
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 8.0
    }
    
    /// Method to add round corners to specified label
    private func addRoundCornerToLabel() {
        labelRoundCornered(name)
    }
}

// MARK: - PickerView
extension ConversionPopUpViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencyCode.count
    }
    
    /// PickerView Datasource
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencyCode[row]
    }
    
    /// Update label from pickerView selected row
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        name.text = currencyName[row]
    }
}
