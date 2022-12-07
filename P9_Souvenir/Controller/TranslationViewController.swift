//
//  TranslationViewController.swift
//  P9_Souvenir
//
//  Created by Nicolas Schena on 18/08/2022.
//

import UIKit

class TranslationViewController: UIViewController {

    private let service = TranslationService()

    @IBOutlet weak var sourceView: UIView!
    @IBOutlet weak var sourceTextView: UITextView!
    @IBOutlet weak var translationButton: UIButton!
    @IBOutlet weak var targetView: UIView!
    @IBOutlet weak var translatedView: UIView!
    @IBOutlet weak var translatedLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        addRoundCorner()
        textViewSettings(sourceTextView)
        textViewDidBeginEditing(sourceTextView)
        textViewDidEndEditing(sourceTextView)
    }

    @IBAction func translateButton(_ sender: Any) {
        guard let textToTranslate = sourceTextView.text else {
            return
        }
        service.getTranstlation(text: textToTranslate) { result in
            DispatchQueue.main.async {
                switch result {
                case let .success(translatedText):
                    self.translatedLabel.text = translatedText.translations[0].text
                case .failure(_):
                    break
                }
            }
        }
    }
}

// MARK: - Round Corner
extension TranslationViewController {
    private func labelRoundCornered(_ view: UIView) {
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 8.0
    }

    private func roundCornered(_ button: UIButton, _ textView: UITextView) {
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8.0
        textView.layer.masksToBounds = true
        textView.layer.cornerRadius = 8.0
    }

    /// Method to add round corners to specified
    private func addRoundCorner() {
        labelRoundCornered(sourceView)
        labelRoundCornered(targetView)
        labelRoundCornered(translatedView)
        roundCornered(translationButton, sourceTextView)
    }
}

// MARK: - Keyboard
extension TranslationViewController: UITextFieldDelegate {
    @IBAction func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        sourceTextView.resignFirstResponder()
    }
}

// MARK: - TextView placeholder
extension TranslationViewController: UITextViewDelegate {
    func textViewSettings(_ textView: UITextView) {
        textView.delegate = self
        textView.text = "Saisissez du texte"
        textView.textColor = UIColor.lightGray
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Saisissez du texte"
            textView.textColor = UIColor.lightGray
        }
    }
}
