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
    @State private var stringValue: String = ""
    
    struct EditTireSetLineItemFieldView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \TireSet.sortOrder, ascending: true)],
            animation: .default)
        private var tireSets: FetchedResults<TireSet>
        @ObservedObject var field: LineItemField
        let type: LineItemTypeField
        @State private var selected: TireSet? = nil
        
        var body: some View {
            Picker(type.shortDisplayName, selection: $selected) {
                Text("None").tag(TireSet?.none)
                ForEach(tireSets) { ts in
                    Text(ts.displayName).tag(TireSet?.some(ts))
                }
            }
                .onAppear(perform: setupTireSet)
                .onDisappear(perform: saveTireSet)
        }
        
        func setupTireSet() {
            selected = field.tireSetValue
        }
        
        func saveTireSet() {
            print("Previous \(field.tireSetValue?.displayName ?? "nil"), new \(selected?.displayName ?? "nil")")
            field.tireSetValue = selected
            field.objectWillChange.send()
            do {
                try viewContext.save()
            } catch {
                SentrySDK.capture(error: error)
            }
        }
    }
    
    var body: some View {
        if let type = field.type {
            Section(header: Text(type.longDisplayName)) {
                switch type.type {
                case .string:
                    TextField(type.example ?? "", text: $stringValue, onCommit: saveString)
                        .onAppear(perform: setupString)
                        .onDisappear(perform: saveString)
                case .enumeration:
                    Picker(type.shortDisplayName, selection: $stringValue) {
                        ForEach(Array(type.enumValues.values)) { val in
                            VStack {
                                Text(val.displayName)
                                if let description = val.description {
                                    Text(description).font(.caption)
                                }
                            }
                        }
                    }
                        .onAppear(perform: setupString)
                        .onDisappear(perform: saveString)
                case .tireSet: EditTireSetLineItemFieldView(field: field, type: type)
                }
            }
        }
    }
    
    private func setupString() {
        stringValue = field.stringValue ?? ""
    }
    
    private func saveString() {
        field.stringValue = stringValue
        field.objectWillChange.send()
        do {
            try viewContext.save()
        } catch {
            SentrySDK.capture(error: error)
        }
    }
}
