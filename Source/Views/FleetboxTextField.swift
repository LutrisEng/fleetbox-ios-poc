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
    let example: String
    
    var body: some View {
        HStack {
            if let name = name {
                Text(name)
                    .font(.body.bold())
                    .frame(width: 60, alignment: .trailing)
            }
            ZStack(alignment: .trailing) {
                TextField(
                    example,
                    text: Binding(
                        get: {
                            value ?? ""
                        },
                        set: { newValue in
                            value = newValue
                            ignoreErrors {
                                try viewContext.save()
                            }
                        }
                    ),
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
                            .foregroundColor(Color(UIColor.opaqueSeparator))
                    }
                    .padding(.trailing, 8)
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }
}
