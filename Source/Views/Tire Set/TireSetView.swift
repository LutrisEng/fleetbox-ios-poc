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

struct TireSetView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var tireSet: TireSet

    var body: some View {
        Form {
            FleetboxTextField(value: $tireSet.userDisplayName, name: "Name", example: "My Summer Tires")
            FleetboxTextField(value: $tireSet.make, name: "Make", example: "TireCo")
            FleetboxTextField(value: $tireSet.model, name: "Model", example: "Aviator Sport")
            if let vehicle = tireSet.vehicle {
                Section(header: Text("Current vehicle")) {
                    NavigationLink(vehicle.displayNameWithFallback) {
                        VehicleView(vehicle: vehicle)
                    }
                }
            }
            let logItems = tireSet.logItemsInverseChrono
            if !logItems.isEmpty {
                Section(header: Text("Log items")) {
                    ForEach(logItems) { logItem in
                        NavigationLink(
                            destination: {
                                LogItemView(logItem: logItem)
                            },
                            label: {
                                LogItemLabelView(logItem: logItem, showVehicle: true)
                            }
                        )
                    }
                }
            }
            Section(header: Text("Actions")) {
                NavigationLink("Merge with other tire set") {
                    TireSetPickerView(
                        selected: nil,
                        allowNone: false,
                        exclude: [tireSet]
                    ) {
                        tireSet.mergeWith($0!)
                        ignoreErrors {
                            try viewContext.save()
                        }
                    }
                    .navigationTitle("Merge tire sets")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
                .navigationTitle("Tire set")
    }
}

struct TireSetView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            TireSetView(tireSet: fixtures.tireSet)
        }
    }
}
