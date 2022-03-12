//
//  VehicleDetailsView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct VehicleDetailsView: View {
    @ObservedObject var vehicle: Vehicle

    var body: some View {
        Section(header: Text("Vehicle details")) {
            FleetboxTextField(value: $vehicle.displayName, name: "Name", example: dummyData.vehicleName)
            VINDetailView(vehicle: vehicle)
            FleetboxTextField(value: $vehicle.make, name: "Make", example: dummyData.vehicleMake)
            FleetboxTextField(value: $vehicle.model, name: "Model", example: dummyData.vehicleModel)
            if let tireSet = vehicle.currentTireSet {
                TireDetailView(tireSet: tireSet)
            }
        }
    }
}

struct VehicleDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            VehicleDetailsView(vehicle: fixtures.vehicle)
        }
    }
}
