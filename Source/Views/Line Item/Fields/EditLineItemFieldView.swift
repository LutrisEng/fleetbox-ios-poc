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

import SwiftUI
import CoreData
import Sentry

struct EditLineItemFieldView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var field: LineItemField

    var body: some View {
        if let type = field.type {
            Section(header: Text(type.longDisplayName)) {
                switch type.type {
                case .string:
                    FleetboxTextField(
                            value: $field.stringValue,
                            name: type.shortDisplayNameLocal,
                            example: type.example
                    )
                case .enumeration:
                    Picker(type.shortDisplayNameLocal, selection: convertToNonNilBinding(string: $field.stringValue)) {
                        ForEach(type.enumValues) { val in
                            VStack {
                                Text(val.displayName)
                                if let description = val.description {
                                    Text(description).font(.caption)
                                }
                            }
                        }
                    }
                case .tireSet: EditTireSetLineItemFieldView(field: field, type: type)
                case .boolean:
                    HStack {
                        Button(type.booleanFormat.unsetFormat) {
                            field.stringValue = nil
                        }
                            .foregroundColor(
                                field.stringValue == nil ? .accentColor : .secondary
                            )
                            .buttonStyle(BorderlessButtonStyle())
                            .frame(maxWidth: .infinity)
                        Button(type.booleanFormat.trueFormat) {
                            field.stringValue = "true"
                        }
                            .foregroundColor(
                                field.stringValue == "true" ? .green : .secondary
                            )
                            .buttonStyle(BorderlessButtonStyle())
                            .frame(maxWidth: .infinity)
                        Button(type.booleanFormat.falseFormat) {
                            field.stringValue = "false"
                        }
                            .foregroundColor(
                                field.stringValue == "false" ? .red : .secondary
                            )
                            .buttonStyle(BorderlessButtonStyle())
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }
}
