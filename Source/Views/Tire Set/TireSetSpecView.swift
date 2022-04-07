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

struct TireSetSpecView: View {
    @ObservedObject var tireSet: TireSet

    var loadCapacityCaption: LocalizedStringKey? {
        if let loadCapacity = tireSet.loadCapacity {
            return "\(loadCapacity)lbs/wheel"
        } else {
            return nil
        }
    }

    var topSpeedCaption: LocalizedStringKey? {
        if let topSpeed = tireSet.topSpeed {
            return "\(topSpeed)mph"
        } else {
            return nil
        }
    }

    @ViewBuilder
    var specForm: some View {
        FleetboxTextField(value: $tireSet.vehicleType, name: "Vehicle Type", example: "P")
            .caption(tireSet.vehicleTypeDescription)
            .autocapitalization(.characters)
        FleetboxTextField(value: $tireSet.width, name: "Width", example: 225)
        FleetboxTextField(value: $tireSet.aspectRatio, name: "Aspect Ratio", example: 70)
        FleetboxTextField(value: $tireSet.construction, name: "Construction", example: "R")
            .caption(tireSet.constructionDescription)
            .autocapitalization(.characters)
        FleetboxTextField(value: $tireSet.diameter, name: "Rim Diameter", example: 16)
        FleetboxTextField(value: $tireSet.loadIndex, name: "Load Index", example: 91)
            .caption(loadCapacityCaption)
        FleetboxTextField(value: $tireSet.speedRating, name: "Speed Rating", example: "S")
            .caption(topSpeedCaption)
            .autocapitalization(.characters)
    }

    var body: some View {
        Section(header: Text("Specs")) {
            FormLinkLabel(
                title: "Tire specs",
                value: tireSet.specs
            )
            .caption("Examples based on P225/70R16 91S")
            specForm
        }
    }
}
