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
    @Environment(\.editable) private var editable
    @Environment(\.dismiss) private var dismiss

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Shop.sortOrder, ascending: true)],
            animation: .default)
    private var shops: FetchedResults<Shop>

    let selected: Shop?
    let exclude: Set<Shop>
    let action: (Shop) -> Void

    init(selected: Shop?, exclude: Set<Shop> = [], action: @escaping (Shop) -> Void) {
        self.selected = selected
        self.exclude = exclude
        self.action = action
    }

    var body: some View {
        List {
            let filteredShops = shops.filter { !exclude.contains($0) }
            if filteredShops.isEmpty {
                if exclude.isEmpty {
                    Text("No shops").foregroundColor(.secondary)
                } else {
                    Text("No eligible shops").foregroundColor(.secondary)
                }
            } else {
                ForEach(filteredShops, id: \.self) { shop in
                    Button(
                        action: {
                            action(shop)
                            dismiss()
                        }, label: {
                            HStack {
                                ShopLabelView(shop: shop)
                                if selected == shop {
                                    Image(systemName: "checkmark")
                                            .foregroundColor(.accentColor)
                                }
                            }
                        }
                    )
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                if editable {
                    NavigationLink(
                        destination: EnsureNavigationView {
                            NewShopView()
                        },
                        label: {
                            Label("Add Shop", systemImage: "plus")
                        }
                    )
                }
            }
        }
    }
}

#if DEBUG
struct ShopPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            ShopPickerView(selected: nil) {
                print($0.name ?? "Unknown shop")
            }
        }
    }
}
#endif
