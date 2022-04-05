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

func generatePartOdometers() -> [PartOdometer] {
    let fluidFilterPairs = lineItemTypes.allComponents.compactMap { component -> (String, String)? in
        if let filter = component.filter {
            return (component.id, filter)
        } else {
            return nil
        }
    }
    let fluids = Set(fluidFilterPairs.map { $0.0 })
    let filters = Set(fluidFilterPairs.map { $0.1 })
    let individuals = lineItemTypes.allComponents.filter { !fluids.contains($0.id) && !filters.contains($0.id) }
    var partOdometers: [PartOdometer] = []
    for (fluid, filter) in fluidFilterPairs {
        let fluidComponent = lineItemTypes.allComponentsById[fluid]!
        let filterComponent = lineItemTypes.allComponentsById[filter]!
        partOdometers.append(.fluidFilter(fluid: fluidComponent, filter: filterComponent))
    }
    for individual in individuals {
        partOdometers.append(.individual(component: individual))
    }
    return partOdometers
}

let partOdometers: [PartOdometer] = generatePartOdometers()

enum PartOdometer: Identifiable {
    case individual(component: LineItemTypeComponent)
    case fluidFilter(fluid: LineItemTypeComponent, filter: LineItemTypeComponent)

    var id: String {
        switch self {
        case .individual(let component):
            return "lineItem:\(component.id)"
        case .fluidFilter(let fluid, let filter):
            return "lineItem:\(fluid.id):\(filter.id)"
        }
    }

    @ViewBuilder
    func view(vehicle: Vehicle) -> some View {
        switch self {
        case .individual(let component):
            PartOdometerIndividualView(
                    vehicle: vehicle,
                    component: component
            )
        case .fluidFilter(let fluid, let filter):
            PartOdometerFluidFilterView(
                    vehicle: vehicle,
                    fluid: fluid,
                    filter: filter
            )
        }
    }
}
