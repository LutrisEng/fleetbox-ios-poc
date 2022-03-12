//
//  EditTireSetLineItemFieldView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

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
