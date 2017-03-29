//
//  RouteDrawer.swift
//  PinPlace
//
//  Created by Artem on 6/17/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import MapKit

enum RouteDrawerError: Error {
    case targetPlaceIsNotProvided
    case destinationCoordiateMissed
    case userLocationIsDisabled
    case routeCalculationFailed
}

class RouteDrawer {
    
    var targetPlace: Place?
    var mapView: MKMapView?
    
    fileprivate var currentRouteDirections: MKDirections?
    
    // MARK: - Public
    
    func showRouteToTargetPlace(_ completion: @escaping ((NSError?) -> Void)) throws {
        do {
            try fetchDirectionsToTargetPlace() { error in
                completion(error)
            }
        }
    }
    
    func dismissCurrentRoute() {
        if let directions = currentRouteDirections {
            if directions.isCalculating {
                directions.cancel()
            }
        }
        mapView!.removeAnnotations(mapView!.annotations)
        mapView!.removeOverlays(mapView!.overlays)
        currentRouteDirections = nil
    }
    
    // MARK: - Private
    
    fileprivate func fetchDirectionsToTargetPlace(_ completion: @escaping ((NSError?) -> Void)) throws {
        guard let place = targetPlace else {
            throw RouteDrawerError.targetPlaceIsNotProvided
        }
        
        guard let destinationCoordinate = place.location?.coordinate else {
            throw RouteDrawerError.destinationCoordiateMissed
        }
        
        guard mapView!.userLocation.location != nil else {
            throw RouteDrawerError.userLocationIsDisabled
        }
        
        dismissCurrentRoute()
        mapView!.addAnnotation(place)
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem.forCurrentLocation()
        directionsRequest.requestsAlternateRoutes = false
        
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        directionsRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionsRequest.transportType = .any
        
        currentRouteDirections = MKDirections(request: directionsRequest)
        
        currentRouteDirections?.calculate() { directionsResponse, error in
            DispatchQueue.main.async {
                if error != nil && directionsResponse == nil {
                    completion(error as NSError?)
                } else {
                    if let directions = directionsResponse {
                        self.drawRoute(directions)
                    }
                    completion(nil)
                }
            }
        }
    }
    
    fileprivate func drawRoute(_ mkDirectionsResponse: MKDirectionsResponse) {
        var totalRect = MKMapRectNull
        for route in mkDirectionsResponse.routes {
            mapView!.add(route.polyline, level: .aboveRoads)
            let polygon = MKPolygon(points: route.polyline.points(), count: route.polyline.pointCount)
            let routeRect = polygon.boundingMapRect
            totalRect = MKMapRectUnion(totalRect, routeRect)
        }
        mapView!.setVisibleMapRect(totalRect, edgePadding: UIEdgeInsetsMake(30, 30, 30, 30), animated: true)
    }
}
