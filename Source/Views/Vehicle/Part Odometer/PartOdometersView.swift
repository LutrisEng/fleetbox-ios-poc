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

struct PartOdometersView: View {
    @Environment(\.editable) private var editable

    @ObservedObject var vehicle: Vehicle

    @State private var _vehicleOdometer: Int64?
    private var vehicleOdometer: Int64 {
        if let vehicleOdometer = _vehicleOdometer {
            return vehicleOdometer
        } else {
            let odo = vehicle.approximateOdometer
            DispatchQueue.main.async {
                if _vehicleOdometer == nil {
                    _vehicleOdometer = odo
                }
            }
            return odo
        }
    }

    var roundedMilesPerYear: Int64? {
        if let calculated = vehicle.calculatedAverageMilesPerYear {
            return calculated - (calculated % 1000)
        } else {
            return nil
        }
    }

    var milesPerYearDescription: LocalizedStringKey? {
        if let roundedMilesPerYear = roundedMilesPerYear {
            let formatted = Formatter.format(number: roundedMilesPerYear)
            return (
                "Fleetbox has estimated that you drive this vehicle about \(formatted) miles in a year."
            )
        } else {
            return nil
        }
    }

    var body: some View {
        Section(header: Text("Odometer")) {
            if editable {
                NavigationLink(
                    destination: {
                        OdometerReadingFormView(vehicle: vehicle)
                    },
                    label: {
                        Text("\(Image(systemName: "plus")) Add odometer reading")
                            .foregroundColor(.accentColor)
                    }
                )
            }
            if let lastReading = vehicle.odometerReadings.chrono.last {
                let timeLine: String = {
                    if let lastReadingAt = lastReading.at {
                        return "\n" + Formatter.format(
                            durationLabel: Date.now.timeIntervalSinceReferenceDate -
                                lastReadingAt.timeIntervalSinceReferenceDate
                        ) + " ago"
                    } else {
                        return ""
                    }
                }()
                FormLinkLabel(
                    title: "Last reading",
                    value: "\(Formatter.format(number: lastReading.reading)) miles\(timeLine)"
                )
            }
            FleetboxTextField(
                value: $vehicle.milesPerYear,
                name: "Est. distance per year",
                example: roundedMilesPerYear ?? 12000,
                description: milesPerYearDescription
            )
            .unit("miles/year")
            FormLinkLabel(
                title: "Est. current reading",
                value: "\(Formatter.format(number: vehicleOdometer)) miles"
            )
            NavigationLink("View history") {
                OdometerReadingsView(vehicle: vehicle)
                    .navigationTitle("Odometer readings")
            }
        }
        .onChange(of: vehicle.approximateOdometer) { newOdometer in
            // Cache the vehicle odometer to reduce time spent calculating it
            _vehicleOdometer = newOdometer
        }
        let partOdometers = partOdometers.filter { $0.shouldShow(vehicle: vehicle) }
        if vehicle.currentTireSet != nil || !partOdometers.isEmpty {
            Section(header: Text("Part Odometers")) {
                if let tires = vehicle.currentTireSet {
                    PartOdometerRowView(
                        name: "Tires",
                        milesSince: tires.approximateOdometer,
                        timeSince: tires.age
                    )
                }
                ForEach(partOdometers) { odometer in
                    odometer.view(vehicle: vehicle)
                }
            }
        }
    }
}

#if DEBUG
struct PartOdometersView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            PartOdometersView(vehicle: fixtures.vehicle)
        }
    }
}
#endif
