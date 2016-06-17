//
//  RouteDrawer.swift
//  PinPlace
//
//  Created by Artem on 6/17/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import MapKit

private enum RouteDrawerError: ErrorType {
    case TargetPlaceIsNotProvided
    case DestinationCoordiateMissed
    case UserLocationIsDisabled
    case RouteCalculationFailed
}

class RouteDrawer {
    
    var targetPlace: Place?
    let mapView: MKMapView
    
    private var currentRouteDirections: MKDirections?
    
    init(mapView: MKMapView, targetPlace: Place? = nil) {
        self.mapView = mapView
        self.targetPlace = targetPlace
    }
    
    // MARK: - Public
    
    func showRouteToTargetPlace(completion: ((NSError?) -> Void)) throws {
        do {
            try fetchDirectionsToTargetPlace() { error in
                completion(error)
            }
        }
    }
    
    func dismissCurrentRoute() {
        guard let directions = currentRouteDirections else {return}
        if directions.calculating {
            directions.cancel()
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        currentRouteDirections = nil
        targetPlace = nil
    }
    
    // MARK: - Private
    
    private func fetchDirectionsToTargetPlace(completion: ((NSError?) -> Void)) throws {
        guard let place = targetPlace else {
            throw RouteDrawerError.TargetPlaceIsNotProvided
        }
        
        guard let destinationCoordinate = place.location?.coordinate else {
            throw RouteDrawerError.DestinationCoordiateMissed
        }
        
        guard mapView.userLocation.location != nil else {
            throw RouteDrawerError.UserLocationIsDisabled
        }
        
        dismissCurrentRoute()
        mapView.addAnnotation(place)
        
        let directionsRequest = MKDirectionsRequest()
        directionsRequest.source = MKMapItem.mapItemForCurrentLocation()
        directionsRequest.requestsAlternateRoutes = false
        
        let destinationPlaceMark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
        
        directionsRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionsRequest.transportType = .Any
        
        currentRouteDirections = MKDirections(request: directionsRequest)
        
        currentRouteDirections?.calculateDirectionsWithCompletionHandler() { [unowned self] directionsResponse, error in
            dispatch_async(dispatch_get_main_queue()) {
                if error != nil && directionsResponse == nil {
                    completion(error)
                } else {
                    if let directions = directionsResponse {
                        self.drawRoute(directions)
                    }
                    completion(nil)
                }
            }
        }
    }
    
    private func drawRoute(mkDirectionsResponse: MKDirectionsResponse) {
        var totalRect = MKMapRectNull
        for route in mkDirectionsResponse.routes {
            mapView.addOverlay(route.polyline, level: .AboveRoads)
            let polygon = MKPolygon(points: route.polyline.points(), count: route.polyline.pointCount)
            let routeRect = polygon.boundingMapRect
            totalRect = MKMapRectUnion(totalRect, routeRect)
        }
        mapView.setVisibleMapRect(totalRect, edgePadding: UIEdgeInsetsMake(30, 30, 30, 30), animated: true)
    }
}
