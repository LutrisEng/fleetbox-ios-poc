//
//  ExportableLineItemField.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import CoreData

struct ExportableLineItemField : Codable {
    let typeId: String?
    let stringValue: String?
    let booleanValue: Bool
    // TODO: tire sets
    
    init(lineItemField: LineItemField) {
        self.typeId = lineItemField.typeId
        self.stringValue = lineItemField.stringValue
        self.booleanValue = lineItemField.booleanValue
    }
    
    func importLineItemField(context: NSManagedObjectContext, lineItem: LineItem) -> LineItemField {
        let field = LineItemField(context: context)
        field.lineItem = lineItem
        field.typeId = typeId
        field.stringValue = stringValue
        field.booleanValue = booleanValue
        return field
    }
}
