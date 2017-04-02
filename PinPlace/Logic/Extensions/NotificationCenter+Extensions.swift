//
//  NotificationCenter+Extensions.swift
//  PinPlace
//
//  Created by Artem Kalinovsky on 4/2/17.
//  Copyright © 2017 Artem. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let buildRoute = Notification.Name("buildRouteNotification")
    static let placeDeleted = Notification.Name("placeDeletedNotification")
    static let centerPlaceOnMap = Notification.Name("centerPlaceOnMapNotification")
}
