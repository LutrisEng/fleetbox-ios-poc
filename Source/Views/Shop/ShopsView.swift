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
import Sentry

struct ShopsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Shop.sortOrder, ascending: true)],
            animation: .default)
    private var shops: FetchedResults<Shop>

    @State private var selection: String?

    var body: some View {
        NavigationView {
            List {
                ForEach(shops, id: \.self) { shop in
                    NavigationLink(
                            shop.name ?? "Unknown shop",
                            destination: ShopView(shop: shop),
                            tag: shop.objectID.uriRepresentation().absoluteString,
                            selection: $selection)
                }
                        .onDelete { offsets in
                            withAnimation {
                                offsets.map {
                                            shops[$0]
                                        }
                                        .forEach(viewContext.delete)
                            }
                        }
            }
                    .navigationTitle("Shops")
                    .toolbar {
                        ToolbarItemGroup(placement: .navigationBarTrailing) {
                            Button(action: addShop) {
                                Label("Add Shop", systemImage: "plus")
                            }
                            EditButton()
                        }
                    }
            Text("Select a shop")
        }
    }

    private func addShop() {
        withAnimation {
            _ = Shop(context: viewContext)
        }
    }
}

struct ShopsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            ShopsView()
        }
                .withoutNavigation()
    }
}
