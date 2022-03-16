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

    var lineItemsChrono: [LineItem] {
        lineItems.sorted {
            ($0.logItem?.performedAt ?? Date.distantPast) > ($1.logItem?.performedAt ?? Date.distantPast)
        }
    }

    var lineItemsInverseChrono: [LineItem] {
        lineItems.sorted {
            ($0.logItem?.performedAt ?? Date.distantPast) < ($1.logItem?.performedAt ?? Date.distantPast)
        }
    }

    var logItems: Set<LogItem> {
        Set(lineItems.compactMap {
            $0.logItem
        })
    }

    var logItemsChrono: [LogItem] {
        logItems.sorted {
            ($0.performedAt ?? Date.distantPast) > ($1.performedAt ?? Date.distantPast)
        }
    }

    var logItemsInverseChrono: [LogItem] {
        logItems.sorted {
            ($0.performedAt ?? Date.distantPast) < ($1.performedAt ?? Date.distantPast)
        }
    }

    func lastLineItem(type: String) -> LineItem? {
        return lineItemsInverseChrono.first(where: { $0.typeId == type })
    }

    var vehicle: Vehicle? {
        return lastLineItem(type: "mountedTires")?.logItem?.vehicle
    }

    var odometer: Int64 {
        var counter: Int64 = 0
        var mountedOn: Vehicle?
        var mountedAt: Int64?
        for item in logItemsChrono {
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

    func mergeWith(_ other: TireSet) {
        if other == self { return }
        for field in other.lineItemFields {
            field.tireSetValue = self
        }
        if let context = managedObjectContext {
            context.delete(other)
        }
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
    }
}
