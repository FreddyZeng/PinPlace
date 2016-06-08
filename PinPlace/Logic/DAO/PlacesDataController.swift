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
    
    let model: CoreDataModel!
    var stack: CoreDataStack?
    
    static var coreDataModelName: String {
        get {
            return "PinPlace"
        }
    }
    
    // MARK: - Singleton
    
    static let sharedInstance = PlacesDataController()
    
    // MARK: - Initializer
    
    private init() {
        self.model = CoreDataModel(name: PlacesDataController.coreDataModelName,
                                   bundle: NSBundle.mainBundle())
        
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
            try stack!.mainContext.save()
        } catch {
            
        }
    }
}
