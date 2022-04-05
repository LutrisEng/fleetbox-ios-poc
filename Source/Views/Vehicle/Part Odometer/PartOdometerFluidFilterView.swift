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

struct PartOdometerFluidFilterView: View {
    @ObservedObject var vehicle: Vehicle
    let fluid: LineItemTypeComponent
    let filter: LineItemTypeComponent

    var body: some View {
        let milesSinceFluid = vehicle.approximateMilesSince(replaces: fluid.id)
        let timeSinceFluid = vehicle.timeSince(replaces: filter.id)
        let milesSinceFilter = vehicle.approximateMilesSince(replaces: fluid.id)
        let timeSinceFilter = vehicle.timeSince(replaces: filter.id)
        if milesSinceFluid != nil &&
            milesSinceFluid == milesSinceFilter &&
            (timeSinceFluid ?? 0) - (timeSinceFilter ?? 0) < 60 * 60 {
            PartOdometerRowView(
                name: "\(fluid.name) & filter",
                milesSince: milesSinceFluid,
                timeSince: timeSinceFluid
            )
        } else {
            if milesSinceFluid != nil || timeSinceFluid != nil {
                PartOdometerRowView(
                    name: fluid.name,
                    milesSince: milesSinceFluid,
                    timeSince: timeSinceFluid
                )
            }
            if milesSinceFilter != nil || timeSinceFilter != nil {
                PartOdometerRowView(
                    name: filter.name,
                    milesSince: milesSinceFilter,
                    timeSince: timeSinceFilter
                )
            }
        }
    }
}

#if DEBUG
struct PartOdometerFluidFilterView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            PartOdometerFluidFilterView(
                    vehicle: fixtures.vehicle,
                    fluid: lineItemTypes.allComponentsById["engineOil"]!,
                    filter: lineItemTypes.allComponentsById["engineOilFilter"]!
            )
        }
    }
}
#endif
