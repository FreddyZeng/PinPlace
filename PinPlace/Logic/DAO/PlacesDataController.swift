//
//  PlacesDataController.swift
//  PinPlace
//
//  Created by Artem on 6/8/16.
//  Copyright © 2016 Artem. All rights reserved.
//

import Foundation
import JSQCoreDataKit

class PlacesDataController {
    
    // MARK: - Properties
    
    fileprivate let model: CoreDataModel!
    var stack: CoreDataStack?
    
    fileprivate static var coreDataModelName: String {
        get {
            return "PinPlace"
        }
    }
    
    // MARK: - Singleton
    
    static let sharedInstance = PlacesDataController()
    
    // MARK: - Initializer
    
    fileprivate init() {
        self.model = CoreDataModel(name: PlacesDataController.coreDataModelName,
                                   bundle: Bundle.main)
        
        let factory = CoreDataStackFactory(model: model)
        factory.createStack(onQueue: nil) { [unowned self](result: StackResult) in
            switch result {
            case .success(let s):
                self.stack = s
                
            case .failure(let e):
                print("Error: \(e)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    func saveChanges() {
        do {
            try stack?.mainContext.save()
        } catch {
            
        }
    }
    
    func fetchPlaces() -> Array<Place> {
        var result = Array<Place>()
        
        guard let stack = self.stack, let placeEntity = Place.entity(stack.mainContext) else {
            return result
        }
        
        //let request = FetchRequest<Place>(entity: placeEntity)
        let request = Place.fetchRequest()
        
        do {
            result = try stack.mainContext.fetch(request) as! Array<Place>
        } catch {
            print("Fetch error: \(error)")
        }
        
        return result
    }
    
    func deletePlace(_ place: Place) {
        guard let stack = self.stack else {
            return
        }
        stack.mainContext.delete(place)
        do {
            try stack.mainContext.save()
        } catch {
            
        }
    }
}
