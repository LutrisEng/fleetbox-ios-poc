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

extension TireSet: Sortable,
    TracksTime, TracksMiles,
    HasRawLineItemFields, HasLineItemFields,
    HasLineItemFieldLineItems, HasLineItems,
    HasLineItemLogItems, HasLogItems,
    HasRawWarranties, HasWarranties {
    var displayName: String {
        userDisplayName ?? "\(make ?? "Unknown Make") \(model ?? "Unknown Model")"
    }

    var fieldsNs: NSSet? {
        lineItemFieldsNs
    }

    var vehicle: Vehicle? {
        guard let mountedLineItem = lastLineItem(
            type: "mountedTires",
            where: { (try? $0.getFieldValueTireSet("tireSet")) != nil }
        ) else {
            return nil
        }
        guard let mountedLogItem = mountedLineItem.logItem else { return nil }
        if (try? mountedLineItem.getFieldValueTireSet("tireSet")) != self {
            return nil
        }
        let dismountedLogItems = lastLineItem(
            type: "dismountedTires",
            where: {
                $0.logItem?.vehicle == mountedLogItem.vehicle &&
                ($0.logItem?.performedAt ?? Date.distantPast) >
                    (mountedLogItem.performedAt ?? Date.distantFuture)
            }
        )
        if dismountedLogItems == nil {
            return mountedLogItem.vehicle
        } else {
            return nil
        }
    }

    var odometer: Int64 {
        var counter: Int64 = 0
        var mountedOn: Vehicle?
        var mountedAt: Int64?
        for item in logItems.chrono {
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
                        .odometerReadings
                        .first(before: item.performedAt ?? Date.distantFuture) {
                        counter += lastBeforeThis.reading - prevMountedAt
                    } else if let soonestAfterThis = prevMountedOn
                        .odometerReadings
                        .first(after: item.performedAt ?? Date.distantPast) {
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

    var approximateOdometer: Int64 {
        if let vehicle = vehicle {
            return odometer + vehicle.approximateOdometerOffset
        } else {
            return odometer
        }
    }

    var specs: String {
        func maybe(_ number: Int16) -> String {
            if number == 0 {
                return "?"
            } else {
                return String(number)
            }
        }

        func maybe(_ string: String?) -> String {
            if let string = string, string != "" {
                return string
            } else {
                return "?"
            }
        }

        return "\(maybe(vehicleType))\(maybe(width))/" +
        "\(maybe(aspectRatio))\(maybe(construction))\(maybe(diameter)) " +
        "\(maybe(loadIndex))\(maybe(speedRating))"
    }

    var origin: Date? {
        logItems.chrono.first?.performedAt
    }

    enum Category {
        case mounted
        case unmounted
        case hidden
    }

    var category: Category {
        if hidden {
            return .hidden
        } else if vehicle != nil {
            return .mounted
        } else {
            return .unmounted
        }
    }

    var loadCapacity: Int? {
        tireLoadCapacityMap[loadIndex]
    }

    var topSpeed: Int? {
        guard let firstCh = speedRating?.first else { return nil }
        return tireSpeedRatingMap[firstCh]
    }

    func mergeWith(_ other: TireSet) {
        if other == self { return }
        for field in other.fieldsSet {
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
