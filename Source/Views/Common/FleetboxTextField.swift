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
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    private var wrappedValue: Binding<String>
    @State private var tempValue: String = ""
    @State private var pageShown: Bool = false
    let name: LocalizedStringKey?
    let description: Text?
    let example: String?
    private var unitName: Text?
    private var number: Bool = false
    private var previewAsNumber: Bool = false
    private var _caption: Text?
    private var _badge: Badge?
    private var _progress: Double?
    private var _progressColor: Color?
    private var _autocapitalization: TextInputAutocapitalization?
    private var _keyboardType: UIKeyboardType = .default
    private var _autocorrection: Bool = true
    private var _allowNewline: Bool = true

    init(value: Binding<String?>, name: LocalizedStringKey?, example: String?, description: Textable? = nil) {
        wrappedValue = convertToNonNilBinding(string: value)
        self.name = name
        self.example = example
        self.description = description?.text
    }

    init(value: Binding<Int64>, name: LocalizedStringKey?, example: Int64, description: Textable? = nil) {
        self.init(
            value: convertToNillableBinding(string: convertToStringBinding(int64: value)),
            name: name,
            example: Formatter.format(number: example),
            description: description
        )
        number = true
        previewAsNumber = true
        _keyboardType = .numberPad
    }

    init(value: Binding<Int16>, name: LocalizedStringKey?, example: Int16, description: Textable? = nil) {
        self.init(
            value: convertToNillableBinding(string: convertToStringBinding(int16: value)),
            name: name,
            example: Formatter.format(number: example),
            description: description
        )
        number = true
        previewAsNumber = true
        _keyboardType = .numberPad
    }

    func unit<Unit: Textable>(_ unit: Unit) -> Self {
        var view = self
        view.unitName = unit.text
        return view
    }

    func caption<Caption: Textable>(_ caption: Caption?) -> Self {
        var view = self
        if let caption = caption {
            view._caption = caption.text
        } else {
            view._caption = nil
        }
        return view
    }

    func progress(_ progress: Double?) -> Self {
        var view = self
        view._progress = progress
        return view
    }

    func progressColor(_ color: Color?) -> Self {
        var view = self
        view._progressColor = color
        return view
    }

    func previewAsString() -> Self {
        var view = self
        view.previewAsNumber = false
        return view
    }

    func badge(_ badge: Badge?) -> Self {
        var view = self
        view._badge = badge
        return view
    }

    func autocapitalization(_ autocapitalization: TextInputAutocapitalization?) -> Self {
        var view = self
        view._autocapitalization = autocapitalization
        return view
    }

    func keyboard(_ type: UIKeyboardType) -> Self {
        var view = self
        view._keyboardType = type
        return view
    }

    func autocorrection(_ autocorrection: Bool) -> Self {
        var view = self
        view._autocorrection = autocorrection
        return view
    }

    func allowNewline(_ allowNewline: Bool = true) -> Self {
        var view = self
        view._allowNewline = allowNewline
        return view
    }

    private var maybeUnitName: Text {
        if let unitName = unitName, !wrappedValue.wrappedValue.isEmpty {
            return (Text(" ") + unitName)
        } else {
            return Text("")
        }
    }

    private var numberValue: Int64? {
        if number, !wrappedValue.wrappedValue.isEmpty {
            return try? Int64(wrappedValue.wrappedValue, format: .number)
        } else {
            return nil
        }
    }

    private var previewValue: String {
        if previewAsNumber, let numberValue = numberValue {
            return Formatter.format(number: numberValue)
        } else if !wrappedValue.wrappedValue.isEmpty {
            return wrappedValue.wrappedValue
        } else {
            return ""
        }
    }

    private var tempValueBinding: Binding<String> {
        if previewAsNumber {
            return convertToNumberFormattingBinding(string: $tempValue)
        } else {
            return $tempValue
        }
    }

    @ViewBuilder
    private var label: some View {
        FormLinkLabel(title: name ?? "", value: Text(previewValue) + maybeUnitName)
            .caption(_caption)
            .progress(_progress)
            .progressColor(_progressColor)
            .badge(_badge)
            .allowNewline(_allowNewline)
    }

    var body: some View {
        if editable {
            NavigationLink(
                isActive: $pageShown,
                destination: {
                    Form {
                        if let description = description {
                            description
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        HStack {
                            ZStack(alignment: .trailing) {
                                TextField(
                                    example ?? "",
                                    text: tempValueBinding
                                )
                                .firstResponder()
                                .introspectTextField { textField in
                                    textField.text = tempValueBinding.wrappedValue
                                }
                                .textInputAutocapitalization(_autocapitalization)
                                .onSubmit {
                                    pageShown = false
                                }
                                .keyboardType(_keyboardType)
                                .disableAutocorrection(!_autocorrection)
                                if !tempValue.isEmpty {
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
                                unitName
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Done") {
                                withAnimation {
                                    pageShown = false
                                }
                            }
                        }
                    }
                    .onAppear(perform: prepare)
                    .onDisappear(perform: save)
                    .navigationTitle(name ?? "")
                    .navigationBarTitleDisplayMode(.inline)
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
