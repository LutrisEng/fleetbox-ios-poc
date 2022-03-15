//
//  ExportableTireSet.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/15/22.
//

import Foundation
import CoreData

struct ExportableTireSet: Codable {
    let aspectRatio: Int16
    let construction: String?
    let diameter: Int16
    let loadIndex: Int16
    let make: String?
    let model: String?
    let sortOrder: Int16
    let speedRating: String?
    let userDisplayName: String?
    let vehicleType: String?
    let width: Int16

    init(tireSet: TireSet) {
        aspectRatio = tireSet.aspectRatio
        construction = tireSet.construction
        diameter = tireSet.diameter
        loadIndex = tireSet.loadIndex
        make = tireSet.make
        model = tireSet.model
        sortOrder = tireSet.sortOrder
        speedRating = tireSet.speedRating
        userDisplayName = tireSet.userDisplayName
        vehicleType = tireSet.vehicleType
        width = tireSet.width
    }

    func importTireSet(context: NSManagedObjectContext) -> TireSet {
        let tireSet = TireSet(context: context)
        tireSet.aspectRatio = aspectRatio
        tireSet.construction = construction
        tireSet.diameter = diameter
        tireSet.loadIndex = loadIndex
        tireSet.make = make
        tireSet.model = model
        tireSet.sortOrder = sortOrder
        tireSet.speedRating = speedRating
        tireSet.userDisplayName = userDisplayName
        tireSet.vehicleType = vehicleType
        tireSet.width = width
        return tireSet
    }
}
