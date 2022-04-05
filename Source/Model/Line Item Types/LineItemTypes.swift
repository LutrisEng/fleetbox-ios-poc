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

// swiftlint:disable:next force_try
let lineItemTypes = try! LineItemTypes()
let lineItemDefaultIcon = "wrench.and.screwdriver"

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
        let exampleInteger: Int?
        let defaultValue: String?
        let defaultValueFrom: String?
        let unit: String?
    }

    struct YamlIcon: Codable {
        let sfsymbols: String?
    }

    struct YamlType: Codable {
        let id: String
        let displayName: String
        let description: String?
        let replaces: String?
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

    struct YamlComponent: Codable {
        let id: String
        let name: String
        let filter: String?
    }

    struct YamlContents: Codable {
        let categories: [YamlCategory]
        let components: [YamlComponent]
    }

    private let filePath = Bundle.main.url(forResource: "LineItemTypes", withExtension: "json")!
    private let decoder = JSONDecoder()
    private let yamlContents: YamlContents
    let topLevelCategories: [LineItemTypeCategory]
    let allCategories: [LineItemTypeCategory]
    let allTypes: [LineItemType]
    let allCategoriesById: [String: LineItemTypeCategory]
    let allTypesById: [String: LineItemType]
    let allComponents: [LineItemTypeComponent]
    let allComponentsById: [String: LineItemTypeComponent]
    let hierarchyItems: [LineItemTypeHierarchyItem]

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
        allComponents = yamlContents.components.map {
            LineItemTypeComponent(yaml: $0)
        }
        var componentsById: [String: LineItemTypeComponent] = [:]
        for component in allComponents {
            componentsById[component.id] = component
        }
        allComponentsById = componentsById
        hierarchyItems = topLevelCategories.map { LineItemTypeHierarchyItem.category($0) }
    }

    func search(query: String) -> [LineItemTypeHierarchyItem] {
        let lowercaseQuery = query.lowercased()
        let matchingCategories = allCategories.filter {
            $0.displayName.lowercased().contains(lowercaseQuery)
        }
        let matchingTypes = allTypes.filter {
            $0.displayName.lowercased().contains(lowercaseQuery) ||
            $0.description?.lowercased().contains(lowercaseQuery) == true
        }
        var foundCategories = Set<String>()
        var foundTypes = Set<String>()
        for category in matchingCategories {
            foundCategories.insert(category.id)
            var maybeParent = category.parent
            while let parent = maybeParent {
                foundCategories.insert(parent.id)
                maybeParent = parent.parent
            }
        }
        for type in matchingTypes {
            foundTypes.insert(type.id)
            var maybeParent: LineItemTypeCategory? = type.category
            while let parent = maybeParent {
                foundCategories.insert(parent.id)
                maybeParent = parent.parent
            }
        }
        return topLevelCategories
            .filter({ foundCategories.contains($0.id) })
            .map {
                LineItemTypeHierarchyItem.category(
                    $0,
                    allowedCategories: foundCategories,
                    allowedTypes: foundTypes
                )
            }
    }

    private static func walk(
            categories inputCategories: [LineItemTypeCategory]
    ) -> ([LineItemTypeCategory], [LineItemType]) {
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

    private static func walk(
        category: LineItemTypeCategory
    ) -> ([LineItemTypeCategory], [LineItemType]) {
        var (categories, types) = walk(categories: category.subcategories)
        for type in category.types {
            types.append(type)
        }
        return (categories, types)
    }
}
