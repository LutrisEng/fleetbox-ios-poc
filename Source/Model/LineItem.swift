//
//  LineItem.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/2/22.
//

import Foundation
import CoreData

enum FieldValue {
    case string(String)
    case tireSet(TireSet)
    case boolean(Bool)
}

enum FieldValueError: Error {
    case invalidField
    case invalidType(expected: LineItemTypeFieldType, received: LineItemTypeFieldType)
}

extension LineItem {
    convenience init(context: NSManagedObjectContext, logItem: LogItem) {
        self.init(context: context)
        self.logItem = logItem
        self.sortOrder = logItem.nextLineItemSortOrder
    }
    
    var type: LineItemType? {
        get {
            guard let typeId = self.typeId else {
                return nil
            }
            return (lineItemTypes.allTypesById[typeId] ?? lineItemTypes.allTypesById["misc"])!
        }
        
        set {
            self.typeId = newValue?.id
        }
    }
    
    var fieldSet: Set<LineItemField> {
        return fieldsNs as? Set<LineItemField> ?? []
    }
    
    func getFields(create: Bool = false) -> [LineItemField] {
        guard let type = type else { return [] }
        var fields: [LineItemField] = []
        for fieldType in type.fields {
            fields.append(getField(id: fieldType.id, create: create))
        }
        return fields
    }
    
    var fields: [LineItemField] {
        getFields(create: false)
    }
    
    var allFields: [LineItemField] {
        getFields(create: true)
    }
    
    func getFieldValue(_ id: String) throws -> FieldValue? {
        guard let field = (fields.first { $0.typeId == id }) else {
            throw FieldValueError.invalidField
        }
        guard let fieldType = field.type else {
            throw FieldValueError.invalidField
        }
        switch fieldType.type {
        case .string, .enumeration:
            guard let value = field.stringValue else {
                return nil
            }
            return .string(value)
        case .tireSet:
            guard let value = field.tireSetValue else {
                return nil
            }
            return .tireSet(value)
        case .boolean:
            return .boolean(field.booleanValue)
        }
    }
    
    func getFieldValueString(_ id: String) throws -> String? {
        guard let value = try getFieldValue(id) else {
            return nil
        }
        switch value {
        case .string(let v): return v
        case .tireSet: throw FieldValueError.invalidType(expected: .string, received: .tireSet)
        case .boolean: throw FieldValueError.invalidType(expected: .string, received: .boolean)
        }
    }
    
    func getFieldValueTireSet(_ id: String) throws -> TireSet? {
        guard let value = try getFieldValue(id) else {
            return nil
        }
        switch value {
        case .tireSet(let v): return v
        case .string: throw FieldValueError.invalidType(expected: .tireSet, received: .string)
        case .boolean: throw FieldValueError.invalidType(expected: .tireSet, received: .boolean)
        }
    }
    
    func getFieldValueBoolean(_ id: String) throws -> Bool? {
        guard let value = try getFieldValue(id) else {
            return nil
        }
        switch value {
        case .boolean(let v): return v
        case .string: throw FieldValueError.invalidType(expected: .boolean, received: .string)
        case .tireSet: throw FieldValueError.invalidType(expected: .boolean, received: .tireSet)
        }
    }
    
    func getField(id: String, create: Bool = true) -> LineItemField {
        if let field = fieldSet.first(where: { $0.typeId == id }) {
            return field
        } else {
            let field = LineItemField(context: managedObjectContext!)
            field.typeId = id
            field.lineItem = self
            field.setDefaultValue(vehicle: logItem?.vehicle)
            return field
        }
    }
    
    func setFieldValue(_ id: String, value: String) throws {
        let field = getField(id: id)
        guard let fieldType = field.type else {
            throw FieldValueError.invalidField
        }
        switch fieldType.type {
        case .string, .enumeration:
            field.stringValue = value
        default:
            throw FieldValueError.invalidType(expected: fieldType.type, received: .string)
        }
    }
    
    func setFieldValue(_ id: String, value: TireSet) throws {
        let field = getField(id: id)
        guard let fieldType = field.type else {
            return
        }
        switch fieldType.type {
        case .tireSet:
            field.tireSetValue = value
        default:
            throw FieldValueError.invalidType(expected: fieldType.type, received: .tireSet)
        }
    }
    
    func setFieldValue(_ id: String, value: Bool) throws {
        let field = getField(id: id)
        guard let fieldType = field.type else {
            return
        }
        switch fieldType.type {
        case .boolean:
            field.booleanValue = value
        default:
            throw FieldValueError.invalidType(expected: fieldType.type, received: .boolean)
        }
    }
    
    func setFieldValue(_ id: String, value: FieldValue) throws {
        switch value {
        case .string(let v): try setFieldValue(id, value: v)
        case .tireSet(let v): try setFieldValue(id, value: v)
        case .boolean(let v): try setFieldValue(id, value: v)
        }
    }
    
    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        logItem?.objectWillChange.send()
        logItem?.vehicle?.objectWillChange.send()
    }
}
