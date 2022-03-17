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

struct ShopView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var shop: Shop

    var body: some View {
        Form {
            FleetboxTextField(value: $shop.name, name: "Name", example: "Quick Lube of Anytown USA")
            let vehicles = shop.vehicles
            if !vehicles.isEmpty {
                Section(header: Text("Performed service on")) {
                    ForEach(shop.vehicles) { vehicle in
                        NavigationLink(vehicle.displayNameWithFallback) {
                            VehicleView(vehicle: vehicle)
                        }
                    }
                }
            }
            let logItems = shop.logItemsInverseChrono
            if !logItems.isEmpty {
                Section(header: Text("Log items")) {
                    ForEach(shop.logItemsInverseChrono) { logItem in
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
            Section(header: Text("Actions")) {
                NavigationLink("Merge with other shop") {
                    ShopPickerView(
                        selected: nil,
                        exclude: [shop]
                    ) {
                        shop.mergeWith($0)
                    }
                    .navigationTitle("Merge shops")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
        .modifier(WithDoneButton())
        .modifier(SaveOnLeave())
        .navigationTitle("Shop")
    }
}

#if DEBUG
struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            ShopView(shop: fixtures.shop)
        }
    }
}
#endif
