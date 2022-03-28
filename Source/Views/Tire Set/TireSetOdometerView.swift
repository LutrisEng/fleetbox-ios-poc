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

    var body: some View {
        Section(header: Text("Odometer")) {
            FormLinkLabel(
                title: "Verified distance",
                value: "\(Formatter.format(number: tireSet.odometer)) miles"
            )
            if let vehicle = tireSet.vehicle {
                FormLinkLabel(
                    title: "Est. distance per year",
                    value: "\(Formatter.format(number: vehicle.milesPerYear)) miles/year"
                )
                FormLinkLabel(
                    title: "Est. distance",
                    value: "\(Formatter.format(number: tireSet.approximateOdometer)) miles"
                )
            }
            FleetboxTextField(value: $tireSet.breakin, name: "Break-in period", example: 500)
                .unit("miles")
                .badge(tireSet.breakinBadge)
                .caption(tireSet.breakinPercentage)
                .progress(tireSet.breakinProgress)
                .progressColor((tireSet.breakinProgress ?? 0) < 1 ? .yellow : .green)
        }
    }
}
