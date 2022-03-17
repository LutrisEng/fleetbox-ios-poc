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
        Section(header: Text("Vehicle details")) {
            FleetboxTextField(value: $vehicle.displayName, name: "Name", example: dummyData.vehicleName)
            VINDetailView(vehicle: vehicle)
            FleetboxTextField(value: $vehicle.year, name: "Year", example: 2020)
            FleetboxTextField(value: $vehicle.make, name: "Make", example: dummyData.vehicleMake)
            FleetboxTextField(value: $vehicle.model, name: "Model", example: dummyData.vehicleModel)
            if let tireSet = vehicle.currentTireSet {
                TireDetailView(tireSet: tireSet)
            }
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
