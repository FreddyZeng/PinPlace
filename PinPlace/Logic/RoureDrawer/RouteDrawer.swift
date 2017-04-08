//
//  RouteDrawer.swift
//  PinPlace
//
//  Created by Artem on 6/17/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

enum RouteCalculatorError: Error {
    case destinationCoordinateMissed
    case userLocationCoordinateMissed
}

final class RouteCalculator {

    //MARK: - Properties

    private var currentRouteDirections: MKDirections?
    
    //MARK: - Methods
    
    func calculateRoute(from startCoordinate: CLLocationCoordinate2D?,
                        to finishCoordinate: CLLocationCoordinate2D?,
                        completion: @escaping ((MKDirectionsResponse?, NSError?) -> Void)) throws {

        guard let finishCoordinate = finishCoordinate else {
            throw RouteCalculatorError.destinationCoordinateMissed
        }

        guard let _ = startCoordinate else {
            throw RouteCalculatorError.userLocationCoordinateMissed
        }

        dismissCurrentRoute()

        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem.forCurrentLocation()
        directionsRequest.requestsAlternateRoutes = false

        let destinationPlaceMark = MKPlacemark(coordinate: finishCoordinate, addressDictionary: nil)

        directionsRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionsRequest.transportType = .any

        currentRouteDirections = MKDirections(request: directionsRequest)

        currentRouteDirections?.calculate() { directionsResponse, error in
            DispatchQueue.main.async {
                if error != nil && directionsResponse == nil {
                    completion(nil, error as NSError?)
                } else {
                    if let directions = directionsResponse {
                        completion(directions, nil)
                    }
                }
            }
        }
    }

    func dismissCurrentRoute() {
        if let directions = currentRouteDirections {
            if directions.isCalculating {
                directions.cancel()
            }
        }
        currentRouteDirections = nil
    }
}
