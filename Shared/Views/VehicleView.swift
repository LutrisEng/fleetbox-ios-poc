//
//  VehicleView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/3/22.
//

import SwiftUI
import Sentry

struct VehicleView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var vehicle: Vehicle
    
    @State private var odometerReadingSheetPresented = false
    @State private var shouldDeleteOdometerReading = false
    @State private var odometerReadingSheetOdometerReading: OdometerReading? = nil
    
    func createOdometerReading() -> OdometerReading {
        let reading = OdometerReading(context: viewContext)
        reading.at = Date.now
        return reading
    }
    
    var body: some View {
        VStack {
            if vehicle.displayName != nil {
                VStack {
                    Text(vehicle.fullModelName)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.subheadline)
                }.padding()
            }
            List {
                Section(header: Text("Odometer")) {
                    Button("Record odometer reading") {
                        odometerReadingSheetOdometerReading = createOdometerReading()
                        odometerReadingSheetPresented = true
                        shouldDeleteOdometerReading = true
                    }
                    Text("Vehicle odometer: \(vehicle.odometer) miles")
                    if let tires = vehicle.currentTireSet {
                        Text("Tires: \(tires.odometer) miles")
                    }
                    let milesSinceOilChange = vehicle.milesSince(lineItemType: "engineOilChange")
                    let milesSinceOilFilterChange = vehicle.milesSince(lineItemType: "engineOilFilterChange")
                    if let milesSinceOilChange = milesSinceOilChange, let milesSinceOilFilterChange = milesSinceOilFilterChange, milesSinceOilChange == milesSinceOilFilterChange {
                        Text("Oil & filter: \(milesSinceOilChange) miles")
                    } else {
                        if let milesSinceOilChange = milesSinceOilChange {
                            Text("Oil: \(milesSinceOilChange)")
                        }
                        if let milesSinceOilFilterChange = milesSinceOilFilterChange {
                            Text("Oil filter: \(milesSinceOilFilterChange)")
                        }
                    }
                }
                Section(header: Text("Maintenance log")) {
                    let logItems = vehicle.logItemsInverseChrono
                    ForEach(logItems, id: \.self) { logItem in
                        NavigationLink(destination: LogItemView(logItem: logItem)) {
                            LogItemLabelView(logItem: logItem)
                        }
                    }.onDelete { offsets in
                        withAnimation {
                            offsets.map { logItems[$0] }.forEach(viewContext.delete)

                            do {
                                try viewContext.save()
                            } catch {
                                SentrySDK.capture(error: error)
                                // Replace this implementation with code to handle the error appropriately.
                                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
                        }
                    }
                }
            }
        }.navigationTitle(vehicle.displayNameWithFallback)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink("Edit") {
                        Text("test")
                    }
                }
            }
            .sheet(isPresented: $odometerReadingSheetPresented, onDismiss: {
                if shouldDeleteOdometerReading {
                    if let r = odometerReadingSheetOdometerReading {
                        viewContext.delete(r)
                    }
                } else {
                    try? viewContext.save()
                }
            }) {
                if let reading = odometerReadingSheetOdometerReading {
                    VStack {
                        OdometerReadingView(odometerReading: reading) {
                            reading.vehicle = vehicle
                            shouldDeleteOdometerReading = false
                            odometerReadingSheetPresented = false
                            try? viewContext.save()
                        }
                    }.padding()
                }
            }
    }
}

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        return NavigationView {
            VehicleView(vehicle: PersistenceController.preview.fixtures.vehicle)
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
