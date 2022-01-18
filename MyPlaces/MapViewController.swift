//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Гришечко on 12.01.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var place = Place()
    var annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 10000.00
    var incomeSegueIdentifier = ""
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMapView()
        checkLocationServices()

    }
    
    @IBAction func centerViewOnUserLocation() {
        showUserLocation()
    }
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    @IBAction func doneButtonPressed() {
    }
    
    private func setupMapView() {
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
        }
    }
    
    private func setupPlacemark () {
        guard let location = place.location else { return }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) {(placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else {return}
            annotation.coordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServices() {
        if CLLocationManager.significantLocationChangeMonitoringAvailable() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled", message: "To enable it go: Settings -> Privacy -> Location Services and turn on")
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAdress" {showUserLocation()}
            break
        case .authorizedAlways:
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location is not available", message: "To enable it go: Settings -> Privacy -> Location Services and turn on")
            }
            break
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled", message: "To enable it go: Settings -> Privacy -> Location Services and turn on")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        @unknown default:
            print("New case")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        
        if let imageData = place.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData)
            annotationView?.leftCalloutAccessoryView = imageView
        }
        
        return annotationView
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
//    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//        checkLocationAuthorization()
//    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
    
}
