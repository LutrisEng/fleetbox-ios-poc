//
//  VehicleView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/3/22.
//

import SwiftUI
import Sentry

struct VehicleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var vehicle: Vehicle
    
    var body: some View {
        VStack {
            Form {
                VehicleDetailsView(vehicle: vehicle)
                PartOdometersView(vehicle: vehicle)
                MaintenanceLogView(vehicle: vehicle)
            }
        }.navigationTitle(vehicle.fullModelName)
    }
}

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            VehicleView(vehicle: fixtures.vehicle)
        }
    }
}
