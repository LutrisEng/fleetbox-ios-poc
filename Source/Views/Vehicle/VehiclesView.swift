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
import CoreData
import CoreSpotlight
import Sentry

struct VehiclesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Vehicle.sortOrder, ascending: true)],
            animation: .default)
    private var vehicles: FetchedResults<Vehicle>

    @State private var selection: String?

    var body: some View {
        NavigationView {
            List {
                ForEach(vehicles, id: \.self) { vehicle in
                    NavigationLink(vehicle.displayNameWithFallback) {
                        VehicleView(vehicle: vehicle)
                    }
                }
                        .onDelete { offsets in
                            withAnimation {
                                offsets
                                    .map { vehicles[$0] }
                                    .forEach(viewContext.delete)

                                ignoreErrors {
                                    try viewContext.save()
                                }
                            }
                        }
            }
                    .navigationTitle("Vehicles")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        ToolbarItem {
                            Button(action: addVehicle) {
                                Label("Add Vehicle", systemImage: "plus")
                            }
                        }
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: addFixtures) {
                                Label("Add Fixtures", systemImage: "questionmark.folder")
                            }
                        }
                    }
            Image(systemName: "car")
        }
    }

    private func addVehicle() {
        withAnimation {
            _ = Vehicle(context: viewContext)

            ignoreErrors {
                try viewContext.save()
            }
        }
    }

    private func addFixtures() {
        withAnimation {
            ignoreErrors {
                _ = try PersistenceController.Fixtures(viewContext: viewContext)
            }
        }
    }
}

struct VehiclesView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            VehiclesView()
        }
                .withoutNavigation()
    }
}
