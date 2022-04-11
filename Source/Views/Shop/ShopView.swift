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
    @Environment(\.editable) private var editable

    @ObservedObject var shop: Shop

    var body: some View {
        Form {
            FleetboxTextField(value: $shop.name, name: "Name", example: "Quick Lube of Anytown USA")
                .autocapitalization(.words)
            HStack {
                FleetboxTextField(value: $shop.location, name: "Location", example: "Anytown, USA")
                    .autocapitalization(.words)
                if let mapURL = shop.mapURL {
                    Link(
                        destination: mapURL,
                        label: {
                            Label("Open map", systemImage: "map")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.accentColor)
                        }
                    )
                    .buttonStyle(.plain)
                }
            }
            HStack {
                FleetboxTextField(value: $shop.email, name: "Email Address", example: "quicklube@example.com")
                    .allowNewline(false)
                    .autocapitalization(.never)
                    .keyboard(.emailAddress)
                    .autocorrection(false)
                if let emailURL = shop.emailURL {
                    Link(
                        destination: emailURL,
                        label: {
                            Label("Send an email", systemImage: "envelope")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.accentColor)
                        }
                    )
                    .buttonStyle(.plain)
                }
            }
            HStack {
                FleetboxTextField(
                    value: phoneNumberBinding(string: $shop.phoneNumber),
                    name: "Phone Number",
                    example: "123-555-9876"
                )
                .allowNewline(false)
                .autocapitalization(.never)
                .keyboard(.phonePad)
                .autocorrection(false)
                if let phoneURL = shop.phoneURL {
                    Link(
                        destination: phoneURL,
                        label: {
                            Label("Call", systemImage: "phone")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.accentColor)
                        }
                    )
                    .buttonStyle(.plain)
                }
                if let smsURL = shop.smsURL {
                    Link(
                        destination: smsURL,
                        label: {
                            Label("Send a message", systemImage: "bubble.left")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.accentColor)
                        }
                    )
                    .buttonStyle(.plain)
                }
            }
            HStack {
                FleetboxTextField(value: $shop.url, name: "Website", example: "https://quicklube.example.com")
                    .allowNewline(false)
                    .autocapitalization(.never)
                    .keyboard(.URL)
                    .autocorrection(false)
                if let url = shop.urlURL {
                    Link(
                        destination: url,
                        label: {
                            Label("Visit website", systemImage: "globe")
                                .labelStyle(.iconOnly)
                                .foregroundColor(.accentColor)
                        }
                    )
                    .buttonStyle(.plain)
                }
            }
            Section(header: Text("Notes")) {
                TextEditor(text: convertToNonNilBinding(string: $shop.notes))
            }
            if !shop.vehicles.isEmpty {
                Section(header: Text("Performed service on")) {
                    ForEachObjects(shop.vehicles, allowDelete: false, allowMove: false) { vehicle in
                        NavigationLink(
                            destination: {
                                VehicleView(vehicle: vehicle)
                            },
                            label: {
                                VehicleLabelView(vehicle: vehicle)
                            }
                        )
                    }
                }
            }
            if !shop.logItems.isEmpty {
                Section(header: Text("Log items")) {
                    ForEach(shop.logItems.inverseChrono, id: \.self) { logItem in
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
                    NavigationLink("Merge with other shop") {
                        ShopPickerView(
                            selected: nil,
                            exclude: [shop]
                        ) { other in
                            withAnimation {
                                shop.mergeWith(other)
                                ignoreErrors {
                                    try viewContext.save()
                                }
                            }
                        }
                        .navigationTitle("Merge shops")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
        }
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
