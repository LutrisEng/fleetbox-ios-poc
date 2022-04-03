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
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \TireSet.sortOrder, ascending: true)],
            animation: .default)
    private var tireSets: FetchedResults<TireSet>

    @State private var showHidden = false

    @ViewBuilder
    func setList(_ sets: [TireSet]) -> some View {
        ForEachObjects(sets) { tireSet in
            NavigationLink(
                destination: EnsureNavigationView {
                    TireSetView(tireSet: tireSet)
                },
                label: {
                    TireSetLabelView(tireSet: tireSet)
                }
            )
        }
    }

    var body: some View {
        EnsureNavigationView {
            List {
                let mounted = tireSets.filter { $0.category == .mounted }
                if !mounted.isEmpty {
                    Section(header: Text("Mounted")) {
                        setList(mounted)
                    }
                }
                let unmounted = tireSets.filter { $0.category == .unmounted }
                if !unmounted.isEmpty {
                    Section(header: Text("Unmounted")) {
                        setList(unmounted)
                    }
                }
                let hidden = tireSets.filter { $0.category == .hidden }
                if showHidden && !hidden.isEmpty {
                    Section(header: Text("Hidden")) {
                        setList(hidden)
                    }
                }
            }
            .navigationTitle("Tire sets")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(
                        action: {
                            withAnimation {
                                showHidden.toggle()
                            }
                        },
                        label: {
                            if showHidden {
                                Label("Show hidden items", systemImage: "eye")
                            } else {
                                Label("Hide hidden items", systemImage: "eye.slash")
                            }
                        }
                    )
                    if editable {
                        Button(action: addTireSet) {
                            Label("Add Tire Set", systemImage: "plus")
                        }
                        EditButton()
                    }
                }
            }
            Text("Select a tire set")
        }
    }

    private func addTireSet() {
        withAnimation {
            _ = TireSet(context: viewContext)
        }
    }
}

#if DEBUG
struct TireSetsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            TireSetsView()
        }
                .withoutNavigation()
    }
}
#endif
