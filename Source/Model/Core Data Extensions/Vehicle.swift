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

extension Vehicle {
    var logItems: Set<LogItem> {
        logItemsNs as? Set<LogItem> ?? []
    }

    var logItemsChrono: [LogItem] {
        logItems.sorted {
            ($0.performedAt ?? Date.distantPast) < ($1.performedAt ?? Date.distantPast)
        }
    }

    var logItemsInverseChrono: [LogItem] {
        logItems.sorted {
            ($0.performedAt ?? Date.distantPast) > ($1.performedAt ?? Date.distantPast)
        }
    }

    var odometerReadingSet: Set<OdometerReading> {
        odometerReadingsNs as? Set<OdometerReading> ?? []
    }

    var odometerReadingsChrono: [OdometerReading] {
        odometerReadingSet.sorted {
            ($0.at ?? Date.distantPast) < ($1.at ?? Date.distantPast)
        }
    }

    var odometerReadingsInverseChrono: [OdometerReading] {
        odometerReadingSet.sorted {
            ($0.at ?? Date.distantPast) > ($1.at ?? Date.distantPast)
        }
    }

    var odometer: Int64 {
        odometerReadingsInverseChrono.first?.reading ?? 0
    }

    func lastLineItem(type: String) -> LineItem? {
        for logItem in logItemsInverseChrono {
            for lineItem in logItem.lineItems where lineItem.typeId == type {
                return lineItem
            }
        }
        return nil
    }

    var currentTireSet: TireSet? {
        do {
            return try lastLineItem(type: "mountedTires")?.getFieldValueTireSet("tireSet")
        } catch {
            SentrySDK.capture(error: error)
            return nil
        }
    }

    func closestOdometerReadingTo(date: Date?) -> Int64 {
        odometerReadingsChrono
                .sorted(by: { dateDifference($0.at, date) < dateDifference($1.at, date) })
                .first?
                .reading
                ?? odometer
    }

    func milesSince(lineItemType: String) -> Int64? {
        for logItem in logItemsInverseChrono {
            for lineItem in logItem.lineItems where lineItem.typeId == lineItemType {
                if let reading = logItem.odometerReading?.reading {
                    return odometer - reading
                } else {
                    return odometer - closestOdometerReadingTo(date: logItem.performedAt ?? Date.distantPast)
                }
            }
        }
        return nil
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
