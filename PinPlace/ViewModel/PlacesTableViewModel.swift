//
//  PlacesTableViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/21/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation

class PlacesTableViewModel: PlacesViewModel {
    
    func deletePlace(_ place: Place) {
        PlacesDataController.sharedInstance.deletePlace(place)
        self.places.value.remove(at: self.places.value.index(of: place)!)
    }
    
    func findPlacesByName(_ searchQuery: String) {
        if searchQuery.characters.count > 0 {
            self.places.value = self.places.value.filter { place in
                return place.title!.contains(searchQuery)
            }
        } else {
            self.fetchPlaces()
        }
    }
}
