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

func dateDifference(_ first: Date?, _ second: Date?) -> Double {
    abs((first ?? Date.distantPast).timeIntervalSince1970 - (second ?? Date.distantPast).timeIntervalSince1970)
}

func monthsSince(origin: Date) -> Double {
    let components = Calendar.current.dateComponents([.month, .day], from: origin, to: Date.now)
    return Double(components.month ?? 0) + (Double(components.day ?? 0) / daysPerMonth)
}

func toMonths(interval: TimeInterval) -> Double {
    let origin = Date(timeIntervalSinceReferenceDate: Date.now.timeIntervalSinceReferenceDate - interval)
    return monthsSince(origin: origin)
}

let secondsPerMinute: Double = 60
let minutesPerHour: Double = 60
let secondsPerHour: Double = secondsPerMinute * minutesPerHour
let hoursPerDay: Double = 24
let secondsPerDay: Double = secondsPerHour * hoursPerDay
// On average, there are 30.437 days in a month.
// See Britannica: https://www.britannica.com/science/time/Lengths-of-years-and-months
// This provides a good-enough approximation for most purposes
let daysPerMonth: Double = 30.437
let daysPerYear: Double = 365.2425

func toDays(interval: TimeInterval) -> Double {
    return interval * secondsPerDay
}
