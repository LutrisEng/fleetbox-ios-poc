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

struct VehicleLabelView: View {
    @ObservedObject var vehicle: Vehicle

    @State private var image: UIImage?

    var additionalDetails: Text {
        Text("\(Formatter.format(number: vehicle.approximateOdometer)) miles")
    }

    var body: some View {
        VStack(alignment: .leading) {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(20)
                    .frame(maxWidth: 200)
            }
            if let displayName = vehicle.displayName {
                (
                    Text(displayName).font(.body.bold()) +
                        Text("\n") +
                        (
                            Text(vehicle.fullModelName) +
                            Text(", ") +
                            additionalDetails
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                )
                .multilineTextAlignment(.leading)
            } else {
                (
                    Text(vehicle.fullModelName).font(.body.bold()) +
                        Text("\n") +
                        additionalDetails
                            .font(.caption)
                            .foregroundColor(.secondary)
                )
                .multilineTextAlignment(.leading)
            }
        }
        .onAppear {
            self.image = vehicle.image
        }
        .onChange(of: vehicle.imageData) { _ in
            self.image = vehicle.image
        }
    }
}
