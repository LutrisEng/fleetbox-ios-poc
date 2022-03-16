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
