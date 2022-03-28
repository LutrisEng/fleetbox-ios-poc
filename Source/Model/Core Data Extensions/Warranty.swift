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

extension Warranty: Sortable {
    convenience init(context: NSManagedObjectContext, vehicle: Vehicle) {
        self.init(context: context)
        self.sortOrder = (vehicle.warranties.last?.sortOrder ?? -1) + 1
        self.vehicle = vehicle
    }

    convenience init(context: NSManagedObjectContext, tireSet: TireSet) {
        self.init(context: context)
        self.sortOrder = (tireSet.warranties.last?.sortOrder ?? -1) + 1
        self.tireSet = tireSet
    }

    func calculateProgress(atMiles: Int64) -> Double? {
        if miles == 0 { return nil }
        return min(1, Double(atMiles) / Double(miles))
    }

    func calculateProgress(atMonths: Double) -> Double? {
        if months == 0 { return nil }
        return min(1, atMonths / Double(months))
    }

    static func monthsSince(origin: Date) -> Double {
        let components = Calendar.current.dateComponents([.month, .day], from: origin, to: Date.now)
        // On average, there are 30.437 days in a month.
        // See Britannica: https://www.britannica.com/science/time/Lengths-of-years-and-months
        // This provides a good-enough approximation, we just want a progress bar to advance a bit
        // on a daily basis.
        return Double(components.month ?? 0) + (Double(components.day ?? 0) / 30.437)
    }

    func calculateProgress(origin: Date) -> Double? {
        return calculateProgress(atMonths: Warranty.monthsSince(origin: origin))
    }

    func calculateProgress(atMiles: Int64?, origin: Date?) -> Double? {
        if let atMiles = atMiles, let origin = origin {
            if miles == 0 && months == 0 { return nil }
            return max(calculateProgress(atMiles: atMiles) ?? 0, calculateProgress(origin: origin) ?? 0)
        } else if let atMiles = atMiles {
            return calculateProgress(atMiles: atMiles)
        } else if let origin = origin {
            return calculateProgress(origin: origin)
        } else {
            return nil
        }
    }

    var underlyingEntity: (TracksTime & TracksMiles)? {
        if let vehicle = vehicle {
            return vehicle
        } else if let tireSet = tireSet {
            return tireSet
        } else {
            return nil
        }
    }

    var underlyingOdometer: Int64? {
        underlyingEntity?.odometer
    }

    var underlyingOrigin: Date? {
        underlyingEntity?.origin
    }

    var milesProgress: Double? {
        if let underlyingOdometer = underlyingOdometer {
            return calculateProgress(atMiles: underlyingOdometer)
        } else {
            return nil
        }
    }

    var monthsProgress: Double? {
        if let underlyingOrigin = underlyingOrigin {
            return calculateProgress(origin: underlyingOrigin)
        } else {
            return nil
        }
    }

    var progress: Double? {
        calculateProgress(atMiles: underlyingOdometer, origin: underlyingOrigin)
    }

    var milesPercentage: String? {
        if let progress = milesProgress {
            return Formatter.format(wholePercentage: progress)
        } else {
            return nil
        }
    }

    var monthsPercentage: String? {
        if let progress = monthsProgress {
            return Formatter.format(wholePercentage: progress)
        } else {
            return nil
        }
    }

    var percentage: String? {
        if let progress = progress {
            return Formatter.format(wholePercentage: progress)
        } else {
            return nil
        }
    }

    var badge: Badge? {
        if let progress = progress {
            if progress < 1 {
                return .success
            } else {
                return .warning
            }
        } else {
            return nil
        }
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        vehicle?.objectWillChange.send()
        tireSet?.objectWillChange.send()
    }
}
