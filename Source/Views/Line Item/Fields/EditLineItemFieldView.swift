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
    struct EditTireSetLineItemFieldView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @ObservedObject var field: LineItemField
        let type: LineItemTypeField
        @State private var sheetPresented: Bool = false
        
        var body: some View {
            Button(action: { sheetPresented = true }) {
                HStack {
                    Text(type.shortDisplayNameLocal)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(field.tireSetValue?.displayName ?? "None")
                        .foregroundColor(.secondary)
                }
            }
                .sheet(isPresented: $sheetPresented) {
                    TireSetPickerView(selected: field.tireSetValue) {
                        field.tireSetValue = $0
                        ignoreErrors {
                            try viewContext.save()
                        }
                        sheetPresented = false
                    }
                }
        }
    }
    
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var field: LineItemField
    
    var body: some View {
        if let type = field.type {
            Section(header: Text(type.longDisplayName)) {
                switch type.type {
                case .string:
                    FleetboxTextField(value: $field.stringValue, name: type.shortDisplayNameLocal, example: type.example)
                case .enumeration:
                    Picker(type.shortDisplayNameLocal, selection: convertToNonNilBinding(string: $field.stringValue)) {
                        ForEach(Array(type.enumValues.values)) { val in
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
                    Toggle(type.shortDisplayNameLocal, isOn: $field.booleanValue)
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
