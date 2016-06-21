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

class FoursquareWebService {
    
    private enum RequestKey: String {
        case ClientId = "client_id"
        case ClientSecret = "client_secret"
        case APIVersion = "v"
        case Coordinates = "ll"
    }
    
    private enum ResponseKey: String {
        case Response = "response"
        case Venues = "venues"
    }
    
    private enum WebServiceConstant: String {
        case SearchVenuesURL = "https://api.foursquare.com/v2/venues/search"
        case ClientId = "5XOWXECUBZAYTVY1EPA30CGWABN3FJY2XYSFIYK5FJ4WJNYS"
        case ClientSecret = "01T2ZQJVU5IYEXK4CF2A5LUFN1K5BEKLPDW3GCITXS4AUNYU"
        case APIVersion = "20141219"
    }
    
    func fetchNearbyFoursqareVenues(forPlace place: Place) ->Observable<[FoursquareVenue]> {
        
        let parameters = [RequestKey.ClientId.rawValue : WebServiceConstant.ClientId.rawValue,
                          RequestKey.ClientSecret.rawValue : WebServiceConstant.ClientSecret.rawValue,
                          RequestKey.APIVersion.rawValue : WebServiceConstant.APIVersion.rawValue,
                          RequestKey.Coordinates.rawValue : "\(place.coordinate.latitude), \(place.coordinate.longitude)"] as Dictionary<String, String>
        
        
        return requestJSON(Method.GET, WebServiceConstant.SearchVenuesURL.rawValue, parameters: parameters)
            .observeOn(MainScheduler.instance)
            .map { httpUrlResponse, responseData in
                return JSON(responseData)[ResponseKey.Response.rawValue][ResponseKey.Venues.rawValue].map{FoursquareVenue($0)}
        }
    }
    
}
