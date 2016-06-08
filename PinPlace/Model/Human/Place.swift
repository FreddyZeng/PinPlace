
import Foundation
import CoreData
import MapKit

@objc(Place)
public class Place: _Place {
    
    public convenience init?(managedObjectContext: NSManagedObjectContext) {
        guard let entity = Place.entity(managedObjectContext) else { return nil }
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
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
            let location = self.location as! CLLocation
            return location.coordinate
        }
    }
}
