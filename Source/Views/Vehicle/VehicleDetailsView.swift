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

struct VehicleDetailsView: View {
    @ObservedObject var vehicle: Vehicle

    var body: some View {
        Section(header: Text("Details")) {
            FleetboxTextField(value: $vehicle.displayName, name: "Name", example: dummyData.vehicleName)
            VINDetailView(vehicle: vehicle)
            FleetboxTextField(value: $vehicle.year, name: "Year", example: 2020)
                .previewAsString()
            FleetboxTextField(value: $vehicle.make, name: "Make", example: dummyData.vehicleMake)
                .autocapitalization(.words)
            FleetboxTextField(value: $vehicle.model, name: "Model", example: dummyData.vehicleModel)
                .autocapitalization(.words)
            if let licensePlateNumber = vehicle.licensePlateNumber {
                FormLinkLabel(title: "License plate", value: licensePlateNumber)
            }
            if let tireSet = vehicle.currentTireSet {
                TireDetailView(tireSet: tireSet)
            }
            BreakinField(obj: vehicle, name: "Break-in period", example: 1000)
            if let tireSet = vehicle.currentTireSet {
                BreakinField(obj: tireSet, name: "Tire break-in period", example: 500)
            }
            NavigationLink(
                destination: {
                    Form {
                        PartOdometersView(vehicle: vehicle)
                    }
                    .navigationTitle("Odometer")
                },
                label: {
                    FormLinkLabel(
                        title: "Odometer",
                        value: "About \(Formatter.format(number: vehicle.approximateOdometer)) miles"
                    )
                }
            )
        }
    }
}

#if DEBUG
struct VehicleDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            VehicleDetailsView(vehicle: fixtures.vehicle)
        }
    }
}
#endif
