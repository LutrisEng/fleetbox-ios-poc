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

struct LogItemLabelView: View {
    @ObservedObject var logItem: LogItem
    let showVehicle: Bool

    init(logItem: LogItem, showVehicle: Bool = false) {
        self.logItem = logItem
        self.showVehicle = showVehicle
    }

    var body: some View {
        VStack {
            if showVehicle, let vehicle = logItem.vehicle {
                Text(vehicle.displayNameWithFallback)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let odometerReading = logItem.odometerReading {
                Text("\(odometerReading.reading) miles")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let displayName = logItem.displayName, !displayName.isEmpty {
                Text(displayName)
                        .font(.body.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
                if let formattedDate = logItem.formattedDate {
                    Text(formattedDate)
                            .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                Text(logItem.formattedDate ?? "Log item")
                        .font(.body.bold())
                        .frame(maxWidth: .infinity, alignment: .leading)
            }
            if let shop = logItem.shop {
                Text("Performed by \(shop.name ?? "a shop")")
                        .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Performed by owner")
                        .frame(maxWidth: .infinity, alignment: .leading)
            }
            ForEach(logItem.lineItems) { lineItem in
                LineItemLabelView(lineItem: lineItem).mini
            }
        }
        .padding([.top, .bottom], 10)
    }
}

#if DEBUG
struct LogItemLabelView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            List {
                LogItemLabelView(logItem: fixtures.logItem)
            }
        }
    }
}
#endif
