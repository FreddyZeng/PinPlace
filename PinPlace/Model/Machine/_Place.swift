// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Place.swift instead.

import Foundation
import CoreData

public enum PlaceAttributes: String {
    case location = "location"
    case title = "title"
}

public class _Place: NSManagedObject {

    // MARK: - Class methods

    public class func entityName () -> String {
        return "Place"
    }

    public class func entity(managedObjectContext: NSManagedObjectContext) -> NSEntityDescription? {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext)
    }

    // MARK: - Life cycle methods

    public override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = _Place.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged public
    var location: AnyObject?

    @NSManaged public
    var title: String?

    // MARK: - Relationships

}

