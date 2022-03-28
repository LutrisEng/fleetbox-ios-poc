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

    @State private var showInfo: Bool = false

    @ViewBuilder func infoButton(type: LineItemTypeField) -> some View {
        Button(
            action: { withAnimation { showInfo.toggle() } },
            label: { Image(systemName: "info.circle") }
        )
        .buttonStyle(.plain)
        .foregroundColor(.accentColor)
    }

    @ViewBuilder func info(type: LineItemTypeField, alignment: Alignment = .trailing) -> some View {
        Text(type.longDisplayName)
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: alignment)
            .padding([.top, .bottom], 1.5)
    }

    var showInfoButton: Bool {
        if let type = field.type {
            return type.type != .string && type.type != .integer && type.type != .boolean
        } else {
            return true
        }
    }

    var body: some View {
        if let type = field.type {
            VStack {
                HStack {
                    switch type.type {
                    case .string:
                        FleetboxTextField(
                                value: $field.stringValue,
                                name: type.shortDisplayNameLocal,
                                example: type.example,
                                description: type.longDisplayNameLocal
                        )
                    case .integer:
                        let textField = FleetboxTextField(
                            value: $field.integerValue,
                            name: type.shortDisplayNameLocal,
                            example: type.exampleInteger ?? 0,
                            description: type.longDisplayNameLocal
                        )
                        if let unit = type.unitLocal {
                            textField.unit(unit)
                        } else {
                            textField
                        }
                    case .enumeration:
                        Picker(
                            type.shortDisplayNameLocal,
                            selection: convertToNonNilBinding(string: $field.stringValue)
                        ) {
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
                        VStack {
                            HStack {
                                Text(type.shortDisplayNameLocal)
                                Spacer()
                                infoButton(type: type)
                            }
                            if showInfo {
                                info(type: type, alignment: .leading)
                            }
                            Picker(
                                type.shortDisplayNameLocal,
                                selection: $field.stringValue as Binding<String?>
                            ) {
                                Text(type.booleanFormat.unsetFormat).tag(nil as String?)
                                Text(type.booleanFormat.trueFormat).tag("true" as String?)
                                Text(type.booleanFormat.falseFormat).tag("false" as String?)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                    }
                    if showInfoButton {
                        infoButton(type: type)
                    }
                }
                if showInfoButton && showInfo {
                    info(type: type)
                }
            }
        }
    }
}
