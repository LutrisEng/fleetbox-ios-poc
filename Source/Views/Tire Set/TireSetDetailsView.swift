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

struct TireSetDetailsView: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var tireSet: TireSet

    var body: some View {
        FleetboxTextField(value: $tireSet.userDisplayName, name: "Name", example: "My Summer Tires")
        FleetboxTextField(value: $tireSet.make, name: "Make", example: "TireCo")
        FleetboxTextField(value: $tireSet.model, name: "Model", example: "Aviator Sport")
        FleetboxTextField(value: $tireSet.tin, name: "TIN", example: "DOT U2LL LMLR5107")
        if editable {
            if tireSet.hidden {
                Button("Un-hide") {
                    tireSet.hidden = false
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
            } else {
                Button("Hide") {
                    tireSet.hidden = true
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
            }
        }
    }
}
