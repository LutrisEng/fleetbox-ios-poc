//
//  TireSet.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
//

import Foundation
import CoreData

extension TireSet {
    var displayName: String {
        userDisplayName ?? "\(make ?? "Unknown Make") \(model ?? "Unknown Model")"
    }

    var lineItemFields: Set<LineItemField> {
        lineItemFieldsNs as? Set<LineItemField> ?? []
    }

    var lineItems: Set<LineItem> {
        Set(lineItemFields.compactMap {
            $0.lineItem
        })
    }

    var logItems: Set<LogItem> {
        Set(lineItems.compactMap {
            $0.logItem
        })
    }

    var logItemsSorted: [LogItem] {
        logItems.sorted {
            ($0.performedAt ?? Date.distantPast) < ($1.performedAt ?? Date.distantPast)
        }
    }

    var odometer: Int64 {
        var counter: Int64 = 0
        var mountedOn: Vehicle?
        var mountedAt: Int64?
        for item in logItemsSorted {
            if item.removedTireSets.contains(self) {
                if let dismountedAt = item.odometerReading?.reading {
                    counter += dismountedAt - (mountedAt ?? 0)
                } else if let vehicle = item.vehicle {
                    let closestReading = vehicle.closestOdometerReadingTo(date: item.performedAt)
                    counter += closestReading - (mountedAt ?? 0)
                }
                mountedAt = nil
                mountedOn = nil
            }
            if item.addedTireSets.contains(self) {
                if let prevMountedOn = mountedOn, let prevMountedAt = mountedAt {
                    if let lastBeforeThis = prevMountedOn
                            .odometerReadingsChrono
                            .first(where: { ($0.at ?? Date.distantPast) < (item.performedAt ?? Date.distantPast) }) {
                        counter += lastBeforeThis.reading - prevMountedAt
                    } else if let soonestAfterThis = prevMountedOn
                            .odometerReadingsChrono
                            .first(where: { ($0.at ?? Date.distantPast) > (item.performedAt ?? Date.distantPast) }) {
                        counter += soonestAfterThis.reading - prevMountedAt
                    } else {
                        counter += prevMountedOn.odometer - prevMountedAt
                    }
                } else if let prevMountedOn = mountedOn {
                    counter += prevMountedOn.odometer
                }

                if let newMountedAt = item.odometerReading?.reading {
                    mountedAt = newMountedAt
                } else if let vehicle = item.vehicle {
                    let closestReading = vehicle.closestOdometerReadingTo(date: item.performedAt)
                    mountedAt = closestReading
                }
                mountedOn = item.vehicle
            }
        }
        if let mountedAt = mountedAt, let mountedOn = mountedOn {
            counter += mountedOn.odometer - mountedAt
        }
        return counter
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
    }
}
