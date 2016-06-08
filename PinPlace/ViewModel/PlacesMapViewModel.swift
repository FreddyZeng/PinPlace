//
//  PlacesMapViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/7/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import CoreLocation

class PlacesMapViewModel {
    
    var places = Array<Place>()
    
    init() {
        places = PlacesDataController.sharedInstance.fetchPlaces()
    }
    
    func insertPlaceWithCoordinate(coordinate: CLLocationCoordinate2D) {
        guard let newPlace = Place(coordinate: coordinate) else { return }
        places.append(newPlace)
        PlacesDataController.sharedInstance.saveChanges()
    }
}