//
//  PlacesMapViewController.swift
//  PinPlace
//
//  Created by Artem on 6/7/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import UIKit
import MapKit
import PKHUD
import RxSwift
import RxCocoa
import RxMKMapView

/* TODO:
 -Add Route/Clear Route Mode
 -Update user location
 -Searhcable list of bookmarks
 -Tableview placeholder
 -finish details screen functionality
 */
class PlacesMapViewController: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var mapView: MKMapView!
    
    let disposeBag = DisposeBag()
    let viewModel = PlacesMapViewModel()
    let locationManager = CLLocationManager()
    
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: NotificationName.BuildRoute.rawValue,
                                                            object: nil)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(buildRoute),
                                                         name: NotificationName.BuildRoute.rawValue,
                                                         object: nil)
        
        setupMapForUpdatingUserLocation()
        
        longPressGestureRecognizer.rx_event.subscribeNext { [unowned self] longPressGesture in
            if longPressGesture.state != .Ended {
                return
            }
            let touchPoint = longPressGesture.locationInView(self.mapView)
            let touchLocationCoordinate2D = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            self.viewModel.appendPlaceWithCoordinate(touchLocationCoordinate2D)
            self.mapView.addAnnotation(self.viewModel.places.value.last!)
            
            }.addDisposableTo(disposeBag)
        
        
        mapView.rx_annotationViewCalloutAccessoryControlTapped.subscribeNext { [unowned self] view, control in
            if view.annotation is Place {
                self.mapView.deselectAnnotation(view.annotation, animated: false)
                self.performSegueWithIdentifier(SegueIdentifier.ShowPlaceDetails.rawValue, sender: view.annotation)
            }
            }.addDisposableTo(disposeBag)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPlaces()
        mapView.addAnnotations(viewModel.places.value)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == SegueIdentifier.ShowPopover.rawValue {
            guard let destVC = segue.destinationViewController as? PlacesTableViewController,
                let destPopoverVC = destVC.popoverPresentationController else {
                    return
            }
            destPopoverVC.delegate = self
        } else if segue.identifier == SegueIdentifier.ShowPlaceDetails.rawValue {
            guard let place = sender as? Place,
                let destinationViewController = segue.destinationViewController as? PlaceDetailsViewController
                else { return }
            destinationViewController.viewModel = PlaceDetailsViewModel()
            destinationViewController.viewModel?.place = place
        }
    }
    
    // MARK: - NSNotificationCenter Handlers
    
    func buildRoute() {
        viewModel.routeDrawer.mapView = self.mapView
        HUD.show(.Progress)
        viewModel.buildRoute() { errorMessage in
            HUD.flash(.Success, delay: 1.0)
            if errorMessage != nil {
                let alertController = UIAlertController(title: "Error", message: errorMessage!, preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "OK", style: .Cancel) { (action) in
                }
                alertController.addAction(cancelAction)
                dispatch_async(dispatch_get_main_queue()) {
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
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
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor(red:0.29, green:0.53, blue:0.91, alpha:1.0)
        polylineRenderer.lineWidth = 5.0
        return polylineRenderer
    }
}

// MARK: - UIPopoverPresentationControllerDelegate

extension PlacesMapViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .None
    }
}

