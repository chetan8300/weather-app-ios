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
            let addLocationController = segue.destination as! AddLocationController
            addLocationController.delegate = self
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
        
        loadWeather(search: "\(location.coordinate.latitude),\(location.coordinate.longitude)", callback: getWeatherData, location: location.coordinate)

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
    
    func getWeatherData(weatherData: WeatherResponse, location: CLLocationCoordinate2D? = nil) -> Void {
        locationData.append(weatherData)
        if let location = location {
            addLocationAnnotation(location: location, weatherData: weatherData)
        } else {
            let newLocation = CLLocationCoordinate2D(latitude: weatherData.location.lat, longitude: weatherData.location.lon)
            addLocationAnnotation(location: newLocation, weatherData: weatherData)
        }
    }
    
    func updateLocationsArray(weatherData: WeatherResponse) {
        print("weatherData", weatherData)
        locationData.append(weatherData)
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
                view.markerTintColor = annotation.markerTintColor

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
    var markerTintColor: UIColor
    
    init(coordinate: CLLocationCoordinate2D, weatherData: WeatherResponse) {
        let tempC = "\(Int(weatherData.current.temp_c.rounded(.toNearestOrEven)))°C"
        let feelLikeC = "\(Int(weatherData.current.feelslike_c.rounded(.toNearestOrEven)))°C"
        let weatherCondition = weatherData.current.condition.text
        let weatherCode = weatherData.current.condition.code
        let weatherImage = weatherIconDictionary[weatherCode]?.generateNightImage()
        
        if (weatherData.current.is_day == 0) {
            self.symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, .systemBlue])
        } else {
            self.symbolConfiguration = UIImage.SymbolConfiguration(paletteColors: [.systemBlue, UIColor(red: 1.00, green: 0.65, blue: 0.00, alpha: 1.00)])
        }
        
        self.markerTintColor = UIColor.systemPurple
        if (weatherData.current.temp_c > 30) {
            // Very hot
            self.markerTintColor = UIColor.systemRed
        } else if (weatherData.current.temp_c > 24 && weatherData.current.temp_c <= 30) {
            // Hot
            self.markerTintColor = UIColor.systemOrange
        } else if (weatherData.current.temp_c > 16 && weatherData.current.temp_c <= 24) {
            // Warm
            self.markerTintColor = UIColor.systemOrange
        } else if (weatherData.current.temp_c > 11 && weatherData.current.temp_c <= 16) {
            // Cool
            self.markerTintColor = UIColor.systemOrange
        } else if (weatherData.current.temp_c >= 0 && weatherData.current.temp_c <= 11) {
            // Cold
            self.markerTintColor = UIColor.systemOrange
        }
        
        self.coordinate = coordinate
        self.title = weatherCondition
        self.subtitle = "Temp: \(tempC), Feels like: \(feelLikeC)"
        self.glyphText = tempC
        self.weatherImage = weatherImage
        
        super.init()
    }
}

protocol ReceiveWeatherData {
  func updateLocationsArray(weatherData: WeatherResponse)  // weatherData: WeatherResponse object
}
