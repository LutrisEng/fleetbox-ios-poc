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
import SwiftUI

enum LineItemTypesParseError: Error {
    case invalidFieldType(statedType: String)
}

enum LineItemTypeFieldType {
    case string, tireSet, enumeration, boolean, integer
}

struct LineItemTypeEnumValue: Identifiable {
    let id: String
    let displayName: String
    let description: String?

    init(yaml: LineItemTypes.YamlEnumValue) {
        id = yaml.id
        displayName = yaml.displayName
        description = yaml.description
    }
}

struct LineItemTypeBooleanFormat {
    let unsetFormat: String
    let trueFormat: String
    let falseFormat: String

    static let defaultFormat = LineItemTypeBooleanFormat(unsetFormat: "Unknown", trueFormat: "Yes", falseFormat: "No")
}

enum LineItemTypeFetcher {
    case vehicleMake, vehicleRegistrationState, vehicleOilViscosity, vehicleCurrentTires
}

class LineItemTypeField: Identifiable {
    let id: String
    let shortDisplayName: String
    let shortDisplayNameLocal: LocalizedStringKey
    let longDisplayName: String
    let longDisplayNameLocal: LocalizedStringKey
    let type: LineItemTypeFieldType
    let booleanFormat: LineItemTypeBooleanFormat
    let enumValues: [LineItemTypeEnumValue]
    let enumValuesById: [String: LineItemTypeEnumValue]
    let example: String?
    let exampleInteger: Int64?
    let defaultValue: String?
    let defaultValueFrom: LineItemTypeFetcher?
    let unit: String?
    let unitLocal: LocalizedStringKey?

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    init(yaml: LineItemTypes.YamlField) throws {
        id = yaml.id
        shortDisplayName = yaml.shortDisplayName
        shortDisplayNameLocal = LocalizedStringKey(shortDisplayName)
        longDisplayName = yaml.longDisplayName
        longDisplayNameLocal = LocalizedStringKey(longDisplayName)
        switch yaml.type {
        case "string": type = .string
        case "tireSet": type = .tireSet
        case "enum": type = .enumeration
        case "boolean": type = .boolean
        case "integer": type = .integer
        default: throw LineItemTypesParseError.invalidFieldType(statedType: yaml.type)
        }
        if let booleanFormat = yaml.booleanFormat {
            self.booleanFormat = LineItemTypeBooleanFormat(
                unsetFormat: booleanFormat.unsetFormat ?? LineItemTypeBooleanFormat.defaultFormat.unsetFormat,
                trueFormat: booleanFormat.trueFormat ?? LineItemTypeBooleanFormat.defaultFormat.trueFormat,
                falseFormat: booleanFormat.falseFormat ?? LineItemTypeBooleanFormat.defaultFormat.falseFormat
            )
        } else {
            booleanFormat = LineItemTypeBooleanFormat.defaultFormat
        }
        self.enumValues = (yaml.enumValues ?? []).map { LineItemTypeEnumValue(yaml: $0) }
        var enumValuesById: [String: LineItemTypeEnumValue] = [:]
        for enumValue in enumValues {
            enumValuesById[enumValue.id] = enumValue
        }
        self.enumValuesById = enumValuesById
        example = yaml.example
        if let exampleInteger = yaml.exampleInteger {
            self.exampleInteger = Int64(exampleInteger)
        } else {
            exampleInteger = nil
        }
        defaultValue = yaml.defaultValue
        switch yaml.defaultValueFrom {
        case "vehicle.make": defaultValueFrom = .vehicleMake
        case "vehicle.registrationState": defaultValueFrom = .vehicleRegistrationState
        case "vehicle.oilViscosity": defaultValueFrom = .vehicleOilViscosity
        case "vehicle.currentTires": defaultValueFrom = .vehicleCurrentTires
        default: defaultValueFrom = nil
        }
        unit = yaml.unit
        if let unit = unit {
            unitLocal = LocalizedStringKey(unit)
        } else {
            unitLocal = nil
        }
    }
}

