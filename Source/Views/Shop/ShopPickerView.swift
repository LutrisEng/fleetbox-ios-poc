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

struct ShopPickerView: View {
    @Environment(\.dismiss) var dismiss

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Shop.sortOrder, ascending: true)],
            animation: .default)
    private var shops: FetchedResults<Shop>

    let selected: Shop?
    let action: (Shop) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(shops, id: \.self) { shop in
                    Button(action: {
                        action(shop)
                        dismiss()
                    }, label: {
                        HStack {
                            Text(shop.name ?? "Unknown shop")
                                    .foregroundColor(.primary)
                            if selected == shop {
                                Spacer()
                                Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                            }
                        }
                    })
                }
            }
                    .navigationTitle("Shops")
        }
    }
}

struct ShopPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            ShopPickerView(selected: nil) {
                print($0.name ?? "Unknown shop")
            }
        }
    }
}
