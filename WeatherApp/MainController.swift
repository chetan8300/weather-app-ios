//
//  MainController.swift
//  WeatherApp
//
//  Created by Chetan Godhani on 03/04/23.
//

import UIKit
import MapKit

class MainController: UIViewController, ReceiveWeatherData {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    private let locationManager = CLLocationManager()
    
    private var currentLocationAdded = false
    
    private var locationData = [WeatherResponse]()
    private let radiusInMeters: CLLocationDistance = 1000
    
    private var addLocationScreenSegue = "navigateToAddLocation"
    private var weatherDetailScreenSegue = "navigateToWeatherDetail"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        setupLocation()
        setupMap()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == addLocationScreenSegue {
            // Navigating to Add Location Screen
            let addLocationController = segue.destination as! AddLocationController
            addLocationController.delegate = self
        } else if segue.identifier == weatherDetailScreenSegue {
            // Navigating to Weather Detail Screen
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
        
        loadWeather(search: "\(location.coordinate.latitude),\(location.coordinate.longitude)", callback: updateLocationsArray, location: location.coordinate)

        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        mapView.setRegion(region, animated: true)
        
        // control zooming
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    @IBAction func addLocationButtonAction(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: addLocationScreenSegue, sender: self)
    }
    
    func updateLocationsArray(weatherData: WeatherResponse, location: CLLocationCoordinate2D? = nil) {
        if let location = location {
            addLocationAnnotation(location: location, weatherData: weatherData)
            var weather = WeatherResponse(location: weatherData.location, current: weatherData.current, forecast: weatherData.forecast)
            weather.updateLocationForCurrent(currentLocation: location)
            locationData.append(weather)
        } else {
            let newLocation = CLLocationCoordinate2D(latitude: weatherData.location.lat, longitude: weatherData.location.lon)
            addLocationAnnotation(location: newLocation, weatherData: weatherData)
            locationData.append(weatherData)
        }
        
        tableView.reloadData()
    }
}

extension MainController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = String(abs(annotation.hash.hashValue))
        var view: MKMarkerAnnotationView
        
        // Check if the identifier exist for reuse
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            // get updated annotation view
            dequeuedView.annotation = annotation
            
            if let annotation = annotation as? MyAnnotation {
                // don't know why but changing the region, changes the glyphtext and color - so setting them again
                dequeuedView.glyphText = annotation.glyphText
                dequeuedView.markerTintColor = annotation.markerTintColor
            }
            
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
                view.markerTintColor = annotation.markerTintColor

                let imageView = UIImageView(image: annotation.weatherImage)
                imageView.preferredSymbolConfiguration = annotation.symbolConfiguration
                view.leftCalloutAccessoryView = imageView
                
                // add a button to right side of callout
                let button = UIButton(type: .detailDisclosure)
                button.addAction(
                        UIAction { _ in
                            self.performSegue(withIdentifier: self.weatherDetailScreenSegue, sender: annotation.weatherData)
                        }, for: .touchUpInside)
                view.rightCalloutAccessoryView = button
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MyAnnotation {
            performSegue(withIdentifier: weatherDetailScreenSegue, sender: annotation.weatherData)
        }
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

extension MainController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // identifier is defined in that attribute inspector on the StoryBoard
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherDataCell", for: indexPath)
        
        let item = locationData[indexPath.row]
        let tempData = item.forecast.forecastday[0].day
        let weatherCode = item.current.condition.code
        
        var content = cell.defaultContentConfiguration()
        content.text = "\(item.location.name), \(item.location.region)"
        content.secondaryText = "\(item.current.temp_c)°C (H:\(tempData.maxtemp_c)°C, L:\(tempData.mintemp_c)°C)"
        content.image = weatherIconDictionary[weatherCode]?.generateNightImage()
        
        cell.contentConfiguration = content
        
        return cell
    }
}

extension MainController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = locationData[indexPath.row]
        let location = CLLocationCoordinate2D(latitude: item.location.lat, longitude: item.location.lon)
        
        let region = MKCoordinateRegion(center: location, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        mapView.setRegion(region, animated: true)
    }
}

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    var weatherImage: UIImage?
    var symbolConfiguration: UIImage.SymbolConfiguration?
    var markerTintColor: UIColor
    var weatherData: WeatherResponse
    
    init(coordinate: CLLocationCoordinate2D, weatherData: WeatherResponse) {
        let tempC = "\(weatherData.current.temp_c)°C"
        let feelLikeC = "\(weatherData.current.feelslike_c)°C"
        let weatherCondition = weatherData.current.condition.text
        let weatherCode = weatherData.current.condition.code
        let weatherImage = weatherIconDictionary[weatherCode]?.generateNightImage()
        
        if (weatherData.current.is_day == 0) {
            self.symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemBlue])
        } else {
            self.symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, UIColor(red: 1.00, green: 0.65, blue: 0.00, alpha: 1.00)])
        }
        
        self.markerTintColor = UIColor(red: 0.63, green: 0.13, blue: 0.94, alpha: 1.00)
        if (weatherData.current.temp_c > 30) {
            // Very hot
            self.markerTintColor = UIColor(red: 0.41, green: 0.03, blue: 0.03, alpha: 1.00)
        } else if (weatherData.current.temp_c > 24 && weatherData.current.temp_c <= 30) {
            // Hot
            self.markerTintColor = UIColor(red: 0.71, green: 0.28, blue: 0.28, alpha: 1.00)
        } else if (weatherData.current.temp_c > 16 && weatherData.current.temp_c <= 24) {
            // Warm
            self.markerTintColor = UIColor(red: 1.00, green: 0.79, blue: 0.48, alpha: 1.00)
        } else if (weatherData.current.temp_c > 11 && weatherData.current.temp_c <= 16) {
            // Cool
            self.markerTintColor = UIColor(red: 0.68, green: 0.85, blue: 0.90, alpha: 1.00)
        } else if (weatherData.current.temp_c >= 0 && weatherData.current.temp_c <= 11) {
            // Cold
            self.markerTintColor = UIColor(red: 0.22, green: 0.49, blue: 0.74, alpha: 1.00)
        }
        
        self.coordinate = coordinate
        self.title = weatherCondition
        self.subtitle = "Temp: \(tempC), Feels like: \(feelLikeC)"
        self.glyphText = "\(Int(weatherData.current.temp_c.rounded(.toNearestOrEven)))°C"
        self.weatherImage = weatherImage
        self.weatherData = weatherData
        
        super.init()
    }
}

protocol ReceiveWeatherData {
  func updateLocationsArray(weatherData: WeatherResponse, location: CLLocationCoordinate2D?)  // weatherData: WeatherResponse object
}
