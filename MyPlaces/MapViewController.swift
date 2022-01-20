//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Дмитрий Гришечко on 12.01.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {

    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    var annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 5000.00
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    var previousLocation : CLLocation? {
        didSet {
            startTrackingUserLocation()
        }
    }
    var directionsArray: [MKDirections] = []
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        setupMapView()
        checkLocationServices()
        addressLabel.text = ""
    }
    
    @IBAction func centerViewOnUserLocation() {
        showUserLocation()
    }
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    private func setupMapView() {
        goButton.isHidden = true
        if incomeSegueIdentifier == "showPlace" {
            setupPlacemark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    private func resetMapView(withNew directions: MKDirections) {
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
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
            self.placeCoordinate = placemarkLocation.coordinate
            
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
            if incomeSegueIdentifier == "getAddress" {showUserLocation()}
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
    
    private func getDirections () {
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        locationManager.startUpdatingLocation()
        previousLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination Not Found ")
            return
        }
        
        
        let directions = MKDirections(request: request)
        resetMapView(withNew: directions)
        
        directions.calculate { (response, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else {
                self.showAlert(title: "Error", message: "Directions is not available")
                return
            }
            
            for route in response.routes {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                let distance = String(format: "%1f", route.distance / 1000)
                let timeInterval = String(format: "%1f", route.expectedTravelTime / 60)
                //set new label (2)
                print("Расстояние до места: \(distance) км.")
                print("Время пути: \(timeInterval) мин.")
            }
            
        }
        
    }
    
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getCenterLocation (for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func startTrackingUserLocation() {
        
        guard let previousLocation = previousLocation else {
            return
        }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: previousLocation) > 50 else {return}
        self.previousLocation = center
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [self] in
            self.showUserLocation()
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
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = getCenterLocation(for: mapView)
        let geocoder = CLGeocoder()
        if incomeSegueIdentifier == "showPlace" && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showUserLocation()
            }
        }
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else {return}
            let placemark = placemarks.first
            let streetName = placemark?.thoroughfare
            let buildingNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async {
                if streetName != nil && buildingNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildingNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
            
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        return renderer
    }
    
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
    
}
