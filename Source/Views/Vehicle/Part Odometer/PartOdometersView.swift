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

struct PartOdometersView: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var vehicle: Vehicle

    @State private var createPresented: Bool = false
    @StateObject private var createReading = NumbersOnly()

    var breakinBadge: FleetboxTextField.Badge? {
        if vehicle.breakin != 0 {
            let odo = vehicle.odometer
            if odo > vehicle.breakin {
                return .success
            } else {
                return .warning
            }
        }
        return nil
    }

    var warrantyBadge: FleetboxTextField.Badge? {
        if vehicle.warranty != 0 {
            let odo = vehicle.odometer
            if odo > vehicle.warranty {
                return .warning
            } else {
                return .success
            }
        }
        return nil
    }

    var body: some View {
        Section(header: Text("Odometer")) {
            if editable {
                Button("Record odometer reading") {
                    createPresented = true
                }
                .sheet(isPresented: $createPresented) {
                    NavigationView {
                        OdometerReadingFormView(previousReading: vehicle.odometer) { value in
                            let reading = OdometerReading(context: viewContext)
                            reading.vehicle = vehicle
                            reading.at = Date.now
                            reading.reading = value
                            createPresented = false
                        } onDismiss: {
                            createPresented = false
                        }
                    }
                }
            }
            NavigationLink("View odometer readings") {
                OdometerReadingsView(vehicle: vehicle)
                    .navigationTitle("Odometer readings")
            }
            PartOdometerRowView(
                name: "Vehicle",
                milesSince: vehicle.odometer,
                timeSince: vehicle.age
            )
            FleetboxTextField(value: $vehicle.breakin, name: "Break-in period", example: 1000)
                .unit("miles")
                .badge(breakinBadge)
            FleetboxTextField(value: $vehicle.warranty, name: "Main warranty", example: 50000)
                .unit("miles")
                .badge(warrantyBadge)
            if let tires = vehicle.currentTireSet {
                PartOdometerRowView(
                    name: "Tires",
                    milesSince: tires.odometer,
                    timeSince: tires.age
                )
            }
            ForEach(partOdometers) { odometer in
                odometer.view(vehicle: vehicle)
            }
        }
    }
}

#if DEBUG
struct PartOdometersView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            PartOdometersView(vehicle: fixtures.vehicle)
        }
    }
}
#endif
