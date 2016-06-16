//
//  PlaceDetailsViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/14/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import RxSwift

class PlaceDetailsViewModel {
    
    //MARK: - Properties
    
    var place: Place?
    let nearbyVenues =  Variable<[FoursquareVenue]>([FoursquareVenue]())
    let foursquareWebService = FoursquareWebService()
    let disposeBag = DisposeBag()
    
    //MARK: - Methods
    
    func fetchNearbyPlaces(completion: (() -> Void)?) {
        if let place = place {
            foursquareWebService.fetchNearbyFoursqareVenues(forPlace: place).subscribeNext {[unowned self] venuesArray  in
                completion?()
                self.nearbyVenues.value = venuesArray
                }.addDisposableTo(disposeBag)
        }
    }
    
    func savePlaceTitle () {
        PlacesDataController.sharedInstance.saveChanges()
    }
}