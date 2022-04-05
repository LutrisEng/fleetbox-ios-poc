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

struct WarrantyView: View {
    @ObservedObject var warranty: Warranty

    var body: some View {
        Form {
            FleetboxTextField(value: $warranty.title, name: "Title", example: "New Vehicle Warranty")
            FleetboxTextField(value: $warranty.miles, name: "Valid for (distance)", example: 36000).unit("miles")
            if let odometer = warranty.underlyingOdometer {
                FormLinkLabel(title: "Distance elapsed", value: "About \(Formatter.format(number: odometer)) miles")
                    .progress(warranty.milesProgress)
                    .caption(warranty.milesPercentage)
            }
            FleetboxTextField(value: $warranty.months, name: "Valid for (time)", example: 36).unit("months")
            if let origin = warranty.underlyingOrigin {
                let monthsSince = monthsSince(origin: origin)
                FormLinkLabel(
                    title: "Time elapsed",
                    value: "About \(Formatter.format(monthsLabel: Int(round(monthsSince))))"
                )
                .progress(warranty.monthsProgress)
                .caption(warranty.monthsPercentage)
            }

            if let vehicle = warranty.vehicle {
                Section(header: Text("Vehicle")) {
                    NavigationLink(
                        destination: { VehicleView(vehicle: vehicle) },
                        label: {
                            FormLinkLabel(title: "Vehicle", value: vehicle.displayNameWithFallback)
                        }
                    )
                }
            } else if let tireSet = warranty.tireSet {
                Section(header: Text("Tire set")) {
                    NavigationLink(
                        destination: { TireSetView(tireSet: tireSet) },
                        label: {
                            FormLinkLabel(title: "Tire set", value: tireSet.displayName)
                        }
                    )
                }
            }

            Section(header: Text("Attachments")) {
                AttachmentsView(owner: warranty)
            }
        }
        .navigationTitle("Warranty")
        .modifier(SaveOnLeave())
    }
}
