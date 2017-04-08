//
//  PlacesMapViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/7/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import RxSwift

final class PlacesMapViewModel: PlacesViewModel {

    var userLocationCoordinate2D: CLLocationCoordinate2D?
    var selectedTargetPlace: Place?
    let routeCalculator = RouteCalculator()
    fileprivate let locationManager = CLLocationManager()
    fileprivate(set) var currentRouteMKDirectionsResponse = Variable<MKDirectionsResponse?>(MKDirectionsResponse())

    func setupLocationManagerWithDelegate(_ locationManagerDelegate: CLLocationManagerDelegate) {
        locationManager.delegate = locationManagerDelegate
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func appendPlaceWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        guard let newPlace = Place(coordinate: coordinate) else { return }
        places.value.append(newPlace)
        PlacesDataController.sharedInstance.saveChanges()
    }
    
    func buildRoute(onErrorCompletion: @escaping ((String?) -> Void)) {
        do {
            currentRouteMKDirectionsResponse.value = nil
            try routeCalculator.calculateRoute(from: userLocationCoordinate2D,
                                               to: selectedTargetPlace?.location?.coordinate) { [weak self] mkDirectionsResponse, error in
                if let calculatedDirections = mkDirectionsResponse {
                    self?.currentRouteMKDirectionsResponse.value = calculatedDirections
                    onErrorCompletion(nil)
                } else {
                    onErrorCompletion(error?.localizedDescription)
                }
            }
        } catch RouteCalculatorError.destinationCoordinateMissed {
            onErrorCompletion("Destination coordinate missed.")
        } catch RouteCalculatorError.userLocationCoordinateMissed {
            onErrorCompletion("User location is disabled")
        } catch {
            onErrorCompletion("Unknown error.")
        }
    }

    func clearRoute() {
        currentRouteMKDirectionsResponse.value = nil
        routeCalculator.dismissCurrentRoute()
    }
}
