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

    @State private var selection: String? = nil

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

                                do {
                                    try viewContext.save()
                                } catch {
                                    SentrySDK.capture(error: error)
                                    // Replace this implementation with code to handle the error appropriately.
                                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                    let nsError = error as NSError
                                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
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
        PreviewWrapper { fixtures in
            ShopsView()
        }
                .withoutNavigation()
    }
}
