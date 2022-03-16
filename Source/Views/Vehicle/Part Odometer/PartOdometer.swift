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
