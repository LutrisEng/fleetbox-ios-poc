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

import CoreData

extension Fleetbox_Export_LogItem {
    init(envelope: ExportEnvelopeTemplate, settings: ExportSettings, logItem: LogItem) {
        if let displayName = logItem.displayName {
            self.displayName = displayName
        }
        if let performedAt = logItem.performedAt {
            self.performedAt = Int64(performedAt.timeIntervalSince1970)
        }
        lineItems = logItem.lineItems.map {
            Fleetbox_Export_LineItem(envelope: envelope, settings: settings, lineItem: $0)
        }
        if let odometerReading = logItem.odometerReading {
            self.odometerReading = odometerReading.reading
        }
        if let shop = logItem.shop {
            if let idx = envelope.shops.firstIndex(of: shop) {
                self.shop = Int64(idx)
            } else {
                self.shop = Int64(envelope.shops.count)
                envelope.shops.append(shop)
            }
        }
        if settings.includeAttachments {
            attachments = logItem.attachments.map {
                Fleetbox_Export_Attachment(settings: settings, attachment: $0)
            }
        }
        includeTime = logItem.includeTime
    }

    func importLogItem(
        context: NSManagedObjectContext,
        envelope: ExportEnvelopeTemplate,
        vehicle: Vehicle
    ) -> LogItem {
        let logItem = LogItem(context: context)
        logItem.vehicle = vehicle
        logItem.displayName = displayName
        if hasPerformedAt {
            logItem.performedAt = Date(timeIntervalSince1970: TimeInterval(performedAt))
        }
        for (index, lineItem) in lineItems.enumerated() {
            _ = lineItem.importLineItem(
                context: context,
                envelope: envelope,
                index: index,
                logItem: logItem
            )
        }
        if hasOdometerReading {
            let odometerReading = OdometerReading(context: context, logItem: logItem)
            odometerReading.reading = Int64(self.odometerReading)
        }
        if hasShop {
            logItem.shop = envelope.shops[Int(shop)]
        }
        for (index, attachment) in attachments.enumerated() {
            let obj = attachment.importAttachment(context: context, index: index)
            obj.logItem = logItem
        }
        logItem.includeTime = includeTime
        return logItem
    }
}
