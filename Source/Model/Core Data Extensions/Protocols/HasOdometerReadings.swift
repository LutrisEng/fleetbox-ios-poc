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

protocol HasOdometerReadings {
    var odometerReadings: Set<OdometerReading> { get }
}

extension HasOdometerReadings {
    var calculatedAverageMilesPerSecond: Double? {
        let readings = odometerReadings.chrono
        guard let first = readings.first(where: { $0.at != nil }) else { return nil }
        guard let last = readings.last(where: { $0.at != nil }) else { return nil }
        if first == last { return nil }

        let miles = last.reading - first.reading
        let interval = last.at!.timeIntervalSinceReferenceDate - first.at!.timeIntervalSinceReferenceDate

        return Double(miles) / interval
    }

    var calculatedAverageMilesPerYear: Int64? {
        guard let calculatedAverageMilesPerSecond = calculatedAverageMilesPerSecond else {
            return nil
        }
        return Int64(round(calculatedAverageMilesPerSecond * secondsPerHour * hoursPerDay * daysPerYear))
    }

    var averageMilesPerSecond: Double? {
        calculatedAverageMilesPerSecond
    }
}

extension HasOdometerReadings where Self: HasMilesPerYear {
    var averageMilesPerSecond: Double? {
        if milesPerYear != 0 {
            return Double(milesPerYear) / daysPerYear / hoursPerDay / secondsPerHour
        } else {
            return calculatedAverageMilesPerSecond
        }
    }
}

extension HasOdometerReadings where Self: TracksMiles {
    func closestOdometerReadingTo(date: Date?) -> Int64 {
        odometerReadings.chrono
            .sorted(by: { dateDifference($0.at, date) < dateDifference($1.at, date) })
            .first?
            .reading
            ?? odometer
    }

    var approximateOdometerOffset: Int64 {
        guard let averageMilesPerSecond = averageMilesPerSecond else { return 0 }
        guard let lastOdometerReading = odometerReadings.inverseChrono.first(where: { $0.at != nil }) else {
            return 0
        }
        let timeSinceLastOdometer = Date.now.timeIntervalSinceReferenceDate -
            lastOdometerReading.at!.timeIntervalSinceReferenceDate
        let daysSinceLastOdometer = toDays(interval: timeSinceLastOdometer)
        if daysSinceLastOdometer > 3 {
            let approxMilesSinceLastOdometer = averageMilesPerSecond * timeSinceLastOdometer
            return Int64(round(approxMilesSinceLastOdometer))
        } else {
            return 0
        }
    }

    var approximateOdometer: Int64 {
        odometer + approximateOdometerOffset
    }
}
