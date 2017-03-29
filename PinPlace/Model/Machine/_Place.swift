// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Place.swift instead.

import Foundation
import CoreData

public enum PlaceAttributes: String {
    case location = "location"
    case title = "title"
}

open class _Place: NSManagedObject {

    // MARK: - Class methods

    open class func entityName () -> String {
        return "Place"
    }

    open class func entity(_ managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entity(forEntityName: self.entityName(), in: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Place.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged open
    var location: AnyObject?

    @NSManaged open
    var title: String?

    // MARK: - Relationships

}

