//
//  ExportableVehicle.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import CoreData

struct ExportableVehicle : Codable {
    let displayName: String?
    let make: String?
    let model: String?
    let vin: String?
    let year: Int64
    let logItems: [ExportableLogItem]
    let standaloneOdometerReadings: [ExportableOdometerReading]
    
    init(vehicle: Vehicle) {
        self.displayName = vehicle.displayName
        self.make = vehicle.make
        self.model = vehicle.model
        self.vin = vehicle.vin
        self.year = vehicle.year
        self.logItems = vehicle.logItems.map { ExportableLogItem(logItem: $0) }
        self.standaloneOdometerReadings = vehicle.odometerReadingsChrono
            .filter({ $0.logItem == nil })
            .map { ExportableOdometerReading(odometerReading: $0) }
    }
    
    func importVehicle(context: NSManagedObjectContext) -> Vehicle {
        let vehicle = Vehicle(context: context)
        vehicle.displayName = displayName
        vehicle.make = make
        vehicle.model = model
        vehicle.vin = vin
        vehicle.year = year
        for logItem in logItems {
            _ = logItem.importLogItem(context: context, vehicle: vehicle)
        }
        for odometerReading in standaloneOdometerReadings {
            _ = odometerReading.importOdometerReading(context: context, vehicle: vehicle)
        }
        return vehicle
    }
}
