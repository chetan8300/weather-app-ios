//
//  HelperExtension.swift
//  WeatherApp
//
//  Created by Chetan Godhani on 08/04/23.
//

import Foundation
import UIKit

extension UIViewController {
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Search Error", message: message, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Dismiss", style: .default)
        
        alert.addAction(okButton)
        
        show(alert, sender: nil)
    }
}
