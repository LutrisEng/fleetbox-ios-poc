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

struct OdometerReadingView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var odometerReading: OdometerReading

    var body: some View {
        Form {
            DatePicker(
                    "Performed",
                    selection: convertToNonNilBinding(date: $odometerReading.at),
                    displayedComponents: [.date]
            )
            FleetboxTextField(
                    value: Binding(
                        get: { odometerReading.reading },
                        set: { odometerReading.reading = $0 }
                    ),
                    name: "Odometer reading in miles",
                    example: 1000
            )
                    .unit("miles")
        }
        .modifier(WithDoneButton())
    }
}

#if DEBUG
struct OdometerReadingView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            OdometerReadingView(odometerReading: fixtures.odometerReading)
        }
    }
}
#endif
