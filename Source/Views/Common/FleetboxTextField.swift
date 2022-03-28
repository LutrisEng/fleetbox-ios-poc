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
import Introspect

struct FleetboxTextField: View {
    enum Badge: View {
        case success, warning

        @ViewBuilder
        var body: some View {
            switch self {
            case .success:
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            case .warning:
                Image(systemName: "exclamationmark.circle")
                    .foregroundColor(.yellow)
            }
        }
    }

    private enum Caption {
        case localized(LocalizedStringKey)
        case string(String)
    }

    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    var value: Binding<String?>
    private var wrappedValue: Binding<String>
    @State private var tempValue: String = ""
    @State private var pageShown: Bool = false
    let name: LocalizedStringKey?
    let description: LocalizedStringKey?
    let example: String?
    private var unitName: LocalizedStringKey?
    private var number: Bool = false
    private var previewAsNumber: Bool = false
    private var _caption: Caption?
    private var _badge: Badge?

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
        previewAsNumber = true
    }

    init(value: Binding<Int16>, name: LocalizedStringKey?, example: Int16, description: LocalizedStringKey? = nil) {
        self.init(
            value: convertToNillableBinding(string: convertToStringBinding(int16: value)),
            name: name,
            example: String(example),
            description: description
        )
        number = true
        previewAsNumber = true
    }

    func unit(_ unit: LocalizedStringKey) -> FleetboxTextField {
        var view = self
        view.unitName = unit
        return view
    }

    func caption(_ caption: LocalizedStringKey?) -> FleetboxTextField {
        var view = self
        if let caption = caption {
            view._caption = .localized(caption)
        } else {
            view._caption = nil
        }
        return view
    }

    func caption(_ caption: String?) -> FleetboxTextField {
        var view = self
        if let caption = caption {
            view._caption = .string(caption)
        } else {
            view._caption = nil
        }
        return view
    }

    func previewAsString() -> FleetboxTextField {
        var view = self
        view.previewAsNumber = false
        return view
    }

    func badge(_ badge: Badge?) -> FleetboxTextField {
        var view = self
        view._badge = badge
        return view
    }

    private var maybeUnitName: Text {
        if let unitName = unitName, value.wrappedValue != nil {
            return (Text(" ") + Text(unitName))
        } else {
            return Text("")
        }
    }

    private var maybeCaption: Text {
        switch _caption {
        case .localized(let caption):
            return Text("\n") + Text(caption).font(.caption)
        case .string(let caption):
            return Text("\n") + Text(caption).font(.caption)
        case nil:
            return Text("")
        }
    }

    private var numberValue: Int64? {
        if number, let value = value.wrappedValue {
            return try? Int64(value, format: .number)
        } else {
            return nil
        }
    }

    private var previewValue: LocalizedStringKey {
        if previewAsNumber, let numberValue = numberValue {
            return "\(numberValue)"
        } else if let value = value.wrappedValue {
            return "\(value)"
        } else {
            return ""
        }
    }

    @ViewBuilder
    private var label: some View {
        HStack {
            if let name = name {
                Text(name)
            }
            Spacer()
            (Text(previewValue) + maybeUnitName + maybeCaption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.trailing)
            if let badge = _badge {
                badge
            }
        }
    }

    var body: some View {
        if editable {
            NavigationLink(
                isActive: $pageShown,
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
                                .introspectTextField { textField in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                        textField.becomeFirstResponder()
                                    }
                                }
                                .onSubmit {
                                    pageShown = false
                                }
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
                label: { label }
            )
        } else {
            label
        }
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
