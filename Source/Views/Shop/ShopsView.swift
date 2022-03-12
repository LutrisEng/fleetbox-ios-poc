//
//  ShopsView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

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

                                ignoreErrors {
                                    try viewContext.save()
                                }
                            }
                        }
            }
                    .navigationTitle("Shops")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
//                    ToolbarItem {
//                        Button(action: addVehicle) {
//                            Label("Add Shop", systemImage: "plus")
//                        }
//                    }
                    }
            Text("Select a shop")
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
