//
//  ViewController.swift
//  Map
//
//  Created by Mark Meretzky on 3/27/19.
//  Copyright © 2019 New York University School of Professional Studies. All rights reserved.
//

import UIKit;
import MapKit;

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let locationManager: CLLocationManager = CLLocationManager(); //find device's latitude and longitude
    let geocoder: CLGeocoder = CLGeocoder();
    
    @IBOutlet weak var mapView: MKMapView!;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        // Do any additional setup after loading the view.
        mapView.delegate = self;

        locationManager.requestWhenInUseAuthorization();     //Allow "Map" to access your loc...?
        assert(CLLocationManager.locationServicesEnabled()); //Settings -> Privacy -> Location
        locationManager.desiredAccuracy = kCLLocationAccuracyBest; //default; uses power
        locationManager.delegate = self;
        locationManager.startUpdatingLocation();
    }

    // MARK: - Protocol CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation();    //save electricity
        
        //last location in the array of locations
        let location: CLLocation = locations.last! as CLLocation;
        print("update Lat \(location.coordinate.latitude)° Long \(location.coordinate.longitude)°");
        
        /*
         Create a region and put it into the MKMapView.
         2nd argument is height of the region (north-south),
         3rd argument is width of the region (east-west).
         */
        let meters: CLLocationDistance = 100;    //east-west
        
        mapView.region = MKCoordinateRegion(
            center: location.coordinate,
            latitudinalMeters: meters * CLLocationDistance(view.bounds.size.height / view.bounds.size.width),
            longitudinalMeters: meters);
        
        geocoder.reverseGeocodeLocation(location, completionHandler: {(placemarks: [CLPlacemark]?, error: Error?) in
            
            if error != nil {
                print("geocoder error: \(error!)");
                return;
            }
            
            guard let placemarks: [CLPlacemark] = placemarks else {
                fatalError("placemarks is nil");
                
            }
            guard !placemarks.isEmpty else {
                fatalError("placemarks is an empty array");
            }

            for placemark in placemarks {    //placemark is a CLPlacemark
                print("placemark.subThoroughfare = \(placemark.subThoroughfare!)");
                print("placemark.thoroughfare = \(placemark.thoroughfare!)");
                let c: CLLocationCoordinate2D = location.coordinate;
                let ns: String = c.latitude  >= 0 ? "N" : "S";
                let ew: String = c.longitude >= 0 ? "E" : "W";
                
                let pointAnnotation: MKPointAnnotation = MKPointAnnotation();
                pointAnnotation.title = placemark.name;
                pointAnnotation.subtitle = "\(abs(c.latitude))°\(ns) \(abs(c.longitude))°\(ew)";
                pointAnnotation.coordinate = c;
                self.mapView.addAnnotation(pointAnnotation);
            }
        });
    }
    
    // MARK: - Protocol MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else {
            return nil;
        }
        
        let identifier: String = "Annotation";
        
        //Try to reuse an MKAnnotationView.
        if let annotationView: MKAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            annotationView.annotation = annotation;
            return annotationView;
        }
        
        //If necessary, create a new MKAnnotationView.
        let annotationView: MKAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier);
        annotationView.canShowCallout = true;   //can display info bubble
        return annotationView;
    }
    
}
