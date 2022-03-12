//
//  MaintenanceLogView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct MaintenanceLogView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var vehicle: Vehicle

    var body: some View {
        Section(header: Text("Maintenance log")) {
            let logItems = vehicle.logItemsInverseChrono
            ForEach(logItems, id: \.self) { logItem in
                NavigationLink(destination: LogItemView(logItem: logItem)) {
                    LogItemLabelView(logItem: logItem).padding([.top, .bottom], 10)
                }
            }
                    .onDelete { offsets in
                        withAnimation {
                            offsets.map {
                                        logItems[$0]
                                    }
                                    .forEach(viewContext.delete)

                            ignoreErrors {
                                try viewContext.save()
                            }
                        }
                    }
        }
    }
}

struct MaintenanceLogView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            Form {
                MaintenanceLogView(vehicle: fixtures.vehicle)
            }
        }
    }
}
