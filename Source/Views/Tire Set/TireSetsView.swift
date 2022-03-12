//
//  TireSetsView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import SwiftUI
import Sentry

struct TireSetsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \TireSet.sortOrder, ascending: true)],
            animation: .default)
    private var tireSets: FetchedResults<TireSet>

    @State private var selection: String? = nil

    var body: some View {
        NavigationView {
            List {
                ForEach(tireSets, id: \.self) { tireSet in
                    NavigationLink(
                            tireSet.displayName,
                            destination: TireSetView(tireSet: tireSet),
                            tag: tireSet.objectID.uriRepresentation().absoluteString,
                            selection: $selection)
                }
                        .onDelete { offsets in
                            withAnimation {
                                offsets.map {
                                            tireSets[$0]
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
                    .navigationTitle("Tire sets")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
//                    ToolbarItem {
//                        Button(action: addVehicle) {
//                            Label("Add Tire Set", systemImage: "plus")
//                        }
//                    }
                    }
            Text("Select a tire set")
        }
    }
}

struct TireSetsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            TireSetsView()
        }
                .withoutNavigation()
    }
}
