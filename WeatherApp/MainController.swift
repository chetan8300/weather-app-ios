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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupLocation()
        setupMap()
    }
    
    private func setupLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
    }

    private func addCurrentLocationAnnotation(location: CLLocation) {
        let annotation = MyAnnotation(coordinate: location.coordinate, title: "Temperature 34°F", subtitle: "My Location")
        
        mapView.addAnnotation(annotation)
    }

    private func setupMap() {
        // set delegate
        mapView.delegate = self
        
        // enable showing user location on map
        // mapView.showsUserLocation = true
        
        guard let location = locationManager.location else {
            return
        }
        
        addCurrentLocationAnnotation(location: location)

        let radiusInMeters: CLLocationDistance = 1000
        
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: radiusInMeters, longitudinalMeters: radiusInMeters)
        mapView.setRegion(region, animated: true)
        
        // camera boundries
        // let cameraBoundry = MKMapView.CameraBoundary(coordinateRegion: region)
        // mapView.setCameraBoundary(cameraBoundry, animated: true)
        
        // control zooming
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 100000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
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
            
            // add a button to right side of callout
            let button = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = button
            
            // add an image to left side of callout
            let image = UIImage(systemName: "graduationcap.circle.fill")
            view.leftCalloutAccessoryView = UIImageView(image: image)
            
            // change color of pin
            view.markerTintColor = .systemBlue
            
            // change color of accessories
            view.tintColor = .systemRed
            
            if let annotation = annotation as? MyAnnotation {
                // change marker glyph
                view.glyphText = annotation.glyphText
            }
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("Tapped \(control.tag)")
        
        guard let coordinates = view.annotation?.coordinate else {
            return
        }
        
        let launchOptions = [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ]
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinates))
        mapItem.openInMaps(launchOptions: launchOptions)
        
    }
}

extension MainController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let _ = locations.last {
            if (!currentLocationAdded) {
                currentLocationAdded = true
                setupMap()
            }
            
//            let latitude = location.coordinate.latitude
//            let longitude = location.coordinate.longitude
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
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.glyphText = glyphText
        
        super.init()
    }
}
