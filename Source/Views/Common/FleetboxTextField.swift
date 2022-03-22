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

struct FleetboxTextField: View {
    @Environment(\.managedObjectContext) private var viewContext

    var value: Binding<String?>
    var wrappedValue: Binding<String>
    @State private var tempValue: String = ""
    let name: LocalizedStringKey?
    let description: LocalizedStringKey?
    let example: String?
    var unitName: LocalizedStringKey?
    var number: Bool = false

    init(value: Binding<String?>, name: LocalizedStringKey?, example: String?, description: LocalizedStringKey? = nil) {
        self.value = value
        wrappedValue = convertToNonNilBinding(string: value)
        self.name = name
        self.example = example
        self.description = description
    }

    init(value: Binding<Int64>, name: LocalizedStringKey?, example: Int64, description: LocalizedStringKey? = nil) {
        self.init(
            value: convertToNillableBinding(string: convertToStringBinding(int64: value)),
            name: name,
            example: String(example),
            description: description
        )
        number = true
    }

    init(value: Binding<Int16>, name: LocalizedStringKey?, example: Int16, description: LocalizedStringKey? = nil) {
        self.init(
            value: convertToNillableBinding(string: convertToStringBinding(int16: value)),
            name: name,
            example: String(example),
            description: description
        )
        number = true
    }

    func unit(_ unit: LocalizedStringKey) -> FleetboxTextField {
        var view = self
        view.unitName = unit
        return view
    }

    @ViewBuilder
    private var maybeUnitName: some View {
        if let unitName = unitName {
            (Text(" ") + Text(unitName))
                .foregroundColor(.secondary)
        } else {
            EmptyView()
        }
    }

    var body: some View {
        NavigationLink(
            destination: {
                Form {
                    if let description = description {
                        Text(description)
                    }
                    HStack {
                        ZStack(alignment: .trailing) {
                            TextField(
                                example ?? "",
                                text: $tempValue
                            )
                            .keyboardType(number ? .decimalPad : .default)
                            if let value = value.wrappedValue, !value.isEmpty {
                                Button(
                                    action: {
                                        self.tempValue = ""
                                    },
                                    label: {
                                        Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.secondary)
                                    }
                                )
                                .padding(.trailing, 8)
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        if let unitName = unitName {
                            Spacer()
                            Text(unitName)
                        }
                    }
                    .onAppear(perform: prepare)
                    .onDisappear(perform: save)
                    .navigationTitle(name ?? "")
                    .navigationBarTitleDisplayMode(.inline)
                }
            },
            label: {
                HStack {
                    if let name = name {
                        Text(name)
                    }
                    Spacer()
                    Text(value.wrappedValue ?? "").foregroundColor(.secondary)
                    maybeUnitName
                }
            }
        )
    }

    private func prepare() {
        tempValue = wrappedValue.wrappedValue
    }

    private func save() {
        wrappedValue.wrappedValue = tempValue
        ignoreErrors {
            try viewContext.save()
        }
    }
}
