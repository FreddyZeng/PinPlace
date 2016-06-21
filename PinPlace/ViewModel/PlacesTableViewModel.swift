//
//  PlacesTableViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/21/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation

class PlacesTableViewModel: PlacesViewModel {
    
    func deletePlace(place: Place) {
        PlacesDataController.sharedInstance.deletePlace(place)
        self.places.value.removeAtIndex(self.places.value.indexOf(place)!)
    }
    
    func findPlacesByName(searchQuery: String) {
        if searchQuery.characters.count > 0 {
            self.places.value = self.places.value.filter { place in
                return place.title!.containsString(searchQuery)
            }
        } else {
            self.fetchPlaces()
        }
    }
}