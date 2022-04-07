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

struct PartOdometerIndividualView: View {
    @ObservedObject var vehicle: Vehicle
    let component: LineItemTypeComponent

    var milesSince: Int64? {
        vehicle.approximateMilesSince(replaces: component.id)
    }

    var timeSince: TimeInterval? {
        vehicle.timeSince(replaces: component.id)
    }

    var body: some View {
        PartOdometerRowView(
            name: component.name,
            milesSince: milesSince,
            timeSince: timeSince,
            milesLife: component.milesLife,
            monthsLife: component.monthsLife
        )
    }
}

#if DEBUG
struct PartOdometerIndividualView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            PartOdometerIndividualView(
                vehicle: fixtures.vehicle,
                component: lineItemTypes.allComponentsById["engineOil"]!
            )
        }
    }
}
#endif
