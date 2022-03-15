//
//  ExportableOdometerReading.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import CoreData

struct ExportableOdometerReading: Codable {
    // swiftlint:disable:next identifier_name
    let at: Date?
    let reading: Int64

    init(odometerReading: OdometerReading) {
        at = odometerReading.at
        reading = odometerReading.reading
    }

    func importOdometerReading(context: NSManagedObjectContext, vehicle: Vehicle) -> OdometerReading {
        let odometerReading = OdometerReading(context: context)
        odometerReading.vehicle = vehicle
        odometerReading.at = at
        odometerReading.reading = reading
        return odometerReading
    }

    func importOdometerReading(context: NSManagedObjectContext, logItem: LogItem) -> OdometerReading {
        let odometerReading = OdometerReading(context: context, logItem: logItem)
        odometerReading.at = at
        odometerReading.reading = reading
        return odometerReading
    }
}