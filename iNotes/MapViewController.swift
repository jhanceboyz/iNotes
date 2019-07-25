//
//  MapViewController.swift
//  iNoteshttp://cdn.similarphotocleaner.com/spc/offers/dod/Black_friday_spc.gif
//
//  Created by Jaspreet Singh on 2018-11-25.
//  Copyright © 2018 Kashyap. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var coordinate = CLLocationCoordinate2D()
    var managedObject: NSManagedObject = NSManagedObject()
    var lat: CLLocationDegrees = 43.773531
    var long: CLLocationDegrees = -79.335935

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        super.viewDidLoad()
        self.title = "Note Location"
        self.mapView.showsUserLocation = true
        self.showNoteLocation()
    }
    
    func showNoteLocation() {
        //if let lat = managedObject.value(forKey: "latitudes") as? Double, let lng = managedObject.value(forKey: "longitudes") as? Double {
            coordinate.latitude = lat
            coordinate.longitude = long
            let initialLocation = CLLocation(latitude: lat, longitude: long)
            centerMapOnLocation(location: initialLocation)
        }
    
    func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
        let artwork = Annotation(title: "Note location",coordinate:CLLocationCoordinate2D(latitude:self.coordinate.latitude, longitude: self.coordinate.longitude))
        
        mapView.addAnnotation(artwork)
    }
    
    
    
//    @available(iOS 11.0, *)
//    func mapView(aMapView: MKMapView!,viewForAnnotation annotation: MKAnnotation!)-> MKAnnotationView! {
//        // 2
//        guard let annotation = annotation as? Annotation else { return nil }
//        // 3
//        let identifier = "marker"
//        var view: MKMarkerAnnotationView
//        // 4
//        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//            as? MKMarkerAnnotationView {
//            dequeuedView.annotation = annotation
//            view = dequeuedView
//        } else {
//            // 5
//            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            view.canShowCallout = true
//            view.calloutOffset = CGPoint(x: -5, y: 5)
//            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        }
//        return view
//    }
    @available(iOS 11.0, *)
    func mapView(aMapView: MKMapView!,viewForAnnotation annotation: MKAnnotation!)-> MKAnnotationView! {
        // 2
        guard let annotation = annotation as? Annotation else { return nil }
        // 3
        let identifier = "marker"
        var view: MKMarkerAnnotationView
        // 4
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            // 5
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
}
