//
//  WeatherAPI.swift
//  WeatherApp
//
//  Created by Chetan Godhani on 05/04/23.
//

import Foundation
import CoreLocation
import UIKit

func getUrlWith(query: String) -> URL? {
    let baseUrl = "https://api.weatherapi.com"
    let endPoint = "/v1/forecast.json"
    let key = "726fcbb7cb9a4e45abd145200230304"
    let airQualityParam = "aqi=no"
    let daysParam = "days=7"
    let alersParam = "alerts=no"
    
    guard let url = "\(baseUrl)\(endPoint)?key=\(key)&q=\(query)&\(airQualityParam)&\(daysParam)&\(alersParam)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
        return nil
    }
    
    return URL(string: url)
}

func parseJson(data: Data) -> WeatherResponse? {
    let jsonDecoder = JSONDecoder()
    var weather: WeatherResponse?
    do {
        weather = try jsonDecoder.decode(WeatherResponse.self, from: data)
    } catch {
        print(error)
    }
    
    return weather
}

func loadWeather(search: String?, successCallback: @escaping ((_ weatherResponse: WeatherResponse, _ location: CLLocationCoordinate2D?) -> Void), errorCallback: @escaping ((_ message: String) -> Void), location: CLLocationCoordinate2D? = nil) {
    guard let search = search, !search.isEmpty else { return }
    
    // Step 1: Get URL
    guard let url: URL = getUrlWith(query: search) else {
        print("Could not get url")
        return
    }
    
    // Step 2: Create Session
    let urlSession = URLSession.shared
    
    // Step 3: Create task for session
    let dataTask = urlSession.dataTask(with: url) { data, response, error in
        guard error == nil else {
            print("Error occured:")
            print(error ?? "")
            return
        }
        
        guard let data = data else {
            print("No data found")
            return
        }
        
        guard let _ = String(data: data, encoding: .utf8) else {
            print("No data string")
            return
        }
        
        if let weatherResponse = parseJson(data: data) {
            DispatchQueue.main.async {
                successCallback(weatherResponse, location)
            }
        } else {
            DispatchQueue.main.async {
                errorCallback("Location not found")
            }
        }
    }
    
    dataTask.resume()
}


struct WeatherResponse: Decodable {
    var location: Location
    let current: Current
    let forecast: Forecast
    
    mutating func updateLocationForCurrent(currentLocation: CLLocationCoordinate2D) {
        location.lat = currentLocation.latitude
        location.lon = currentLocation.longitude
    }
}

struct Location: Decodable {
    let name: String
    let region: String
    let country: String
    var lat: Double
    var lon: Double
}

struct Current: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: WeatherCondition
    let is_day: Int
    let feelslike_c: Float
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}

struct Forecast: Decodable {
    let forecastday: [ForecastDay]
}

struct ForecastDay: Decodable {
    let date: String
    let date_epoch: Int
    let day: ForecastDayData
}

struct ForecastDayData: Decodable {
    let maxtemp_c: Float
    let mintemp_c: Float
    let avgtemp_c: Float
    let condition: WeatherCondition
}
