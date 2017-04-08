//
//  FoursquareWebService.swift
//  PinPlace
//
//  Created by Artem on 6/15/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import JASON
import Alamofire
import RxAlamofire
import RxSwift

final class FoursquareWebService {

    fileprivate enum RequestKey: String {
        case clientId = "client_id"
        case clientSecret = "client_secret"
        case apiVersion = "v"
        case coordinates = "ll"
    }

    fileprivate enum ResponseKey: String {
        case response, venues
    }

    fileprivate enum WebServiceConstant: String {
        case searchVenuesURL = "https://api.foursquare.com/v2/venues/search"
        case clientId = "5XOWXECUBZAYTVY1EPA30CGWABN3FJY2XYSFIYK5FJ4WJNYS"
        case clientSecret = "01T2ZQJVU5IYEXK4CF2A5LUFN1K5BEKLPDW3GCITXS4AUNYU"
        case apiVersion = "20141219"
    }

    func fetchNearbyFoursqareVenues(forPlace place: Place) ->Observable<[FoursquareVenue]> {

        let parameters = [RequestKey.clientId.rawValue: WebServiceConstant.clientId.rawValue,
                          RequestKey.clientSecret.rawValue: WebServiceConstant.clientSecret.rawValue,
                          RequestKey.apiVersion.rawValue: WebServiceConstant.apiVersion.rawValue,
                          RequestKey.coordinates.rawValue: "\(place.coordinate.latitude), \(place.coordinate.longitude)"] as Dictionary<String, String>

        return requestJSON(.get, WebServiceConstant.searchVenuesURL.rawValue, parameters: parameters)
            .observeOn(MainScheduler.instance)
            .map { _, responseData in
                return JSON(responseData)[ResponseKey.response.rawValue][ResponseKey.venues.rawValue].map {FoursquareVenue($0)}
        }
    }

}
