//
//  Vehicle.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 2/28/22.
//

import Foundation
import CoreData
import Sentry

func dateDifference(_ a: Date?, _ b: Date?) -> Double {
    abs((a ?? Date.distantPast).timeIntervalSince1970 - (b ?? Date.distantPast).timeIntervalSince1970)
}

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

    var currentTireSet: TireSet? {
        for logItem in logItemsInverseChrono {
            for lineItem in logItem.lineItems {
                if lineItem.typeId == "mountedTires" {
                    do {
                        return try lineItem.getFieldValueTireSet("tireSet")
                    } catch {
                        SentrySDK.capture(error: error)
                        return nil
                    }
                }
            }
        }
        return nil
    }

    func closestOdometerReadingTo(date: Date?) -> Int64 {
        odometerReadingsChrono.sorted(by: { dateDifference($0.at, date) < dateDifference($1.at, date) }).first?.reading ?? odometer
    }

    func milesSince(lineItemType: String) -> Int64? {
        for logItem in logItemsInverseChrono {
            for lineItem in logItem.lineItems {
                if lineItem.typeId == lineItemType {
                    if let reading = logItem.odometerReading?.reading {
                        return odometer - reading
                    } else {
                        return odometer - closestOdometerReadingTo(date: logItem.performedAt ?? Date.distantPast)
                    }
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

    func export() throws -> Data {
        let encoder = JSONEncoder()
        let exportable = ExportableVehicle(vehicle: self)
        return try encoder.encode(exportable)
    }

    static func importData(_ data: Data, context: NSManagedObjectContext) throws -> Vehicle {
        let decoder = JSONDecoder()
        let exportable = try decoder.decode(ExportableVehicle.self, from: data)
        return exportable.importVehicle(context: context)
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
    }
}
