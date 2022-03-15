//
//  EditLineItemFieldView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
//

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
                    .onDisappear(perform: save)
        }
    }

    private func save() {
        ignoreErrors {
            try viewContext.save()
        }
    }
}
