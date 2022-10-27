//
//  Conversion.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 26/10/2022.
//

import Foundation

class Conversion {
    func calculation(_ amountToConvert: Double, _ conversionRate: Double) -> Double {
        let result = amountToConvert * conversionRate
        return result
    }
}
