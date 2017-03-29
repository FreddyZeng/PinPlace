//
//  PlacesViewModel.swift
//  PinPlace
//
//  Created by Artem on 6/17/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import RxSwift

class PlacesViewModel {

    fileprivate(set) var places = Variable<[Place]>([Place]())

    func fetchPlaces() {
        places.value.removeAll()
        places.value.append(contentsOf: PlacesDataController.sharedInstance.fetchPlaces())
    }
}