class LineItemType: Identifiable {
    let id: String
    let category: LineItemTypeCategory
    let categoryPath: [String]
    dynamic let displayName: String
    dynamic let description: String?
    let replaces: String?
    let definedIcon: String?
    var icon: String {
        definedIcon ?? category.icon
    }
    let fields: [LineItemTypeField]
    let fieldsById: [String: LineItemTypeField]

    init(category: LineItemTypeCategory, categoryPath: [String], yaml: LineItemTypes.YamlType) throws {
        id = yaml.id
        self.category = category
        self.categoryPath = categoryPath
        displayName = yaml.displayName
        description = yaml.description
        replaces = yaml.replaces
        definedIcon = yaml.icon?.sfsymbols
        fields = try (yaml.fields ?? []).map { try LineItemTypeField(yaml: $0) }
        var fieldsById: [String: LineItemTypeField] = [:]
        for field in fields {
            fieldsById[field.id] = field
        }
        self.fieldsById = fieldsById
    }
}

class LineItemTypeCategory: Identifiable {
    let id: String
    let parent: LineItemTypeCategory?
    let categoryPath: [String]
    dynamic let displayName: String
    let definedIcon: String?
    var icon: String {
        definedIcon ?? parent?.icon ?? lineItemDefaultIcon
    }
    var types: [LineItemType] = []
    var subcategories: [LineItemTypeCategory] = []

    init(
            parent: LineItemTypeCategory? = nil,
            categoryPath: [String],
            yaml: LineItemTypes.YamlCategory
    ) throws {
        self.id = yaml.id
        self.parent = parent
        self.categoryPath = categoryPath
        var childCategoryPath = categoryPath
        childCategoryPath.append(id)
        displayName = yaml.displayName
        definedIcon = yaml.icon?.sfsymbols
        types = try (yaml.types ?? []).map {
            try LineItemType(category: self, categoryPath: childCategoryPath, yaml: $0 )
        }
        subcategories = try (yaml.subcategories ?? []).map {
            try LineItemTypeCategory(
                    parent: self,
                    categoryPath: childCategoryPath,
                    yaml: $0
            )
        }
    }
}

enum LineItemTypeHierarchyItem: Identifiable {
    case type(LineItemType)
    case category(
        LineItemTypeCategory,
        allowedCategories: Set<String>? = nil,
        allowedTypes: Set<String>? = nil
    )

    var id: String {
        switch self {
        case .type(let type): return "type:\(type.id)"
        case .category(let category, _, _): return "category:\(category.id)"
        }
    }

    func allowed(category: LineItemTypeCategory) -> Bool {
        switch self {
        case .category(_, let allowedCategories, _):
            if let allowedCategories = allowedCategories {
                return allowedCategories.contains(category.id)
            } else {
                return true
            }
        default: return true
        }
    }

    func allowed(type: LineItemType) -> Bool {
        switch self {
        case .category(_, _, let allowedTypes):
            if let allowedTypes = allowedTypes {
                return allowedTypes.contains(type.id)
            } else {
                return true
            }
        default: return true
        }
    }

    var children: [LineItemTypeHierarchyItem]? {
        switch self {
        case .type: return nil
        case .category(let category, let allowedCategories, let allowedTypes):
            var vals = category.types
                .filter(allowed)
                .map(LineItemTypeHierarchyItem.type)
            vals.append(
                contentsOf:
                    category.subcategories
                        .filter(allowed)
                        .map {
                            LineItemTypeHierarchyItem.category(
                                $0,
                                allowedCategories: allowedCategories,
                                allowedTypes: allowedTypes
                            )
                        }
            )
            return vals
        }
    }
}

class LineItemTypeComponent {
    let id: String
    let name: LocalizedStringKey
    let filter: String?

    init(yaml: LineItemTypes.YamlComponent) {
        id = yaml.id
        name = LocalizedStringKey(yaml.name)
        filter = yaml.filter
    }
}
