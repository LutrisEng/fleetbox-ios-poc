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

struct TireSetOdometerView: View {
    @ObservedObject var tireSet: TireSet

    var breakinPercentage: String? {
        let odo = tireSet.odometer
        if tireSet.breakin != 0 && odo <= tireSet.breakin {
            return Formatter.format(wholePercentage: Double(odo) / Double(tireSet.breakin))
        } else {
            return nil
        }
    }

    var breakinProgress: Double? {
        if tireSet.breakin != 0 {
            return min(1, Double(tireSet.odometer) / Double(tireSet.breakin))
        } else {
            return nil
        }
    }

    var breakinBadge: Badge? {
        if tireSet.breakin != 0 {
            let odo = tireSet.odometer
            if odo > tireSet.breakin {
                return .success
            } else {
                return .warning
            }
        }
        return nil
    }

    var body: some View {
        Section(header: Text("Odometer")) {
            PartOdometerRowView(name: "Tires", milesSince: tireSet.odometer, timeSince: tireSet.age)
            FleetboxTextField(value: $tireSet.breakin, name: "Break-in period", example: 500)
                .unit("miles")
                .badge(breakinBadge)
                .caption(breakinPercentage)
                .progress(breakinProgress)
        }
    }
}
