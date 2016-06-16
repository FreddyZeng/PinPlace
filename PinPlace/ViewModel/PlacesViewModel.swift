//
//  PlacesViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/7/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCoreData

class PlacesViewModel {
    
    var places = Variable<[Place]>([Place]())
    
    init() {
        places.value.appendContentsOf(PlacesDataController.sharedInstance.fetchPlaces())
    }
    
    func appendPlaceWithCoordinate(coordinate: CLLocationCoordinate2D) {
        guard let newPlace = Place(coordinate: coordinate) else { return }
        places.value.append(newPlace)
        PlacesDataController.sharedInstance.saveChanges()
    }
}