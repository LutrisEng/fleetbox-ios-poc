//
//  PartOdometer.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import Foundation
import SwiftUI

let partOdometers: [PartOdometer] = [
    .fluidFilter(
            fluidLineItemType: "engineOilChange",
            filterLineItemType: "engineOilFilterChange",
            fluidName: "Oil"
    ),
    .fluidFilter(
            fluidLineItemType: "transmissionFluidChange",
            filterLineItemType: "transmissionFluidFilterChange",
            fluidName: "Transmission fluid"
    ),
    .individual(
            lineItemType: "brakeFluidChange",
            name: "Brake fluid"
    ),
    .individual(
            lineItemType: "coolantChange",
            name: "Coolant"
    ),
    .individual(
            lineItemType: "sparkPlugReplacement",
            name: "Spark plugs"
    ),
    .individual(
            lineItemType: "batteryReplacement",
            name: "12V battery"
    ),
    .individual(
            lineItemType: "hvBatteryReplacement",
            name: "High-voltage battery"
    ),
    .individual(
            lineItemType: "engineAirFilterChange",
            name: "Engine air filter"
    ),
    .individual(
            lineItemType: "cabinAirFilterChange",
            name: "Cabin air filter"
    )
]

enum PartOdometer: Identifiable {
    case individual(lineItemType: String, name: String)
    case fluidFilter(fluidLineItemType: String, filterLineItemType: String, fluidName: String)

    var id: String {
        switch self {
        case .individual(let type, let name):
            return "lineItem:\(type):\(name)"
        case .fluidFilter(let fluidType, let filterType, let name):
            return "lineItem:\(fluidType):\(filterType):\(name)"
        }
    }

    @ViewBuilder
    func view(vehicle: Vehicle) -> some View {
        switch self {
        case .individual(let lineItemType, let name):
            PartOdometerIndividualView(
                    vehicle: vehicle,
                    lineItemType: lineItemType,
                    name: name
            )
        case .fluidFilter(let fluidLineItemType, let filterLineItemType, let fluidName):
            PartOdometerFluidFilterView(
                    vehicle: vehicle,
                    fluidLineItemType: fluidLineItemType,
                    filterLineItemType: filterLineItemType,
                    fluidName: fluidName
            )
        }
    }
}
