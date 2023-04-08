//
//  WeatherDetailController.swift
//  WeatherApp
//
//  Created by Chetan Godhani on 05/04/23.
//

import UIKit

class WeatherDetailController: UIViewController {
    
    @IBOutlet weak var tempCLabel: UILabel!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationIconView: UIImageView!
    @IBOutlet weak var otherTemperatureLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var weatherData: WeatherResponse!
    var forecastData = [ForecastDay]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 0.49, green: 0.73, blue: 0.91, alpha: 1.00)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tempCLabel.text = ""
        weatherTypeLabel.text = ""
        locationLabel.text = ""
        locationIconView.isHidden = true
        otherTemperatureLabel.text = ""
        
        setupCurrentWeatherData()
    }
    
    func setupCurrentWeatherData() {
        if let weatherData = weatherData {
            tempCLabel.text = "\(weatherData.current.temp_c)°C"
            weatherTypeLabel.text = weatherData.current.condition.text
            let weatherCode = weatherData.current.condition.code
            weatherImage.image = weatherIconDictionary[weatherCode]?.generateDayImage()
            
            locationLabel.text = "\(weatherData.location.name), \(weatherData.location.region)"
            locationIconView.isHidden = false
            
            let tempData = weatherData.forecast.forecastday[0].day
            otherTemperatureLabel.text = "\(tempData.maxtemp_c)° / \(tempData.mintemp_c)° Feels like \(weatherData.current.feelslike_c)°"
            
            forecastData = weatherData.forecast.forecastday
            tableView.reloadData()
        }
    }
}

extension WeatherDetailController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension WeatherDetailController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forecastData.count
    }
    
    func getDayOfWeek(for date: String) -> String? {
        let weekDays = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let formattedDate = formatter.date(from: date) else { return "No Day" }
        
        let calendar = Calendar(identifier: .gregorian)
        let weekDay = calendar.component(.weekday, from: formattedDate)
        
        return weekDays[weekDay - 1]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // identifier is defined in that attribute inspector on the StoryBoard
        let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath)
        
        let item = forecastData[indexPath.row]
        let weatherCode = item.day.condition.code
        
        var content = cell.defaultContentConfiguration()
        content.text = "\(getDayOfWeek(for: item.date)!)"
        content.secondaryText = "\(item.day.avgtemp_c)°C"
        content.image = weatherIconDictionary[weatherCode]?.generateNightImage()
        
        cell.contentConfiguration = content
        
        return cell
    }
}
