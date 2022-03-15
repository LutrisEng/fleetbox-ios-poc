//
//  ExportableLineItemField.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import CoreData

struct ExportableLineItemField: Codable {
    let typeId: String?
    let stringValue: String?
    let tireSetValue: Int?

    init(context: ExportContext, lineItemField: LineItemField) {
        typeId = lineItemField.typeId
        stringValue = lineItemField.stringValue
        if let tireSet = lineItemField.tireSetValue {
            if let idx = context.tireSets.firstIndex(of: tireSet) {
                tireSetValue = idx
            } else {
                tireSetValue = context.tireSets.count
                context.tireSets.append(tireSet)
            }
        } else {
            tireSetValue = nil
        }
    }

    func importLineItemField(
        context: NSManagedObjectContext,
        exportContext: ExportContext,
        lineItem: LineItem
    ) -> LineItemField {
        let field = LineItemField(context: context)
        field.lineItem = lineItem
        field.typeId = typeId
        field.stringValue = stringValue
        if let tireSetValue = tireSetValue {
            field.tireSetValue = exportContext.tireSets[tireSetValue]
        }
        return field
    }
}
