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

extension Vehicle: Sortable,
    TracksTime, TracksMiles,
    HasRawLogItems, HasLogItems,
    HasLogItemLineItems, HasLineItems,
    HasRawOdometerReadings, HasOdometerReadings,
    HasRawWarranties, HasWarranties {
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

    var fullModelName: String {
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
            return "Unknown Vehicle"
        }
    }

    var displayNameWithFallback: String {
        if let displayName = displayName, displayName != "" {
            return displayName
        } else {
            return fullModelName
        }
    }

    var registrationState: String? {
        do {
            return try lastLineItem(type: "stateRegistration")?.getFieldValueString("state")
        } catch {
            SentrySDK.capture(error: error)
            return nil
        }
    }

    var lastOilViscosity: String? {
        do {
            return try lastLineItem(type: "engineOilChange")?.getFieldValueString("viscosity")
        } catch {
            SentrySDK.capture(error: error)
            return nil
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

    func export() throws -> Data? {
        let ctx = ExportEnvelopeTemplate(vehicle: self)
        let exportable = ctx.export()
        return try exportable?.serializedData()
    }

    static func importData(_ data: Data, context: NSManagedObjectContext) throws -> Vehicle? {
        let envelope = try Fleetbox_Export_ExportEnvelope(serializedData: data)
        let tmpl = ExportEnvelopeTemplate(context: context, envelope: envelope)
        return tmpl.vehicle
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
    }
}
