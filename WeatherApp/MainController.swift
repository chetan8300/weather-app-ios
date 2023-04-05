//
//  MainController.swift
//  WeatherApp
//
//  Created by Chetan Godhani on 03/04/23.
//

import UIKit
import MapKit

class MainController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    private let locationManager = CLLocationManager()
    
    private var currentLocationAdded = false
    
    private var locationData = [WeatherResponse]()
    
    private var addLocationScreenSegue = "navigateToAddLocation"
    private var weatherDetailScreenSegue = "navigateToWeatherDetail"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupLocation()
        setupMap()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addLocationScreenSegue {
            print("Navigating to Add Location Screen")
        } else if segue.identifier == weatherDetailScreenSegue {
            print("Navigating to Weather Detail Screen")
        }
    }
    
    private func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }

    private func addLocationAnnotation(location: CLLocationCoordinate2D, weatherData: WeatherResponse) {
        let annotation = MyAnnotation(coordinate: location, weatherData: weatherData)
        
        mapView.addAnnotation(annotation)
    }

    private func setupMap() {
        // set delegate
        mapView.delegate = self
        
        guard let location = locationManager.location else {
            return
        }
        
        loadWeather(search: "\(location.coordinate.latitude),\(location.coordinate.longitude)", location: location.coordinate)

        let radiusInMeters: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        mapView.setRegion(region, animated: true)
        
        // control zooming
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    @IBAction func navigateToWeatherDetailAction(sender: UIButton) {
        performSegue(withIdentifier: weatherDetailScreenSegue, sender: self)
    }
    
    @IBAction func addLocationButtonAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: addLocationScreenSegue, sender: self)
    }
    
    private func getUrlWith(query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com"
        let endPoint = "/v1/current.json"
        let key = "9069e104d6a04c4d959172320231503"
        let airQualityParam = "aqi=no"
        
        guard let url = "\(baseUrl)\(endPoint)?key=\(key)&q=\(query)&\(airQualityParam)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }

        return URL(string: url)
    }

    private func parseJson(data: Data) -> WeatherResponse? {
        let jsonDecoder = JSONDecoder()
        var weather: WeatherResponse?
        do {
            weather = try jsonDecoder.decode(WeatherResponse.self, from: data)
        } catch {
            print(error)
        }
        
        return weather
    }
    
    private func loadWeather(search: String?, location: CLLocationCoordinate2D? = nil) {
        guard let search = search, !search.isEmpty else { return }
        
        // Step 1: Get URL
        guard let url: URL = getUrlWith(query: search) else {
            print("Could not get url")
            return
        }
        
        // Step 2: Create Session
        let urlSession = URLSession.shared
        
        // Step 3: Create task for session
        let dataTask = urlSession.dataTask(with: url) { [self] data, response, error in
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

            if let weatherResponse = self.parseJson(data: data) {
                DispatchQueue.main.async {
                    self.locationData.append(weatherResponse)
                    if let location = location {
                        self.addLocationAnnotation(location: location, weatherData: weatherResponse)
                    } else {
                        let newLocation = CLLocationCoordinate2D(latitude: weatherResponse.location.lat, longitude: weatherResponse.location.lon)
                        self.addLocationAnnotation(location: newLocation, weatherData: weatherResponse)
                    }
                }
            }
        }
        
        dataTask.resume()
    }
}

extension MainController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myIdentifier"
        var view: MKMarkerAnnotationView
        
        // Check if the identifier exist for reuse
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            // get updated annotation view
            dequeuedView.annotation = annotation
            
            // use our reusable view
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            
            // set position of callout
            view.calloutOffset = CGPoint(x: 0, y: 20)
            
            // change color of pin
            view.markerTintColor = .systemBlue
            
            // change color of accessories
            view.tintColor = .systemRed
            
            if let annotation = annotation as? MyAnnotation {
                // change marker glyph
                view.glyphText = annotation.glyphText

                let imageView = UIImageView(image: annotation.weatherImage)
                imageView.preferredSymbolConfiguration = annotation.symbolConfiguration
                view.leftCalloutAccessoryView = imageView
                
                // add a button to right side of callout
                let button = UIButton(type: .detailDisclosure)
                button.addTarget(self, action: #selector(self.navigateToWeatherDetailAction(sender:)), for: .touchUpInside)
                view.rightCalloutAccessoryView = button
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Tapped \(control.tag)")
    }
}

extension MainController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = locations.last {
            if (!currentLocationAdded) {
                currentLocationAdded = true
                setupMap()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    var weatherImage: UIImage?
    var symbolConfiguration: UIImage.SymbolConfiguration?
    
    init(coordinate: CLLocationCoordinate2D, weatherData: WeatherResponse) {
        let tempC = "\(Int(weatherData.current.temp_c.rounded(.toNearestOrEven)))°C"
        let feelLikeC = "\(Int(weatherData.current.feelslike_c.rounded(.toNearestOrEven)))°C"
        let weatherCondition = weatherData.current.condition.text
        let weatherCode = weatherData.current.condition.code
        let weatherImage = weatherIconDictionary[weatherCode]?.generateNightImage()
        
        if (weatherData.current.is_day == 0) {
            self.symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.white, .white])
        } else {
            self.symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, UIColor(red: 1.00, green: 0.65, blue: 0.00, alpha: 1.00)])
        }
        
        self.coordinate = coordinate
        self.title = weatherCondition
        self.subtitle = "Temp: \(tempC), Feels like: \(feelLikeC)"
        self.glyphText = tempC
        self.weatherImage = weatherImage
        
        super.init()
    }
}

struct WeatherResponse: Decodable {
    let location: Location
    let current: Current
}

struct Location: Decodable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
}

struct Current: Decodable {
    let temp_c: Float
    let condition: WeatherCondition
    let is_day: Int
    let feelslike_c: Float
}

struct WeatherCondition: Decodable {
    let text: String
    let code: Int
}
