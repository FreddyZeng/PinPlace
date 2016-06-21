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
    
    func appendPlaceWithCoordinate(coordinate: CLLocationCoordinate2D) {
        guard let newPlace = Place(coordinate: coordinate) else { return }
        places.value.append(newPlace)
        PlacesDataController.sharedInstance.saveChanges()
    }
    
    func buildRoute(completion: ((String?) -> Void)) {
        routeDrawer.targetPlace = selectedTargetPlace
        do {
            try routeDrawer.showRouteToTargetPlace() { error in
                completion(error?.localizedDescription)
            }
        } catch RouteDrawerError.DestinationCoordiateMissed {
            completion("Destination coordiate missed.")
        } catch RouteDrawerError.RouteCalculationFailed {
            completion("Route calculation failed.")
        } catch RouteDrawerError.TargetPlaceIsNotProvided {
            completion("Target place isn't provided.")
        } catch RouteDrawerError.UserLocationIsDisabled {
            completion("User location is disabled")
        } catch {
            completion("Unknown error.")
        }
        
    }
}