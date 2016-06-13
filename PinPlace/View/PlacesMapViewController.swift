//
//  PlacesMapViewController.swift
//  PinPlace
//
//  Created by Artem on 6/7/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit
import MapKit
import RxSwift
import RxCocoa
import RxMKMapView

class PlacesMapViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var mapView: MKMapView!
    
    let disposeBag = DisposeBag()
    let viewModel = PlacesViewModel()
    let locationManager = CLLocationManager()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapForUpdatingUserLocation()
        
        mapView.addAnnotations(viewModel.places)
        
        longPressGestureRecognizer.rx_event.subscribeNext { [unowned self]longPressGesture in
            if longPressGesture.state != .Ended {
                return
            }
            let touchPoint = longPressGesture.locationInView(self.mapView)
            let touchLocationCoordinate2D = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            self.viewModel.appendPlaceWithCoordinate(touchLocationCoordinate2D)
            self.mapView.addAnnotation(self.viewModel.places.last!)
            
            }.addDisposableTo(disposeBag)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ShowPopover.rawValue {
            guard let destVC = segue.destinationViewController.popoverPresentationController else {
                return
            }
            destVC.delegate = self
        }
    }
    
    // MARK: - Private
    
    private func setupMapForUpdatingUserLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        mapView.showsPointsOfInterest = true
    }
}

// MARK: - CLLocationManagerDelegate

extension PlacesMapViewController: CLLocationManagerDelegate {
    
}

// MARK: - MKMapViewDelegate

extension PlacesMapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return mapView.viewForAnnotation(annotation)
        }
        let placeAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PlaceAnnotationViewIdentifier")
        placeAnnotationView.canShowCallout = true
        placeAnnotationView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        return placeAnnotationView
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension PlacesMapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
}
