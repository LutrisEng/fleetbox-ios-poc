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
    @State private var vinLoading = false
    
    func createOdometerReading() -> OdometerReading {
        let reading = OdometerReading(context: viewContext)
        reading.at = Date.now
        return reading
    }
    
    enum ReadOdometer : Identifiable {
        case lineItem(lineItemType: String, name: String)
        case fluidFilter(fluidLineItemType: String, filterLineItemType: String, fluidName: String)
        
        var id: String {
            switch self {
            case .lineItem(let t, let n): return "lineItem:\(t):\(n)"
            case .fluidFilter(let ta, let tb, let n): return "lineItem:\(ta):\(tb):\(n)"
            }
        }
    }
    
    struct LineItemOdometerReading: View {
        @ObservedObject var vehicle: Vehicle
        let lineItemType: String
        let name: String
        
        var body: some View {
            if let milesSince = vehicle.milesSince(lineItemType: lineItemType) {
                Text("\(name): \(milesSince) miles")
            }
        }
    }
    
    struct FluidFilterLineItemOdometerReading: View {
        @ObservedObject var vehicle: Vehicle
        let fluidLineItemType: String
        let filterLineItemType: String
        let fluidName: String
        
        var body: some View {
            let milesSinceFluid = vehicle.milesSince(lineItemType: fluidLineItemType)
            let milesSinceFilter = vehicle.milesSince(lineItemType: filterLineItemType)
            if let milesSinceFluid = milesSinceFluid, let milesSinceFilter = milesSinceFilter, milesSinceFluid == milesSinceFilter {
                Text("\(fluidName) & filter: \(milesSinceFluid) miles")
            } else {
                if let milesSinceFluid = milesSinceFluid {
                    Text("\(fluidName): \(milesSinceFluid) miles")
                }
                if let milesSinceFilter = milesSinceFilter {
                    Text("\(fluidName) filter: \(milesSinceFilter) miles")
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Vehicle details")) {
                    FleetboxTextField(value: $vehicle.displayName, name: "Name", example: dummyData.vehicleName)
                    HStack {
                        FleetboxTextField(value: $vehicle.vin, name: "VIN", example: dummyData.vin)
                        if let vin = vehicle.vin, vin != "" {
                            if vinLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Button(
                                    action: {
                                        Task.init {
                                            vinLoading = true
                                            await ignoreErrors {
                                                // TODO: error dialog
                                                let decoderResult = try await decodeVIN(vin)
                                                if let modelYear = decoderResult.modelYear {
                                                    vehicle.year = Int64(modelYear)
                                                }
                                                vehicle.make = decoderResult.make ?? vehicle.make
                                                vehicle.model = decoderResult.model ?? vehicle.model
                                            }
                                            vinLoading = false
                                        }
                                    }
                                ) {
                                    Image(systemName: "square.and.arrow.down")
                                }
                                .padding(.trailing, 8)
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                    }
                    FleetboxTextField(value: $vehicle.make, name: "Make", example: dummyData.vehicleMake)
                    FleetboxTextField(value: $vehicle.model, name: "Model", example: dummyData.vehicleModel)
                }
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
                    let odometers: [ReadOdometer] = [
                        .fluidFilter(
                            fluidLineItemType: "engineOilChange",
                            filterLineItemType: "engineOilFilterChange",
                            fluidName: "Oil"
                        ),
                        .fluidFilter(
                            fluidLineItemType: "transmissionFluidChange",
                            filterLineItemType: "transmissionFluidFilterChange",
                            fluidName: "Transmission fluid"
                        ),
                        .lineItem(
                            lineItemType: "brakeFluidChange",
                            name: "Brake fluid"
                        ),
                        .lineItem(
                            lineItemType: "coolantChange",
                            name: "Coolant"
                        ),
                        .lineItem(
                            lineItemType: "sparkPlugReplacement",
                            name: "Spark plugs"
                        ),
                        .lineItem(
                            lineItemType: "batteryReplacement",
                            name: "12V battery"
                        ),
                        .lineItem(
                            lineItemType: "hvBatteryReplacement",
                            name: "High-voltage battery"
                        ),
                        .lineItem(
                            lineItemType: "engineAirFilterChange",
                            name: "Engine air filter"
                        ),
                        .lineItem(
                            lineItemType: "cabinAirFilterChange",
                            name: "Cabin air filter"
                        )
                    ]
                    ForEach(odometers) { x in
                        switch x {
                        case .lineItem(let lineItemType, let name):
                            LineItemOdometerReading(vehicle: vehicle, lineItemType: lineItemType, name: name)
                        case .fluidFilter(let fluidLineItemType, let filterLineItemType, let fluidName):
                            FluidFilterLineItemOdometerReading(vehicle: vehicle, fluidLineItemType: fluidLineItemType, filterLineItemType: filterLineItemType, fluidName: fluidName)
                        }
                    }
                }
                Section(header: Text("Maintenance log")) {
                    let logItems = vehicle.logItemsInverseChrono
                    ForEach(logItems, id: \.self) { logItem in
                        NavigationLink(destination: LogItemView(logItem: logItem)) {
                            LogItemLabelView(logItem: logItem).padding([.top, .bottom], 10)
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
        }.navigationTitle(vehicle.fullModelName)
            .toolbar {
//                ToolbarItem(placement: .primaryAction) {
//                    NavigationLink("Edit") {
//                        Text("test")
//                    }
//                }
            }
            .sheet(isPresented: $odometerReadingSheetPresented, onDismiss: {
                if shouldDeleteOdometerReading {
                    if let r = odometerReadingSheetOdometerReading {
                        viewContext.delete(r)
                    }
                } else {
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
            }) {
                if let reading = odometerReadingSheetOdometerReading {
                    VStack {
                        OdometerReadingView(odometerReading: reading) {
                            reading.vehicle = vehicle
                            shouldDeleteOdometerReading = false
                            odometerReadingSheetPresented = false
                            ignoreErrors {
                                try viewContext.save()
                            }
                        }
                    }.padding()
                }
            }
    }
}

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            VehicleView(vehicle: PersistenceController.preview.fixtures.vehicle)
        }
    }
}
