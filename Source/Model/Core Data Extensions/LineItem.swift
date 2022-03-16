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
        sortOrder = logItem.nextLineItemSortOrder
    }

    var type: LineItemType? {
        get {
            guard let typeId = typeId else {
                return nil
            }
            return (lineItemTypes.allTypesById[typeId] ?? lineItemTypes.allTypesById["misc"])!
        }

        set {
            typeId = newValue?.id
        }
    }

    var fieldSet: Set<LineItemField> {
        fieldsNs as? Set<LineItemField> ?? []
    }

    func getFields(create: Bool = false) -> [LineItemField] {
        guard let type = type else {
            return []
        }
        var fields: [LineItemField] = []
        for fieldType in type.fields {
            if create {
                fields.append(getField(id: fieldType.id))
            } else {
                if let field = getFieldWithoutCreating(id: fieldType.id) {
                    fields.append(field)
                }
            }
        }
        return fields
    }

    func createMissingFields() {
        _ = getFields(create: true)
    }

    var fields: [LineItemField] {
        getFields(create: false)
    }

    func getFieldValue(_ id: String) throws -> FieldValue? {
        guard let field = (fields.first {
            $0.typeId == id
        }) else {
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
            switch field.stringValue {
            case "true": return .boolean(true)
            case "false": return .boolean(false)
            default: return nil
            }
        }
    }

    func getFieldValueString(_ id: String) throws -> String? {
        guard let value = try getFieldValue(id) else {
            return nil
        }
        switch value {
        case .string(let value): return value
        case .tireSet: throw FieldValueError.invalidType(expected: .string, received: .tireSet)
        case .boolean: throw FieldValueError.invalidType(expected: .string, received: .boolean)
        }
    }

    func getFieldValueTireSet(_ id: String) throws -> TireSet? {
        guard let value = try getFieldValue(id) else {
            return nil
        }
        switch value {
        case .tireSet(let value): return value
        case .string: throw FieldValueError.invalidType(expected: .tireSet, received: .string)
        case .boolean: throw FieldValueError.invalidType(expected: .tireSet, received: .boolean)
        }
    }

    func getFieldValueBoolean(_ id: String) throws -> Bool? {
        guard let value = try getFieldValue(id) else {
            return nil
        }
        switch value {
        case .boolean(let value): return value
        case .string: throw FieldValueError.invalidType(expected: .boolean, received: .string)
        case .tireSet: throw FieldValueError.invalidType(expected: .boolean, received: .tireSet)
        }
    }

    func getFieldWithoutCreating(id: String) -> LineItemField? {
        return fieldSet.first(where: { $0.typeId == id })
    }

    func getField(id: String) -> LineItemField {
        if let field = getFieldWithoutCreating(id: id) {
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

    func setFieldValue(_ id: String, value: Bool?) throws {
        let field = getField(id: id)
        guard let fieldType = field.type else {
            return
        }
        switch fieldType.type {
        case .boolean:
            switch value {
            case true: field.stringValue = "true"
            case false: field.stringValue = "false"
            default: field.stringValue = nil
            }
        default:
            throw FieldValueError.invalidType(expected: fieldType.type, received: .boolean)
        }
    }

    func setFieldValue(_ id: String, value: FieldValue?) throws {
        switch value {
        case nil:
            let field = getField(id: id)
            field.stringValue = nil
            field.tireSetValue = nil
        case .string(let value): try setFieldValue(id, value: value)
        case .tireSet(let value): try setFieldValue(id, value: value)
        case .boolean(let value): try setFieldValue(id, value: value)
        }
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        logItem?.objectWillChange.send()
        logItem?.vehicle?.objectWillChange.send()
    }
}
