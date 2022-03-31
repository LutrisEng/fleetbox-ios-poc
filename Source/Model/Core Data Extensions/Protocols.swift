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
            return Formatter.format(dateLabel: date)
        } else {
            return nil
        }
    }
}

protocol MaybeTimed {
    var includeTime: Bool { get set }
}

extension MaybeTimed where Self: Dated {
    var formattedDate: String? {
        if let date = at {
            if includeTime {
                return Formatter.format(dateTimeLabel: date)
            } else {
                return Formatter.format(dateLabel: date)
            }
        } else {
            return nil
        }
    }
}

protocol TracksMiles {
    var odometer: Int64 { get }
}

protocol TracksApproximateMiles {
    var approximateOdometer: Int64 { get }
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
    func milesSince(lineItemType: String, odometerReading: Int64) -> Int64? {
        guard let lineItem = lastLineItem(type: lineItemType) else { return nil }
        guard let logItem = lineItem.logItem else { return nil }
        if let reading = logItem.odometerReading?.reading {
            return odometer - reading
        } else {
            return odometer - closestOdometerReadingTo(date: logItem.performedAt ?? Date.distantPast)
        }
    }

    func milesSince(lineItemType: String) -> Int64? {
        return milesSince(lineItemType: lineItemType, odometerReading: odometer)
    }

    func approximateMilesSince(lineItemType: String) -> Int64? {
        return milesSince(lineItemType: lineItemType, odometerReading: approximateOdometer)
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

protocol HasMilesPerYear {
    var milesPerYear: Int64 { get set }
}

protocol HasOdometerReadings {
    var odometerReadings: Set<OdometerReading> { get }
}

let daysPerYear: Double = 365.2425
let hoursPerDay: Double = 24
let secondsPerHour: Double = 3600

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
        if let averageMilesPerSecond = averageMilesPerSecond {
            guard let lastOdometerReading = odometerReadings.inverseChrono.first(where: { $0.at != nil }) else {
                return 0
            }
            let timeSinceLastOdometer = Date.now.timeIntervalSinceReferenceDate -
                lastOdometerReading.at!.timeIntervalSinceReferenceDate
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

protocol HasRawWarranties {
    var warrantiesNs: NSSet? { get }
    func addToWarrantiesNs(_ value: Warranty)
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