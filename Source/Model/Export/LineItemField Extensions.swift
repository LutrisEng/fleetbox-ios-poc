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

extension Fleetbox_Export_LineItemField {
    init(envelope: ExportEnvelopeTemplate, settings: ExportSettings, lineItemField: LineItemField) {
        if let typeID = lineItemField.typeId {
            self.typeID = typeID
        }
        if let stringValue = lineItemField.stringValue {
            self.stringValue = stringValue
        }
        if let tireSet = lineItemField.tireSetValue {
            if let idx = envelope.tireSets.firstIndex(of: tireSet) {
                tireSetValue = Int64(idx)
            } else {
                tireSetValue = Int64(envelope.tireSets.count)
                envelope.tireSets.append(tireSet)
            }
        }
        integerValue = lineItemField.integerValue
    }

    func importLineItemField(
        context: NSManagedObjectContext,
        envelope: ExportEnvelopeTemplate,
        lineItem: LineItem
    ) -> LineItemField {
        let field = LineItemField(context: context)
        field.lineItem = lineItem
        field.typeId = typeID
        field.stringValue = stringValue
        if hasTireSetValue {
            field.tireSetValue = envelope.tireSets[Int(tireSetValue)]
        }
        if hasIntegerValue {
            field.integerValue = integerValue
        }
        return field
    }
}
