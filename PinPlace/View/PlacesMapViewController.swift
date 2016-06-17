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
 -Searhcable list of bookmarks
 -Tableview placeholder
 */
class PlacesMapViewController: UIViewController {
    
    private enum AppMode {
        case Default, Routing
    }
    
    // MARK: - Properties
    
    @IBOutlet weak var routeBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var longPressGestureRecognizer: UILongPressGestureRecognizer!
    @IBOutlet weak var mapView: MKMapView!
    
    let disposeBag = DisposeBag()
    let viewModel = PlacesMapViewModel()
    let locationManager = CLLocationManager()
    private var appMode: AppMode = .Default
    
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: NotificationName.CenterPlace.rawValue,
                                                            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: NotificationName.BuildRoute.rawValue,
                                                            object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
                                                            name: NotificationName.PlaceDeleted.rawValue,
                                                            object: nil)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(centerPlaceNotification),
                                                         name: NotificationName.CenterPlace.rawValue,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(buildRoute),
                                                         name: NotificationName.BuildRoute.rawValue,
                                                         object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(placeDeletedNotification),
                                                         name: NotificationName.PlaceDeleted.rawValue,
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
        
        mapView.rx_didUpdateUserLocation.subscribeNext { [unowned self] _ in
            guard let userLocation = self.mapView.userLocation.location else { return }
            let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            let locationCoordinate = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
                                                           longitude: userLocation.coordinate.longitude)
            
            let region = MKCoordinateRegion(center: locationCoordinate, span: coordinateSpan)
            self.mapView.setRegion(region, animated: true)
        }.addDisposableTo(disposeBag)
        
        routeBarButtonItem.rx_tap.subscribeNext { [unowned self] in
            switch self.appMode {
            case .Default:
                self.performSegueWithIdentifier(SegueIdentifier.ShowPopover.rawValue, sender: self)
            case .Routing:
                self.switchAppToNormalMode()
            }
        }.addDisposableTo(disposeBag)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if appMode == .Default {
            viewModel.fetchPlaces()
            mapView.addAnnotations(viewModel.places.value)
        }
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
        appMode = .Routing
        routeBarButtonItem.title = "Clear Route"
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
    
    func placeDeletedNotification(notification: NSNotification) {
        if let notificationObject = notification.object as? Place {
            if notificationObject == self.viewModel.selectedTargetPlace! && appMode == .Routing {
                self.switchAppToNormalMode()
            }
        }
    }
    
    func centerPlaceNotification(notification: NSNotification) {
        if let notificationObject = notification.object as? Place {
            if self.appMode != .Default {
                switchAppToNormalMode()
            }
            guard let location = notificationObject.location as? CLLocation else {return}
            let centerCoordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            var region = self.mapView.region
            region.center = centerCoordinate
            self.mapView.setRegion(region, animated: true)
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
    
    private func switchAppToNormalMode() {
        self.appMode = .Default
        self.routeBarButtonItem.title = "Route"
        self.viewModel.routeDrawer.dismissCurrentRoute()
        viewModel.fetchPlaces()
        mapView.addAnnotations(viewModel.places.value)
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

