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

protocol HasLineItems {
    var lineItems: Set<LineItem> { get }
}

extension HasLineItems {
    func lastLineItem(type: String) -> LineItem? {
        lineItems.inverseChrono
            .first { $0.typeId == type }
    }

    func lastLineItem(type: String, where pred: (LineItem) -> Bool) -> LineItem? {
        lineItems.inverseChrono
            .first { $0.typeId == type && pred($0) }
    }

    func lastLineItem(typeIn: Set<String>) -> LineItem? {
        lineItems.inverseChrono
            .first {
                guard let typeId = $0.typeId else { return false }
                return typeIn.contains(typeId)
            }
    }

    func lastLineItem(typeIn: Set<String>, where pred: (LineItem) -> Bool) -> LineItem? {
        lineItems.inverseChrono
            .first {
                guard let typeId = $0.typeId else { return false }
                return typeIn.contains(typeId) && pred($0)
            }
    }

    func lastLineItemField(type: String, field: String) -> LineItemField? {
        lineItems.inverseChrono
            .first(where: {
                $0.typeId == type && $0.getFieldWithoutCreating(id: field) != nil
            })?
            .getFieldWithoutCreating(id: field)
    }

    func lastLineItemField(typeIn: Set<String>, field: String) -> LineItemField? {
        lineItems.inverseChrono
            .first(where: {
                guard let typeId = $0.typeId else { return false }
                return typeIn.contains(typeId) && $0.getFieldWithoutCreating(id: field) != nil
            })?
            .getFieldWithoutCreating(id: field)
    }

    func lastLineItem(replaces: String) -> LineItem? {
        lineItems.inverseChrono
            .first {
                guard let type = $0.type else { return false }
                guard let typeReplaces = type.replaces else { return false }
                return typeReplaces == replaces
            }
    }
}

extension HasLineItems where Self: TracksMiles, Self: HasOdometerReadings {
    func milesSince(logItem: LogItem, odometerReading: Int64) -> Int64 {
        if let reading = logItem.odometerReading?.reading {
            return odometer - reading
        } else {
            return odometer - closestOdometerReadingTo(date: logItem.performedAt ?? Date.distantPast)
        }
    }

    func milesSince(lineItemType: String, odometerReading: Int64) -> Int64? {
        guard let lineItem = lastLineItem(type: lineItemType) else { return nil }
        guard let logItem = lineItem.logItem else { return nil }
        return milesSince(logItem: logItem, odometerReading: odometerReading)
    }

    func milesSince(replaces: String, odometerReading: Int64) -> Int64? {
        guard let lineItem = lastLineItem(replaces: replaces) else { return nil }
        guard let logItem = lineItem.logItem else { return nil }
        return milesSince(logItem: logItem, odometerReading: odometerReading)
    }

    func milesSince(lineItemType: String) -> Int64? {
        return milesSince(lineItemType: lineItemType, odometerReading: odometer)
    }

    func approximateMilesSince(lineItemType: String) -> Int64? {
        return milesSince(lineItemType: lineItemType, odometerReading: approximateOdometer)
    }

    func approximateMilesSince(replaces: String) -> Int64? {
        return milesSince(replaces: replaces, odometerReading: approximateOdometer)
    }

    func timeSince(logItem: LogItem) -> TimeInterval? {
        guard let performedAt = logItem.performedAt else { return nil }
        return Date.now.timeIntervalSinceReferenceDate - performedAt.timeIntervalSinceReferenceDate
    }

    func timeSince(lineItemType: String) -> TimeInterval? {
        guard let lineItem = lastLineItem(type: lineItemType) else { return nil }
        guard let logItem = lineItem.logItem else { return nil }
        return timeSince(logItem: logItem)
    }

    func timeSince(replaces: String) -> TimeInterval? {
        guard let lineItem = lastLineItem(replaces: replaces) else { return nil }
        guard let logItem = lineItem.logItem else { return nil }
        return timeSince(logItem: logItem)
    }
}
