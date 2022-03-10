//
//  VehicleSpotlightDelegate.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 2/28/22.
//

import Foundation
import CoreData
import CoreSpotlight

class VehicleSpotlightDelegate: NSCoreDataCoreSpotlightDelegate {
    override func domainIdentifier() -> String {
        "engineering.lutris.fleetbox.vehicles"
    }
    
    override func indexName() -> String? {
        "vehicles-index"
    }
    
    override func attributeSet(for object: NSManagedObject) -> CSSearchableItemAttributeSet? {
        if let vehicle = object as? Vehicle {
            let attributeSet = CSSearchableItemAttributeSet(contentType: .content)
            attributeSet.identifier = vehicle.vin
            attributeSet.displayName = vehicle.displayName
            return attributeSet
        }
        return nil
    }
}
