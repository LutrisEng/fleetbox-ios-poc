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
            ($0.logItem?.performedAt ?? Date.distantPast) < ($1.logItem?.performedAt ?? Date.distantPast)
        }
    }

    var lineItemsInverseChrono: [LineItem] {
        lineItems.sorted {
            ($0.logItem?.performedAt ?? Date.distantPast) > ($1.logItem?.performedAt ?? Date.distantPast)
        }
    }

    var logItems: Set<LogItem> {
        Set(lineItems.compactMap {
            $0.logItem
        })
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

    func lastLineItem(type: String) -> LineItem? {
        return lineItemsInverseChrono.first(where: { $0.typeId == type })
    }

    func lastLineItem(type: String, where pred: (LineItem) -> Bool) -> LineItem? {
        return lineItemsInverseChrono.first(where: { $0.typeId == type && pred($0) })
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

    var age: TimeInterval? {
        if let firstLogItemAt = logItemsChrono.compactMap(\.performedAt).first {
            return Date.now.timeIntervalSinceReferenceDate -
                firstLogItemAt.timeIntervalSinceReferenceDate
        } else {
            return nil
        }
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

    static let loadCapacityMap: [Int16: Int] = [
        0: 99,
        1: 102,
        2: 105,
        3: 107,
        4: 110,
        5: 114,
        6: 117,
        7: 120,
        8: 123,
        9: 128,
        10: 132,
        11: 136,
        12: 139,
        13: 143,
        14: 148,
        15: 152,
        16: 157,
        17: 161,
        18: 165,
        19: 171,
        20: 176,
        21: 182,
        22: 187,
        23: 193,
        24: 198,
        25: 204,
        26: 209,
        27: 215,
        28: 220,
        29: 227,
        30: 234,
        31: 240,
        32: 247,
        33: 254,
        34: 260,
        35: 267,
        36: 276,
        37: 282,
        38: 291,
        39: 300,
        40: 309,
        41: 320,
        42: 331,
        43: 342,
        44: 353,
        45: 364,
        46: 375,
        47: 386,
        48: 397,
        49: 408,
        50: 419,
        51: 430,
        52: 441,
        53: 454,
        54: 467,
        55: 481,
        56: 494,
        57: 507,
        58: 520,
        59: 536,
        60: 551,
        61: 567,
        62: 584,
        63: 600,
        64: 617,
        65: 639,
        66: 639,
        67: 677,
        68: 694,
        69: 716,
        70: 739,
        71: 761,
        72: 783,
        73: 805,
        74: 827,
        75: 852,
        76: 882,
        77: 908,
        78: 937,
        79: 963,
        80: 992,
        81: 1019,
        82: 1047,
        83: 1074,
        84: 1102,
        85: 1135,
        86: 1168,
        87: 1201,
        88: 1235,
        89: 1279,
        90: 1323,
        91: 1356,
        92: 1389,
        93: 1433,
        94: 1477,
        95: 1521,
        96: 1565,
        97: 1609,
        98: 1653,
        99: 1709,
        100: 1764,
        101: 1819,
        102: 1874,
        103: 1929,
        104: 1984,
        105: 2039,
        106: 2094,
        107: 2149,
        108: 2205,
        109: 2271,
        110: 2337,
        111: 2403,
        112: 2469,
        113: 2535,
        114: 2601,
        115: 2679,
        116: 2756,
        117: 2833,
        118: 2910,
        119: 2998,
        120: 3086,
        121: 3197,
        122: 3307,
        123: 3417,
        124: 3527,
        125: 3638,
        126: 3748,
        127: 3858,
        128: 3968,
        129: 4079,
        130: 4189,
        131: 4289,
        132: 4409,
        133: 4541,
        134: 4674,
        135: 4806,
        136: 4938,
        137: 5071,
        138: 5203,
        139: 5357,
        140: 5512,
        141: 5677,
        142: 5842,
        143: 6008,
        144: 6173,
        145: 6393,
        146: 6614,
        147: 6779,
        148: 6844,
        149: 7165,
        150: 7385
    ]

    var loadCapacity: Int? {
        TireSet.loadCapacityMap[loadIndex]
    }

    static let speedRatingMap: [Character: Int] = [
        "B": 31,
        "C": 37,
        "D": 40,
        "E": 43,
        "F": 50,
        "G": 56,
        "J": 62,
        "K": 68,
        "L": 75,
        "M": 81,
        "N": 87,
        "P": 93,
        "Q": 100,
        "R": 106,
        "S": 112,
        "T": 118,
        "U": 124,
        "H": 130,
        "V": 149,
        "W": 168,
        "Y": 186
    ]

    var topSpeed: Int? {
        guard let firstCh = speedRating?.first else { return nil }
        return TireSet.speedRatingMap[firstCh]
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
