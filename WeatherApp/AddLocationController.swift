//
//  AddLocationController.swift
//  WeatherApp
//
//  Created by Chetan Godhani on 05/04/23.
//

import UIKit
import CoreLocation

class AddLocationController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var searchLocationTextField: UITextField!
    @IBOutlet weak var searchLocationButton: UIButton!
    @IBOutlet weak var cTemperatureLabel: UILabel!
    @IBOutlet weak var fTemperatureLabel: UILabel!
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var temperatureSwitch: UISwitch!
    
    var delegate: ReceiveWeatherData!
    
    var weatherData: WeatherResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addGestureRecognizer(UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:))))
        self.view.backgroundColor = UIColor(red: 0.49, green: 0.73, blue: 0.91, alpha: 1.00)
        
        searchLocationTextField.delegate = self
        fTemperatureLabel.text = ""
        cTemperatureLabel.text = ""
        fTemperatureLabel.isHidden = true
        locationLabel.text = ""
        weatherTypeLabel.text = ""
        locationImage.isHidden = true
        temperatureSwitch.isHidden = true
        
        let colorsConfig = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, UIColor(red: 1.00, green: 0.65, blue: 0.00, alpha: 1.00)])
        weatherConditionImage.preferredSymbolConfiguration = colorsConfig
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        loadWeather(search: textField.text!, successCallback: getWeatherData, errorCallback: showErrorAlert)
        return true
    }
    
    @IBAction func onSearchTapped(_ sender: UIButton) {
        loadWeather(search: searchLocationTextField.text!, successCallback: getWeatherData, errorCallback: showErrorAlert)
    }
    
    @IBAction func cancelButtonAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        if let weatherData = weatherData {
            delegate.updateLocationsArray(weatherData: weatherData, location: nil)
            dismiss(animated: true)
        } else {
            let message = "Please search a location"
            
            let alert = UIAlertController(title: "Save Error", message: message, preferredStyle: .alert)
            
            let okButton = UIAlertAction(title: "Dismiss", style: .default)
            
            alert.addAction(okButton)
            
            show(alert, sender: nil)
        }
    }
    
    @IBAction func onTemperatureSwitchTapped(_ sender: UISwitch) {
        if (sender.isOn) {
            cTemperatureLabel.isHidden = false
            fTemperatureLabel.isHidden = true
        } else {
            cTemperatureLabel.isHidden = true
            fTemperatureLabel.isHidden = false
        }
    }
    
    func getWeatherData(weatherData: WeatherResponse, _ location: CLLocationCoordinate2D?) -> Void {
        self.weatherData = weatherData
        locationLabel.text = "\(weatherData.location.name), \(weatherData.location.region)"
        locationImage.isHidden = false
        temperatureSwitch.isHidden = false
        
        cTemperatureLabel.text = "\(weatherData.current.temp_c)°C"
        fTemperatureLabel.text = "\(weatherData.current.temp_f)°F"
        weatherTypeLabel.text = weatherData.current.condition.text
        
        let weatherCode = weatherData.current.condition.code
        
        let nightBackgroundColor = UIColor(red: 0.16, green: 0.17, blue: 0.24, alpha: 1.00)
        let dayBackgroundColor = UIColor(red: 1.00, green: 0.75, blue: 0.58, alpha: 1.00)
        let nightTextColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00)
        let nightTextFieldColor = UIColor(red: 0.27, green: 0.29, blue: 0.40, alpha: 1.00)
        let dayTextFieldColor = UIColor(red: 1.00, green: 0.81, blue: 0.65, alpha: 1.00)
        let placeholder = searchLocationTextField.placeholder ?? ""
        
        if (weatherData.current.is_day == 0) {
            let dayColorsConfig = UIImage.SymbolConfiguration(paletteColors: [.white, .white])
            weatherConditionImage.preferredSymbolConfiguration = dayColorsConfig
            weatherConditionImage.image = weatherIconDictionary[weatherCode]?.generateNightImage()
            view.backgroundColor = nightBackgroundColor
            locationLabel.textColor = nightTextColor
            cTemperatureLabel.textColor = nightTextColor
            fTemperatureLabel.textColor = nightTextColor
            weatherTypeLabel.textColor = UIColor.white
            searchLocationTextField.backgroundColor = nightTextFieldColor
            searchLocationTextField.textColor = UIColor.white
            searchLocationTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
            
        } else {
            let nightColorsConfig = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, UIColor(red: 1.00, green: 0.65, blue: 0.00, alpha: 1.00)])
            weatherConditionImage.preferredSymbolConfiguration = nightColorsConfig
            weatherConditionImage.image = weatherIconDictionary[weatherCode]?.generateDayImage()
            view.backgroundColor = dayBackgroundColor
            locationLabel.textColor = nightBackgroundColor
            cTemperatureLabel.textColor = nightBackgroundColor
            fTemperatureLabel.textColor = nightBackgroundColor
            weatherTypeLabel.textColor = nightBackgroundColor
            searchLocationTextField.backgroundColor = dayTextFieldColor
            searchLocationTextField.textColor = UIColor.black
            searchLocationTextField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor : UIColor.placeholderText])
        }
    }
}
