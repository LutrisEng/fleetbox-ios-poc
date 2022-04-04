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

import CoreData

extension Fleetbox_Export_LineItem {
    init(envelope: ExportEnvelopeTemplate, settings: ExportSettings, lineItem: LineItem) {
        if let notes = lineItem.notes {
            self.notes = notes
        }
        typeID = lineItem.typeId ?? "misc"
        fields = lineItem.fields.map {
            Fleetbox_Export_LineItemField(envelope: envelope, settings: settings, lineItemField: $0)
        }
    }

    func importLineItem(
        context: NSManagedObjectContext,
        envelope: ExportEnvelopeTemplate,
        index: Int,
        logItem: LogItem
    ) -> LineItem {
        let lineItem = LineItem(context: context, logItem: logItem)
        lineItem.notes = notes
        lineItem.sortOrder = Int16(index)
        lineItem.typeId = typeID
        for field in fields {
            _ = field.importLineItemField(
                context: context,
                envelope: envelope,
                lineItem: lineItem
            )
        }
        return lineItem
    }
}
