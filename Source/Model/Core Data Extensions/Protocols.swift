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

protocol Sortable {
    var sortOrder: Int16 { get set }
}

protocol Dated {
    // swiftlint:disable:next identifier_name
    var at: Date? { get set }
}

extension Dated {
    var formattedDate: String? {
        if let date = at {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("dd MMMM YYYY")
            return formatter.string(from: date)
        } else {
            return nil
        }
    }
}

protocol TracksMiles {
    var odometer: Int64 { get }
}

protocol TracksTime {
    var origin: Date? { get }
}

extension TracksTime {
    var age: TimeInterval? {
        if let origin = origin {
            return Date.now.timeIntervalSinceReferenceDate - origin.timeIntervalSinceReferenceDate
        } else {
            return nil
        }
    }
}

protocol HasRawLogItems {
    var logItemsNs: NSSet? { get }
}

extension HasRawLogItems {
    var logItems: Set<LogItem> {
        logItemsNs as? Set<LogItem> ?? []
    }
}

protocol HasLogItems {
    var logItems: Set<LogItem> { get }
}

extension HasLogItems {
    var origin: Date? {
        return logItems.chrono.first?.performedAt
    }

    var vehicles: [Vehicle] {
        logItems.inverseChrono.compactMap({ $0.vehicle }).unique()
    }
}

protocol HasLogItemLineItems: HasLogItems {}

extension HasLogItemLineItems {
    var lineItems: Set<LineItem> {
        Set(logItems.flatMap { $0.lineItems })
    }
}

protocol HasRawLineItems {
    var lineItemsNs: NSSet? { get }
}

extension HasRawLineItems {
    var lineItems: Set<LineItem> {
        lineItemsNs as? Set<LineItem> ?? []
    }
}

protocol HasLineItems {
    var lineItems: Set<LineItem> { get }
}

extension HasLineItems {
    func lastLineItem(type: String) -> LineItem? {
        return lineItems.inverseChrono
            .first(where: { $0.typeId == type })
    }

    func lastLineItem(type: String, where pred: (LineItem) -> Bool) -> LineItem? {
        return lineItems.inverseChrono
            .first(where: { $0.typeId == type && pred($0) })
    }
}

extension HasLineItems where Self: TracksMiles, Self: HasOdometerReadings {
    func milesSince(lineItemType: String) -> Int64? {
        guard let lineItem = lastLineItem(type: lineItemType) else { return nil }
        guard let logItem = lineItem.logItem else { return nil }
        if let reading = logItem.odometerReading?.reading {
            return odometer - reading
        } else {
            return odometer - closestOdometerReadingTo(date: logItem.performedAt ?? Date.distantPast)
        }
    }

    func timeSince(lineItemType: String) -> TimeInterval? {
        guard let lineItem = lastLineItem(type: lineItemType) else { return nil }
        guard let logItem = lineItem.logItem else { return nil }
        guard let performedAt = logItem.performedAt else { return nil }
        return Date.now.timeIntervalSinceReferenceDate - performedAt.timeIntervalSinceReferenceDate
    }
}

protocol HasLineItemLogItems: HasLineItems {}

extension HasLineItemLogItems {
    var logItems: Set<LogItem> {
        Set(lineItems.compactMap { $0.logItem })
    }
}

protocol HasRawOdometerReadings {
    var odometerReadingsNs: NSSet? { get }
}

extension HasRawOdometerReadings {
    var odometerReadings: Set<OdometerReading> {
        odometerReadingsNs as? Set<OdometerReading> ?? []
    }
}

protocol HasOdometerReadings {
    var odometerReadings: Set<OdometerReading> { get }
}

extension HasOdometerReadings where Self: TracksMiles {
    func closestOdometerReadingTo(date: Date?) -> Int64 {
        odometerReadings.chrono
            .sorted(by: { dateDifference($0.at, date) < dateDifference($1.at, date) })
            .first?
            .reading
            ?? odometer
    }
}

protocol HasRawWarranties {
    var warrantiesNs: NSSet? { get }
}

extension HasRawWarranties {
    var warrantiesSet: Set<Warranty> {
        warrantiesNs as? Set<Warranty> ?? []
    }
}

protocol HasWarranties {
    var warrantiesSet: Set<Warranty> { get }
}

extension HasWarranties {
    var warranties: [Warranty] {
        warrantiesSet.sorted
    }
}

protocol HasRawAttachments {
    var attachmentsNs: NSSet? { get }
}

extension HasRawAttachments {
    var attachmentSet: Set<Attachment> {
        attachmentsNs as? Set<Attachment> ?? []
    }
}

protocol HasAttachments {
    var attachmentSet: Set<Attachment> { get }
}

extension HasAttachments {
    var attachments: [Attachment] {
        attachmentSet.sorted
    }
}

protocol HasRawLineItemFields {
    var fieldsNs: NSSet? { get }
}

extension HasRawLineItemFields {
    var fieldsSet: Set<LineItemField> {
        fieldsNs as? Set<LineItemField> ?? []
    }
}

protocol HasLineItemFields {
    var fieldsSet: Set<LineItemField> { get }
}

protocol HasLineItemFieldLineItems: HasLineItemFields {}

extension HasLineItemFieldLineItems {
    var lineItems: Set<LineItem> {
        Set(fieldsSet.compactMap { $0.lineItem })
    }
}
