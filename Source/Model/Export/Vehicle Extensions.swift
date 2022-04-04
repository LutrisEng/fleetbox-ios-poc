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

import CoreData

extension Fleetbox_Export_Vehicle {
    init(envelope: ExportEnvelopeTemplate, settings: ExportSettings, vehicle: Vehicle) {
        if let displayName = vehicle.displayName {
            self.displayName = displayName
        }
        if let make = vehicle.make {
            self.make = make
        }
        if let model = vehicle.model {
            self.model = model
        }
        if let vin = vehicle.vin {
            self.vin = vin
        }
        year = vehicle.year
        if let imageData = vehicle.imageData {
            self.image = imageData
        }
        logItems = vehicle.logItems.map {
            Fleetbox_Export_LogItem(envelope: envelope, settings: settings, logItem: $0)
        }
        freeOdometerReadings = vehicle.odometerReadings.chrono
                .filter({ $0.logItem == nil })
                .map {
                    Fleetbox_Export_OdometerReading(settings: settings, odometerReading: $0)
                }
        breakin = vehicle.breakin
        warranties = vehicle.warranties.map {
            Fleetbox_Export_Warranty(settings: settings, warranty: $0)
        }
        milesPerYear = vehicle.milesPerYear
        if settings.includeAttachments {
            attachments = vehicle.attachments.map {
                Fleetbox_Export_Attachment(settings: settings, attachment: $0)
            }
        }
    }

    func importVehicle(context: NSManagedObjectContext, envelope: ExportEnvelopeTemplate) -> Vehicle {
        let vehicle = Vehicle(context: context)
        vehicle.displayName = displayName
        vehicle.make = make
        vehicle.model = model
        vehicle.vin = vin
        vehicle.year = year
        if hasImage {
            vehicle.imageData = image
        }
        for logItem in logItems {
            _ = logItem.importLogItem(
                context: context,
                envelope: envelope,
                vehicle: vehicle
            )
        }
        for odometerReading in freeOdometerReadings {
            _ = odometerReading.importOdometerReading(context: context, vehicle: vehicle)
        }
        vehicle.breakin = breakin
        for warranty in warranties {
            _ = warranty.importWarranty(context: context, underlying: vehicle)
        }
        vehicle.milesPerYear = milesPerYear
        for (index, attachment) in attachments.enumerated() {
            let obj = attachment.importAttachment(context: context, index: index)
            obj.vehicle = vehicle
        }
        return vehicle
    }
}
