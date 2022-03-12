//
//  PartOdometerFluidFilterView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct PartOdometerFluidFilterView: View {
    @ObservedObject var vehicle: Vehicle
    let fluidLineItemType: String
    let filterLineItemType: String
    let fluidName: String

    var body: some View {
        let milesSinceFluid = vehicle.milesSince(lineItemType: fluidLineItemType)
        let milesSinceFilter = vehicle.milesSince(lineItemType: filterLineItemType)
        if let milesSinceFluid = milesSinceFluid, let milesSinceFilter = milesSinceFilter, milesSinceFluid == milesSinceFilter {
            PartOdometerRowView(name: "\(fluidName) & filter", reading: milesSinceFluid)
        } else {
            if let milesSinceFluid = milesSinceFluid {
                PartOdometerRowView(name: fluidName, reading: milesSinceFluid)
            }
            if let milesSinceFilter = milesSinceFilter {
                PartOdometerRowView(name: "\(fluidName) filter", reading: milesSinceFilter)
            }
        }
    }
}

struct PartOdometerFluidFilterView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            PartOdometerFluidFilterView(vehicle: fixtures.vehicle, fluidLineItemType: "engineOilChanged", filterLineItemType: "engineOilFilterChanged", fluidName: "Oil")
        }
    }
}
