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

struct ExportableLogItem: Codable {
    let displayName: String?
    let performedAt: Date?
    let lineItems: [ExportableLineItem]
    let odometerReading: ExportableOdometerReading?
    let shop: Int?
    let attachments: [ExportableAttachment]

    init(context: ExportContext, logItem: LogItem) {
        displayName = logItem.displayName
        performedAt = logItem.performedAt
        lineItems = logItem.lineItems.map {
            ExportableLineItem(context: context, lineItem: $0)
        }
        if let odometerReading = logItem.odometerReading {
            self.odometerReading = ExportableOdometerReading(odometerReading: odometerReading)
        } else {
            odometerReading = nil
        }
        if let shop = logItem.shop {
            if let idx = context.shops.firstIndex(of: shop) {
                self.shop = idx
            } else {
                self.shop = context.shops.count
                context.shops.append(shop)
            }
        } else {
            shop = nil
        }
        attachments = logItem.attachments.map {
            ExportableAttachment(attachment: $0)
        }
    }

    func importLogItem(context: NSManagedObjectContext, exportContext: ExportContext, vehicle: Vehicle) -> LogItem {
        let logItem = LogItem(context: context)
        logItem.vehicle = vehicle
        logItem.displayName = displayName
        logItem.performedAt = performedAt
        for lineItem in lineItems {
            _ = lineItem.importLineItem(
                context: context,
                exportContext: exportContext,
                logItem: logItem
            )
        }
        if let odometerReading = odometerReading {
            _ = odometerReading.importOdometerReading(context: context, logItem: logItem)
        }
        if let shop = shop {
            logItem.shop = exportContext.shops[shop]
        }
        for attachment in attachments {
            let obj = attachment.importAttachment(context: context)
            obj.logItem = logItem

        }
        return logItem
    }
}
