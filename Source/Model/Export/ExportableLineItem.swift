//
//  ExportableLineItem.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import CoreData

struct ExportableLineItem: Codable {
    let notes: String?
    let sortOrder: Int16
    let typeId: String
    let fields: [ExportableLineItemField]

    init(lineItem: LineItem) {
        notes = lineItem.notes
        sortOrder = lineItem.sortOrder
        typeId = lineItem.typeId ?? "misc"
        fields = lineItem.fields.map {
            ExportableLineItemField(lineItemField: $0)
        }
    }

    func importLineItem(context: NSManagedObjectContext, logItem: LogItem) -> LineItem {
        let lineItem = LineItem(context: context, logItem: logItem)
        lineItem.notes = notes
        lineItem.sortOrder = sortOrder
        lineItem.typeId = typeId
        for field in fields {
            _ = field.importLineItemField(context: context, lineItem: lineItem)
        }
        return lineItem
    }
}
