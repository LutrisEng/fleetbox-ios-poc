//  SPDX-License-Identifier: GPL-3.0-or-later
//  Fleetbox, a tool for managing vehicle maintenance logs
//  Copyright (C) 2022 Lutris, Inc
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import Foundation
import CoreData

struct ExportableVehicle: Codable {
    let displayName: String?
    let make: String?
    let model: String?
    let vin: String?
    let year: Int64
    let logItems: [ExportableLogItem]
    let standaloneOdometerReadings: [ExportableOdometerReading]

    init(context: ExportContext, vehicle: Vehicle) {
        displayName = vehicle.displayName
        make = vehicle.make
        model = vehicle.model
        vin = vehicle.vin
        year = vehicle.year
        logItems = vehicle.logItems.map {
            ExportableLogItem(context: context, logItem: $0)
        }
        standaloneOdometerReadings = vehicle.odometerReadingsChrono
                .filter({ $0.logItem == nil })
                .map {
                    ExportableOdometerReading(odometerReading: $0)
                }
    }

    func importVehicle(context: NSManagedObjectContext, exportContext: ExportContext) -> Vehicle {
        let vehicle = Vehicle(context: context)
        vehicle.displayName = displayName
        vehicle.make = make
        vehicle.model = model
        vehicle.vin = vin
        vehicle.year = year
        for logItem in logItems {
            _ = logItem.importLogItem(
                context: context,
                exportContext: exportContext,
                vehicle: vehicle
            )
        }
        for odometerReading in standaloneOdometerReadings {
            _ = odometerReading.importOdometerReading(context: context, vehicle: vehicle)
        }
        return vehicle
    }
}
