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

struct ExportableLineItem: Codable {
    let notes: String?
    let sortOrder: Int16
    let typeId: String
    let fields: [ExportableLineItemField]

    init(context: ExportContext, lineItem: LineItem) {
        notes = lineItem.notes
        sortOrder = lineItem.sortOrder
        typeId = lineItem.typeId ?? "misc"
        fields = lineItem.fields.map {
            ExportableLineItemField(context: context, lineItemField: $0)
        }
    }

    func importLineItem(context: NSManagedObjectContext, exportContext: ExportContext, logItem: LogItem) -> LineItem {
        let lineItem = LineItem(context: context, logItem: logItem)
        lineItem.notes = notes
        lineItem.sortOrder = sortOrder
        lineItem.typeId = typeId
        for field in fields {
            _ = field.importLineItemField(
                context: context,
                exportContext: exportContext,
                lineItem: lineItem
            )
        }
        return lineItem
    }
}
