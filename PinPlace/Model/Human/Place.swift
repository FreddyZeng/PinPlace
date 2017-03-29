
import Foundation
import CoreData
import MapKit

@objc(Place)
open class Place: _Place {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = Place.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertInto: managedObjectContext)
    }
    
    public convenience init?(coordinate: CLLocationCoordinate2D, title: String? = "Unnamed") {
        self.init(managedObjectContext: PlacesDataController.sharedInstance.stack!.mainContext)
        self.title = title
        self.location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

extension Place: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        get {
            guard let location =  self.location as? CLLocation else {
                return CLLocationCoordinate2D()
            }
            
            return location.coordinate
        }
    }
}
