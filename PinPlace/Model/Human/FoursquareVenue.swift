//
//  FoursquareVenue.swift
//  PinPlace
//
//  Created by Artem on 6/15/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import JASON

public enum FoursquareVenueAttributes: String {
    case name
}

struct FoursquareVenue {

    let name: String

    init(_ json: JSON) {
        name = json[.name]
    }
}

extension JSONKeys {
    static let name = JSONKey<String>(FoursquareVenueAttributes.name.rawValue)
}
