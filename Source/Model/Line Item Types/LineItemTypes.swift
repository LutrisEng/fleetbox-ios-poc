//
//  LineItemTypes.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/5/22.
//

import Foundation
import SwiftUI

// swiftlint:disable:next force_try
let lineItemTypes = try! LineItemTypes()
let lineItemDefaultIcon = "wrench.and.screwdriver"

enum LineItemTypesParseError: Error {
    case invalidFieldType(statedType: String)
}

enum LineItemTypeFieldType {
    case string, tireSet, enumeration, boolean
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
    let defaultValue: String?
    let defaultValueFrom: LineItemTypeFetcher?

    // swiftlint:disable:next cyclomatic_complexity
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
        defaultValue = yaml.defaultValue
        switch yaml.defaultValueFrom {
        case "vehicle.make": defaultValueFrom = .vehicleMake
        case "vehicle.registrationState": defaultValueFrom = .vehicleRegistrationState
        case "vehicle.oilViscosity": defaultValueFrom = .vehicleOilViscosity
        case "vehicle.currentTires": defaultValueFrom = .vehicleCurrentTires
        default: defaultValueFrom = nil
        }
    }
}

class LineItemType: Identifiable {
    let id: String
    let category: LineItemTypeCategory
    let categoryPath: [String]
    let displayName: String
    let description: String?
    let definedIcon: String?
    var icon: String {
        definedIcon ?? category.icon
    }
    let fields: [LineItemTypeField]
    let fieldsById: [String: LineItemTypeField]

    init(category: LineItemTypeCategory, categoryPath: [String], yaml: LineItemTypes.YamlType) throws {
        self.id = yaml.id
        self.category = category
        self.categoryPath = categoryPath
        displayName = yaml.displayName
        description = yaml.description
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
    let displayName: String
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
    case category(LineItemTypeCategory)

    var id: String {
        switch self {
        case .type(let type): return "type:\(type.id)"
        case .category(let category): return "category:\(category.id)"
        }
    }

    var children: [LineItemTypeHierarchyItem]? {
        switch self {
        case .type: return nil
        case .category(let category):
            var vals = category.types.map(LineItemTypeHierarchyItem.type)
            vals.append(contentsOf: category.subcategories.map(LineItemTypeHierarchyItem.category))
            return vals
        }
    }
}

struct LineItemTypes {
    struct YamlEnumValue: Codable {
        let id: String
        let displayName: String
        let description: String?
    }

    struct YamlBooleanFormat: Codable {
        let unsetFormat: String?
        let trueFormat: String?
        let falseFormat: String?

        // swiftlint:disable:next nesting
        enum CodingKeys: String, CodingKey {
            case unsetFormat = "unset"
            case trueFormat = "true"
            case falseFormat = "false"
        }
    }

    struct YamlField: Codable {
        let id: String
        let shortDisplayName: String
        let longDisplayName: String
        let type: String
        let booleanFormat: YamlBooleanFormat?
        let enumValues: [YamlEnumValue]?
        let example: String?
        let defaultValue: String?
        let defaultValueFrom: String?
    }

    struct YamlIcon: Codable {
        let sfsymbols: String?
    }

    struct YamlType: Codable {
        let id: String
        let displayName: String
        let description: String?
        let icon: YamlIcon?
        let fields: [YamlField]?
    }

    struct YamlCategory: Codable {
        let id: String
        let displayName: String
        let icon: YamlIcon?
        let subcategories: [YamlCategory]?
        let types: [YamlType]?
    }

    struct YamlContents: Codable {
        let categories: [YamlCategory]
    }

    private let filePath = Bundle.main.url(forResource: "LineItemTypes", withExtension: "json")!
    private let decoder = JSONDecoder()
    private let yamlContents: YamlContents
    public let topLevelCategories: [LineItemTypeCategory]
    public let allCategories: [LineItemTypeCategory]
    public let allTypes: [LineItemType]
    public let allCategoriesById: [String: LineItemTypeCategory]
    public let allTypesById: [String: LineItemType]
    public let hierarchyItems: [LineItemTypeHierarchyItem]

    init() throws {
        yamlContents = try decoder.decode(YamlContents.self, from: try Data(contentsOf: filePath))
        topLevelCategories = try yamlContents.categories.map {
            try LineItemTypeCategory(categoryPath: [], yaml: $0)
        }
        (allCategories, allTypes) = LineItemTypes.walk(categories: topLevelCategories)
        var categoriesById: [String: LineItemTypeCategory] = [:]
        for category in allCategories {
            categoriesById[category.id] = category
        }
        allCategoriesById = categoriesById
        var typesById: [String: LineItemType] = [:]
        for type in allTypes {
            typesById[type.id] = type
        }
        allTypesById = typesById
        hierarchyItems = topLevelCategories.map(LineItemTypeHierarchyItem.category)
    }

    private static func walk(
            categories inputCategories: [LineItemTypeCategory]) -> ([LineItemTypeCategory], [LineItemType]
    ) {
        var categories: [LineItemTypeCategory] = []
        var types: [LineItemType] = []
        for category in inputCategories {
            categories.append(category)
            let (newCategories, newTypes) = walk(category: category)
            categories.append(contentsOf: newCategories)
            types.append(contentsOf: newTypes)
        }
        return (categories, types)
    }

    private static func walk(category: LineItemTypeCategory) -> ([LineItemTypeCategory], [LineItemType]) {
        var (categories, types) = walk(categories: category.subcategories)
        for type in category.types {
            types.append(type)
        }
        return (categories, types)
    }
}
