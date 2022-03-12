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
    let shop: String?
    let attachments: [ExportableAttachment]

    init(logItem: LogItem) {
        self.displayName = logItem.displayName
        self.performedAt = logItem.performedAt
        self.lineItems = logItem.lineItems.map {
            ExportableLineItem(lineItem: $0)
        }
        if let odometerReading = logItem.odometerReading {
            self.odometerReading = ExportableOdometerReading(odometerReading: odometerReading)
        } else {
            self.odometerReading = nil
        }
        self.shop = logItem.shop?.name
        self.attachments = logItem.attachments.map {
            ExportableAttachment(attachment: $0)
        }
    }

    func importLogItem(context: NSManagedObjectContext, vehicle: Vehicle) -> LogItem {
        let logItem = LogItem(context: context)
        logItem.vehicle = vehicle
        logItem.displayName = displayName
        logItem.performedAt = performedAt
        for lineItem in lineItems {
            _ = lineItem.importLineItem(context: context, logItem: logItem)
        }
        if let odometerReading = odometerReading {
            _ = odometerReading.importOdometerReading(context: context, logItem: logItem)
        }
        // TODO: shop
        for attachment in attachments {
            let obj = attachment.importAttachment(context: context)
            obj.logItem = logItem

        }
        return logItem
    }
}
