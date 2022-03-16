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

    @Binding var value: String?
    @State var focused: Bool = false
    let name: LocalizedStringKey?
    let example: String?
    var unitName: LocalizedStringKey?

    func unit(_ unit: LocalizedStringKey) -> FleetboxTextField {
        var view = self
        view.unitName = unit
        return view
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
                        Button(action: { self.value = "" }, label: {
                            Image(systemName: "xmark.circle")
                                    .foregroundColor(.secondary)
                        })
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
