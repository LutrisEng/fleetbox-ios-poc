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

struct OdometerReadingFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var vehicle: Vehicle
    @State private var initialized = false
    @State private var reading: Int64 = 0

    var body: some View {
        Form {
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
                value: $reading,
                name: "Current reading",
                example: vehicle.approximateOdometer
            )
            .unit("miles")
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: save) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
            }
        }
        .navigationTitle("Odometer reading")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !initialized {
                reading = vehicle.approximateOdometer
                initialized = true
            }
        }
    }

    func save() {
        let reading = OdometerReading(context: viewContext)
        reading.at = Date.now
        reading.vehicle = vehicle
        reading.reading = self.reading
        ignoreErrors {
            try viewContext.save()
        }
        dismiss()
    }
}

#if DEBUG
struct OdometerReadingFormView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            OdometerReadingFormView(vehicle: fixtures.vehicle)
        }
    }
}
#endif
