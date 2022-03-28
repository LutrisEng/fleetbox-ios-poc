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

struct MaintenanceLogView: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var vehicle: Vehicle

    var body: some View {
        Section(header: Text("Maintenance log")) {
            if editable {
                NavigationLink(
                    destination: {
                        NewLogItemView(vehicle: vehicle)
                    },
                    label: {
                        Text("\(Image(systemName: "plus")) Add log item")
                            .foregroundColor(.accentColor)
                    }
                )
            }
            let logItems = vehicle.logItems.inverseChrono
            if logItems.isEmpty {
                Text("Empty")
                    .foregroundColor(.secondary)
            } else {
                ForEach(logItems, id: \.self) { logItem in
                    NavigationLink(destination: LogItemView(logItem: logItem)) {
                        LogItemLabelView(logItem: logItem)
                    }
                }
                .onDelete(deleteFrom: logItems, context: viewContext)
                .deleteDisabled(!editable)
            }
        }
    }
}

#if DEBUG
struct MaintenanceLogView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            Form {
                MaintenanceLogView(vehicle: fixtures.vehicle)
            }
        }
    }
}
#endif
