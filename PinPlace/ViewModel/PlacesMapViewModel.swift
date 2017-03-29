//
//  PlacesMapViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/7/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift

class PlacesMapViewModel: PlacesViewModel {
    
    var selectedTargetPlace: Place?
    var routeDrawer = RouteDrawer()
    fileprivate let locationManager = CLLocationManager()

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
    
    func buildRoute(_ completion: @escaping ((String?) -> Void)) {
        routeDrawer.targetPlace = selectedTargetPlace
        do {
            try routeDrawer.showRouteToTargetPlace() { error in
                completion(error?.localizedDescription)
            }
        } catch RouteDrawerError.destinationCoordiateMissed {
            completion("Destination coordiate missed.")
        } catch RouteDrawerError.routeCalculationFailed {
            completion("Route calculation failed.")
        } catch RouteDrawerError.targetPlaceIsNotProvided {
            completion("Target place isn't provided.")
        } catch RouteDrawerError.userLocationIsDisabled {
            completion("User location is disabled")
        } catch {
            completion("Unknown error.")
        }
        
    }
}
