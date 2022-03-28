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

struct TireSetView: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var tireSet: TireSet

    @ViewBuilder
    var baseSpecForm: some View {
        FleetboxTextField(value: $tireSet.vehicleType, name: "Vehicle Type", example: "P")
        FleetboxTextField(value: $tireSet.width, name: "Width", example: 225)
        FleetboxTextField(value: $tireSet.aspectRatio, name: "Aspect Ratio", example: 70)
        FleetboxTextField(value: $tireSet.construction, name: "Construction", example: "R")
        FleetboxTextField(value: $tireSet.diameter, name: "Rim Diameter", example: 16)
    }

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
        baseSpecForm
        FleetboxTextField(value: $tireSet.loadIndex, name: "Load Index", example: 91)
            .caption(loadCapacityCaption)
        FleetboxTextField(value: $tireSet.speedRating, name: "Speed Rating", example: "S")
            .caption(topSpeedCaption)
    }

    var warrantyProgress: String? {
        let odo = tireSet.odometer
        if tireSet.treadwearWarranty != 0 && odo <= tireSet.treadwearWarranty {
            return Formatter.formatWholePercentage(numerator: odo, denominator: tireSet.treadwearWarranty)
        } else {
            return nil
        }
    }

    var warrantyBadge: FleetboxTextField.Badge? {
        if tireSet.treadwearWarranty != 0 {
            let odo = tireSet.odometer
            if odo > tireSet.treadwearWarranty {
                return .warning
            } else {
                return .success
            }
        }
        return nil
    }

    var breakinProgress: String? {
        let odo = tireSet.odometer
        if tireSet.breakin != 0 && odo <= tireSet.breakin {
            return Formatter.formatWholePercentage(numerator: odo, denominator: tireSet.breakin)
        } else {
            return nil
        }
    }

    var breakinBadge: FleetboxTextField.Badge? {
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
        Form {
            FleetboxTextField(value: $tireSet.userDisplayName, name: "Name", example: "My Summer Tires")
            FleetboxTextField(value: $tireSet.make, name: "Make", example: "TireCo")
            FleetboxTextField(value: $tireSet.model, name: "Model", example: "Aviator Sport")
            FleetboxTextField(value: $tireSet.tin, name: "TIN", example: "DOT U2LL LMLR5107")
            if tireSet.hidden {
                Button("Un-hide") {
                    tireSet.hidden = false
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
            } else {
                Button("Hide") {
                    tireSet.hidden = true
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
            }
            if let vehicle = tireSet.vehicle {
                Section(header: Text("Current vehicle")) {
                    NavigationLink(vehicle.displayNameWithFallback) {
                        VehicleView(vehicle: vehicle)
                    }
                }
            }
            Section(header: Text("Odometer")) {
                PartOdometerRowView(name: "Tires", milesSince: tireSet.odometer, timeSince: tireSet.age)
                FleetboxTextField(value: $tireSet.treadwearWarranty, name: "Treadlife Warranty", example: 30000)
                    .unit("miles")
                    .badge(warrantyBadge)
                    .caption(warrantyProgress)
                FleetboxTextField(value: $tireSet.breakin, name: "Break-in period", example: 500)
                    .unit("miles")
                    .badge(breakinBadge)
                    .caption(breakinProgress)
            }
            Section(header: Text("Specs")) {
                HStack {
                    Text("Tire specs")
                    Spacer()
                    VStack {
                        (
                            Text(tireSet.specs) +
                            Text("\nExamples based on P225/70R16 91S")
                                .font(.caption)
                        )
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.trailing)
                    }
                }
                specForm
            }
            let logItems = tireSet.logItemsInverseChrono
            if !logItems.isEmpty {
                Section(header: Text("Log items")) {
                    ForEach(logItems) { logItem in
                        NavigationLink(
                            destination: {
                                LogItemView(logItem: logItem)
                            },
                            label: {
                                LogItemLabelView(logItem: logItem, showVehicle: true)
                            }
                        )
                    }
                }
            }
            if editable {
                Section(header: Text("Actions")) {
                    NavigationLink("Merge with other tire set") {
                        TireSetPickerView(
                            selected: nil,
                            allowNone: false,
                            exclude: [tireSet]
                        ) {
                            tireSet.mergeWith($0!)
                        }
                        .navigationTitle("Merge tire sets")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
        .modifier(WithDoneButton())
        .modifier(SaveOnLeave())
        .navigationTitle("Tire set")
    }
}

#if DEBUG
struct TireSetView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            TireSetView(tireSet: fixtures.tireSet)
        }
    }
}
#endif
