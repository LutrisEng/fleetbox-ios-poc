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

    @State private var selection: String?

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

                                ignoreErrors {
                                    try viewContext.save()
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
        PreviewWrapper { _ in
            TireSetsView()
        }
                .withoutNavigation()
    }
}
