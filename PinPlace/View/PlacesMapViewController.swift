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
    let viewModel = PlacesMapViewModel()
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        longPressGestureRecognizer.rx_event.subscribeNext { [unowned self]longPressGesture in
            if longPressGesture.state != .Ended {
                return
            }
            let touchPoint = longPressGesture.locationInView(self.mapView)
            let touchLocationCoordinate2D = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)
            self.viewModel.insertPlaceWithCoordinate(touchLocationCoordinate2D)
            self.mapView.addAnnotation(self.viewModel.places.last!)
            
        }.addDisposableTo(disposeBag)
        
    }
    
    // MARK: - Private
}
