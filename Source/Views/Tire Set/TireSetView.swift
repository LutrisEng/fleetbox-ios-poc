//
//  TireSetView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import SwiftUI

struct TireSetView: View {
    @ObservedObject var tireSet: TireSet

    var body: some View {
        Form {
            FleetboxTextField(value: $tireSet.userDisplayName, name: "Name", example: "My Summer Tires")
            FleetboxTextField(value: $tireSet.make, name: "Make", example: "TireCo")
            FleetboxTextField(value: $tireSet.model, name: "Model", example: "Aviator Sport")
            Section(header: Text("Actions")) {
                Button("Merge with other tire set") {
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
