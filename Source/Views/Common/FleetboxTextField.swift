//
//  FleetboxTextField.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import SwiftUI

struct FleetboxTextField: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @Binding var value: String?
    @State var focused: Bool = false
    let name: LocalizedStringKey?
    let example: String?
    var unitName: LocalizedStringKey? = nil
    
    func unit(_ unit: LocalizedStringKey) -> FleetboxTextField {
        var v = self
        v.unitName = unit
        return v
    }
    
    var body: some View {
        HStack {
            if let name = name {
                Text(name)
                Spacer()
            }
            HStack {
                ZStack(alignment: name == nil ? .trailing : .leading) {
                    TextField(
                        example ?? "",
                        text: convertToNonNilBinding(string: $value),
                        onEditingChanged: { editingChanged in
                            if editingChanged {
                                focused = true
                            } else {
                                focused = false
                            }
                        }
                    )
                    if let value = value, focused && !value.isEmpty {
                        Button(action: { self.value = "" }) {
                            Image(systemName: "xmark.circle")
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing, 8)
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
                if let unitName = unitName {
                    Spacer()
                    Text(unitName)
                }
            }
                .foregroundColor(name == nil ? .primary : .secondary)
                .frame(alignment: name == nil ? .leading : .trailing)
                .multilineTextAlignment(name == nil ? .leading : .trailing)
        }
    }
}
