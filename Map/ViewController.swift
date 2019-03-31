//
//  ViewController.swift
//  Map
//
//  Created by Mark Meretzky on 3/27/19.
//  Copyright © 2019 New York University School of Professional Studies. All rights reserved.
//

import UIKit;
import MapKit;

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    let locationManager: CLLocationManager = CLLocationManager(); //find device's latitude and longitude
    let geocoder: CLGeocoder = CLGeocoder();
    
    @IBOutlet weak var mapView: MKMapView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Do any additional setup after loading the view.
        locationManager.requestWhenInUseAuthorization(); //Allow "Map" to access your location?
        guard CLLocationManager.locationServicesEnabled() else { //Settings -> Privacy -> Location
            fatalError("location sevices not enabled");
        }

        locationManager.desiredAccuracy = kCLLocationAccuracyBest; //default; uses power
        locationManager.delegate = self;
        mapView.delegate = self;
        locationManager.startUpdatingLocation();
    }

    // MARK: - Protocol CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation();    //save electricity
        
        //last location in the array of locations
        guard let location: CLLocation = locations.last else {
            fatalError("locations is an empty array");
        }

        print("""
            locationManager(_:didUpdateLocations:), locations.count = \(locations.count)
            latitude \(location.coordinate.latitude)°
            longitude \(location.coordinate.longitude)°
            altitude \(location.altitude) meters
            horizontal accuracy \(location.horizontalAccuracy) meters

            """);
        
        /*
         Create a region and put it into the MKMapView.
         2nd argument is height of the region (north-south),
         3rd argument is width of the region (east-west).
         */
        let meters: CLLocationDistance = 100;    //east-west
        
        mapView.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: meters * CLLocationDistance(mapView.frame.height / mapView.frame.width),
            longitudinalMeters: meters);
        
        geocoder.reverseGeocodeLocation(location) {(placemarks: [CLPlacemark]?, error: Error?) in
            guard let error: Error = error else {
                fatalError("geocoder error: \(error)");
            }
            
            guard let placemarks: [CLPlacemark] = placemarks else {
                fatalError("placemarks is nil");
                
            }
            guard !placemarks.isEmpty else {
                fatalError("placemarks is an empty array");
            }

            for placemark in placemarks {    //placemark is a CLPlacemark
                print("""
                    placemark.subThoroughfare = \(placemark.subThoroughfare!)
                    placemark.thoroughfare = \(placemark.thoroughfare!)
                    placemark.postalCode = \(placemark.postalCode!)
                    """);

                let c: CLLocationCoordinate2D = location.coordinate;
                let ns: String = c.latitude  >= 0 ? "N" : "S";
                let ew: String = c.longitude >= 0 ? "E" : "W";
                
                let pointAnnotation: MKPointAnnotation = MKPointAnnotation();
                pointAnnotation.title = placemark.name;
                pointAnnotation.subtitle = "\(abs(c.latitude))°\(ns) \(abs(c.longitude))°\(ew)";
                pointAnnotation.coordinate = c;
                self.mapView.addAnnotation(pointAnnotation);
            }
        }
    }
    
    // MARK: - Protocol MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let pointAnnotation: MKPointAnnotation = annotation as? MKPointAnnotation else {
            fatalError("expected MKPointAnnotation instead of \(type(of: annotation))");
        }
        
        let reuseIdentifier: String = "Annotation";
        
        //Try to reuse an existing MKPinAnnotationView.
        if let pinAnnotationView: MKPinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? MKPinAnnotationView {
            pinAnnotationView.annotation = annotation;
            return pinAnnotationView;
        }
        
        //If necessary, create a new MKPinAnnotationView.
        let pinAnnotationView: MKPinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier);
        pinAnnotationView.canShowCallout = true;   //can display info bubble
        //pinAnnotationView.pinTintColor = MKPinAnnotationView.greenPinColor();   //default is red
        return pinAnnotationView;
    }
    
}
