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
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Vehicle.sortOrder, ascending: true)],
            animation: .default
    )
    private var vehicles: FetchedResults<Vehicle>

    var body: some View {
        NavigationView {
            List {
                let vehicles = vehicles.map { $0 }
                ForEach(vehicles, id: \.self) { vehicle in
                    NavigationLink(
                        destination: VehicleView(vehicle: vehicle),
                        label: {
                            if let displayName = vehicle.displayName {
                                VStack {
                                    Text(displayName)
                                        .font(.body.bold())
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Text(vehicle.fullModelName)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            } else {
                                Text(vehicle.fullModelName)
                            }
                        }
                    )
                }
                .onDelete(deleteFrom: vehicles, context: viewContext)
                .onMove(moveIn: vehicles)
            }
            .navigationTitle("Vehicles")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if editable {
                        NavigationLink(
                            destination: {
                                NewVehicleView()
                            },
                            label: {
                                Label("Add Vehicle", systemImage: "plus")
                            }
                        )
                        #if DEBUG
                        Button(action: addFixtures) {
                            Label("Add Fixtures", systemImage: "questionmark.folder")
                        }
                        #endif
                        EditButton()
                    }
                }
            }
            Image(systemName: "car")
        }
    }

    #if DEBUG
    private func addFixtures() {
        withAnimation {
            ignoreErrors {
                _ = try PersistenceController.Fixtures(viewContext: viewContext)
            }
        }
    }
    #endif
}

#if DEBUG
struct VehiclesView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            VehiclesView()
        }
                .withoutNavigation()
    }
}
#endif
