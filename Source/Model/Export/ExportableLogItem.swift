//
//  ExportableLogItem.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

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
