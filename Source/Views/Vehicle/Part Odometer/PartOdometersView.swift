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
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var vehicle: Vehicle

    @State private var createPresented: Bool = false
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
    @StateObject private var createReading = NumbersOnly()

    var breakinBadge: Badge? {
        if vehicle.breakin != 0 {
            let odo = vehicle.odometer
            if odo > vehicle.breakin {
                return .success
            } else {
                return .warning
            }
        }
        return nil
    }

    var breakinPercentage: String? {
        if let progress = breakinProgress {
            return "About \(Formatter.format(wholePercentage: progress)) complete"
        } else {
            return nil
        }
    }

    var breakinProgress: Double? {
        if vehicle.breakin != 0 && vehicleOdometer <= vehicle.breakin {
            return Double(vehicleOdometer) / Double(vehicle.breakin)
        } else {
            return nil
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
                Button(
                    action: {
                        createPresented = true
                    },
                    label: {
                        Text("\(Image(systemName: "plus")) Add odometer reading")
                            .foregroundColor(.accentColor)
                    }
                )
                .sheet(isPresented: $createPresented) {
                    NavigationView {
                        OdometerReadingFormView(previousReading: vehicleOdometer) { value in
                            let reading = OdometerReading(context: viewContext)
                            reading.vehicle = vehicle
                            reading.at = Date.now
                            reading.reading = value
                            createPresented = false
                        } onDismiss: {
                            createPresented = false
                        }
                    }
                }
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
            FleetboxTextField(value: $vehicle.breakin, name: "Break-in period", example: 1000)
                .unit("miles")
                .badge(breakinBadge)
                .caption(breakinPercentage)
                .progress(breakinProgress)
                .progressColor((breakinProgress ?? 0) < 1 ? .yellow : .green)
            if let tireSet = vehicle.currentTireSet {
                FormLinkLabel(
                    title: "Tire break-in period",
                    value: "\(Formatter.format(number: tireSet.breakin)) miles"
                )
                .badge(tireSet.breakinBadge)
                .caption(tireSet.breakinPercentage)
                .progress(tireSet.breakinProgress)
                .progressColor((tireSet.breakinProgress ?? 0) < 1 ? .yellow : .green)
            }
        }
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
        .onChange(of: vehicle.approximateOdometer) { newOdometer in
            // Cache the vehicle odometer to reduce time spent calculating it
            _vehicleOdometer = newOdometer
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
