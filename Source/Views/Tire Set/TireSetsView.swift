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
                        ToolbarItem {
                            Button(action: addTireSet) {
                                Label("Add Tire Set", systemImage: "plus")
                            }
                        }
                    }
            Text("Select a tire set")
        }
    }

    private func addTireSet() {
        withAnimation {
            _ = TireSet(context: viewContext)

            ignoreErrors {
                try viewContext.save()
            }
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
