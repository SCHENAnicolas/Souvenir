//
//  Translation.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 29/11/2022.
//

import Foundation

// MARK: - Translation
struct Translation: Codable {
    let translations: [TranslationElement]
}

// MARK: - TranslationElement
struct TranslationElement: Codable {
    let text: String
}
