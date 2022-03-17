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

struct OdometerReadingsView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var vehicle: Vehicle

    var body: some View {
        List {
            let odometerReadings = vehicle.odometerReadingsInverseChrono
            ForEach(odometerReadings, id: \.self) { odometerReading in
                NavigationLink(
                    destination: {
                        OdometerReadingView(odometerReading: odometerReading)
                    },
                    label: {
                        if let logItem = odometerReading.logItem {
                            LogItemLabelView(logItem: logItem)
                        } else {
                            VStack {
                                Text("\(odometerReading.reading) miles")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(
                                    odometerReading.at?.formatted(date: .abbreviated, time: .omitted)
                                    ?? "Odometer reading"
                                )
                                .font(.body.bold())
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding([.top, .bottom], 10)
                        }
                    }
                )
            }
            .onDelete { offsets in
                withAnimation {
                    offsets
                        .map { odometerReadings[$0] }
                        .forEach(viewContext.delete)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
        }
        .navigationTitle("Odometer readings")
    }
}

#if DEBUG
struct OdometerReadingsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            OdometerReadingsView(vehicle: fixtures.vehicle)
        }
    }
}
#endif
