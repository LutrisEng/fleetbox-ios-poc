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
    let previousReading: Int64
    let onSubmit: (Int64) -> Void
    let onDismiss: () -> Void
    @State private var reading: Int64 = 0

    var body: some View {
        Form {
            PartOdometerRowView(name: "Previous", reading: previousReading)
            FleetboxTextField(
                value: convertToNillableBinding(string: convertToStringBinding(int64: $reading)),
                name: "Current",
                example: "0"
            )
            .unit("miles")
            Button("Save", action: { onSubmit(reading) })
            Button("Cancel", action: onDismiss)
        }
                .onAppear {
                    reading = previousReading
                }
    }
}

struct OdometerReadingFormView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            OdometerReadingFormView(previousReading: 1000, onSubmit: { _ in }, onDismiss: {})
        }
    }
}
