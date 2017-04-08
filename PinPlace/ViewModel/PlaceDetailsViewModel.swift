//
//  PlaceDetailsViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/14/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import RxSwift

final class PlaceDetailsViewModel {

    // MARK: - Properties

    var place: Place?
    let nearbyVenues =  Variable<[FoursquareVenue]>([FoursquareVenue]())
    fileprivate let foursquareWebService = FoursquareWebService()
    fileprivate let disposeBag = DisposeBag()

    // MARK: - Methods

    func fetchNearbyPlaces(_ completion: (() -> Void)?) {
        if let place = place {
            foursquareWebService.fetchNearbyFoursqareVenues(forPlace: place).bindNext {[unowned self] venuesArray  in
                completion?()
                self.nearbyVenues.value = venuesArray
            }.addDisposableTo(disposeBag)
        }
    }

    func savePlaceTitle () {
        PlacesDataController.sharedInstance.saveChanges()
    }

    func deletePlace() {
        guard let place = place else { return }
        PlacesDataController.sharedInstance.deletePlace(place)
    }
}
