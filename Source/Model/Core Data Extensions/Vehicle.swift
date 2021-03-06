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
import Sentry
import UIKit
import VehicleKit

extension Vehicle: Sortable,
    TracksTime, TracksMiles, TracksApproximateMiles, HasBreakin,
    HasRawLogItems, HasLogItems,
    HasLogItemLineItems, HasLineItems,
    HasRawOdometerReadings, HasOdometerReadings,
    HasRawWarranties, HasWarranties,
    HasRawAttachments, HasAttachments {
    var odometer: Int64 {
        odometerReadings.inverseChrono.first?.reading ?? 0
    }

    var currentTireSet: TireSet? {
        guard let mountedLineItem = lastLineItem(
            type: "mountedTires",
            where: { (try? $0.getFieldValueTireSet("tireSet")) != nil }
        ) else {
            return nil
        }
        guard let tireSet = try? mountedLineItem.getFieldValueTireSet("tireSet") else {
            return nil
        }
        let dismountedLogItems = lastLineItem(
            type: "dismountedTires",
            where: {
                (try? $0.getFieldValueTireSet("tireSet")) == tireSet &&
                ($0.logItem?.performedAt ?? Date.distantPast) >
                    (mountedLineItem.logItem?.performedAt ?? Date.distantFuture)
            }
        )
        if dismountedLogItems == nil {
            return tireSet
        } else {
            return nil
        }
    }

    static func generateFullModelName(
        year: Int64,
        make: String?,
        model: String?,
        fallback: String = "Unknown Vehicle"
    ) -> String {
        if let make = make {
            if let model = model {
                if year != 0 {
                    return "\(year) \(make) \(model)"
                } else {
                    return "\(make) \(model)"
                }
            } else {
                return make
            }
        } else if let model = model {
            if year != 0 {
                return "\(year) \(model)"
            } else {
                return model
            }
        } else {
            return fallback
        }
    }

    var fullModelName: String {
        Vehicle.generateFullModelName(year: year, make: make, model: model)
    }

    var displayNameWithFallback: String {
        if let displayName = displayName, displayName != "" {
            return displayName
        } else {
            return fullModelName
        }
    }

    var registrationState: String? {
        ignoreErrors {
            try lastLineItem(type: "stateRegistration")?.getFieldValueString("state")
        }
    }

    var lastOilViscosity: String? {
        ignoreErrors {
            try lastLineItem(type: "engineOilChange")?.getFieldValueString("viscosity")
        }
    }

    var image: UIImage? {
        get {
            if let data = imageData {
                return UIImage(data: data)
            } else {
                return nil
            }
        }

        set {
            imageData = newValue?.pngData()
        }
    }

    var licensePlateNumber: String? {
        lastLineItemField(
            typeIn: ["stateRegistration", "vanityPlateMounted"],
            field: "licensePlateNumber"
        )?.stringValue?.normalized
    }

    var possibleAPIs: [VKAPIDirectory.API] {
        if let make = make {
            return VKAPIDirectory.apis(forMake: make)
        } else {
            return []
        }
    }

    func export(settings: ExportSettings) throws -> Data? {
        let ctx = ExportEnvelopeTemplate(vehicle: self)
        let exportable = ctx.export(settings: settings)
        return try exportable?.serializedData()
    }

    static func importData(_ data: Data, context: NSManagedObjectContext) throws -> Vehicle? {
        let envelope = try Fleetbox_Export_ExportEnvelope(serializedData: data)
        let tmpl = ExportEnvelopeTemplate(context: context, envelope: envelope)
        return tmpl.vehicle
    }
}
