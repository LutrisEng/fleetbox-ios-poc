//
//  PartOdometerIndividualView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct PartOdometerIndividualView: View {
    @ObservedObject var vehicle: Vehicle
    let lineItemType: String
    let name: String
    
    var body: some View {
        if let milesSince = vehicle.milesSince(lineItemType: lineItemType) {
            PartOdometerRowView(name: name, reading: milesSince)
        }
    }
}

struct PartOdometerIndividualView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            PartOdometerIndividualView(vehicle: fixtures.vehicle, lineItemType: "engineOilChanged", name: "Oil")
        }
    }
}
