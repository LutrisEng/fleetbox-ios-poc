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

struct WarrantiesView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var warranties: [Warranty]
    let vehicle: Vehicle?
    let tireSet: TireSet?

    @State private var creatingWarranty: Warranty?

    init(warranties: [Warranty], vehicle: Vehicle) {
        self.warranties = warranties
        self.vehicle = vehicle
        self.tireSet = nil
    }

    init(warranties: [Warranty], tireSet: TireSet) {
        self.warranties = warranties
        self.vehicle = nil
        self.tireSet = tireSet
    }

    init(warranties: [Warranty]) {
        self.warranties = warranties
        self.vehicle = nil
        self.tireSet = nil
    }

    var body: some View {
        Section(header: Text("Warranties")) {
            ForEach(warranties) { warranty in
                WarrantyListingView(warranty: warranty)
            }
            .onDelete(deleteFrom: warranties, context: viewContext)
            if vehicle != nil || tireSet != nil {
                NavigationLink(
                    destination: {
                        Group {
                            if let creatingWarranty = creatingWarranty {
                                WarrantyView(warranty: creatingWarranty)
                            } else {
                                ProgressView()
                            }
                        }
                        .onAppear {
                            if let vehicle = vehicle {
                                creatingWarranty = Warranty(context: viewContext, vehicle: vehicle)
                            } else if let tireSet = tireSet {
                                creatingWarranty = Warranty(context: viewContext, tireSet: tireSet)
                            }
                        }
                    },
                    label: {
                        Text("\(Image(systemName: "plus")) Add warranty")
                            .foregroundColor(.accentColor)
                    }
                )
            }
        }
    }
}
