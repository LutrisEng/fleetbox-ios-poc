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
    let lineItemType: String
    let name: String

    var milesSince: Int64? {
        vehicle.milesSince(lineItemType: lineItemType)
    }

    var timeSince: TimeInterval? {
        vehicle.timeSince(lineItemType: lineItemType)
    }

    var body: some View {
        if milesSince != nil || timeSince != nil {
            PartOdometerRowView(name: name, milesSince: milesSince, timeSince: timeSince)
        }
    }
}

#if DEBUG
struct PartOdometerIndividualView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            PartOdometerIndividualView(vehicle: fixtures.vehicle, lineItemType: "engineOilChanged", name: "Oil")
        }
    }
}
#endif
