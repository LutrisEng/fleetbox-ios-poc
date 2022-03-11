//
//  VehicleView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/3/22.
//

import SwiftUI
import Sentry

struct VehicleView: View {
    struct VehicleDetails: View {
        struct VINDetail: View {
            @ObservedObject var vehicle: Vehicle
            @State private var state: ViewState = .base
            @State private var err: Bool = false
            
            enum ViewState {
                case base, loading, ok, err
            }
            
            var body: some View {
                HStack {
                    FleetboxTextField(value: $vehicle.vin, name: "VIN", example: dummyData.vin)
                    if let vin = vehicle.vin, vin != "" {
                        switch state {
                        case .base:
                            Button(
                                action: {
                                    Task.init {
                                        state = .loading
                                        do {
                                            // TODO: error dialog
                                            let decoderResult = try await decodeVIN(vin)
                                            if decoderResult.errorCode != 0 {
                                                print("error code", decoderResult.errorCode)
                                                state = .err
                                                err = true
                                                await ignoreErrors {
                                                    try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
                                                }
                                                state = .base
                                                return
                                            }
                                            if let modelYear = decoderResult.modelYear {
                                                vehicle.year = Int64(modelYear)
                                            }
                                            vehicle.make = decoderResult.make ?? vehicle.make
                                            vehicle.model = decoderResult.model ?? vehicle.model
                                        } catch {
                                            SentrySDK.capture(error: error)
                                            state = .err
                                            err = true
                                            await ignoreErrors {
                                                try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
                                            }
                                            state = .base
                                            return
                                        }
                                        state = .ok
                                        await ignoreErrors {
                                            try await Task.sleep(nanoseconds: 3 * UInt64(NSEC_PER_SEC))
                                        }
                                        state = .base
                                    }
                                }
                            ) {
                                Image(systemName: "square.and.arrow.down")
                            }
                            .padding(.trailing, 8)
                            .frame(width: 30)
                            .buttonStyle(BorderlessButtonStyle())
                        case .loading:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding(.trailing, 8)
                                .frame(width: 30)
                        case .ok:
                            Image(systemName: "checkmark")
                                .padding(.trailing, 8)
                                .frame(width: 30)
                                .foregroundColor(.green)
                        case .err:
                            Image(systemName: "xmark")
                                .padding(.trailing, 8)
                                .frame(width: 30)
                                .foregroundColor(.red)
                        }
                    }
                }
                .alert("Failed to decode VIN", isPresented: $err, actions: {}) {
                    Text("An error occurred while decoding your VIN. Check to make sure you typed your VIN correctly, and check your network connection.")
                }
            }
        }
        
        struct TireDetail: View {
            @ObservedObject var tireSet: TireSet
            
            var body: some View {
                NavigationLink(destination: { TireSetView(tireSet: tireSet) }) {
                    HStack {
                        Text("Tires")
                        Spacer()
                        Text(tireSet.displayName)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        
        @ObservedObject var vehicle: Vehicle
        
        var body: some View {
            Section(header: Text("Vehicle details")) {
                FleetboxTextField(value: $vehicle.displayName, name: "Name", example: dummyData.vehicleName)
                VINDetail(vehicle: vehicle)
                FleetboxTextField(value: $vehicle.make, name: "Make", example: dummyData.vehicleMake)
                FleetboxTextField(value: $vehicle.model, name: "Model", example: dummyData.vehicleModel)
                if let tireSet = vehicle.currentTireSet {
                    TireDetail(tireSet: tireSet)
                }
            }
        }
    }
    
    struct PartOdometers: View {
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
        
        struct OdometerReadingRow: View {
            let name: String
            let reading: Int64
            
            var body: some View {
                HStack {
                    Text(name)
                    Spacer()
                    Text("\(reading) miles")
                        .foregroundColor(.secondary)
                }
            }
        }
        
        struct LineItem: View {
            @ObservedObject var vehicle: Vehicle
            let lineItemType: String
            let name: String
            
            var body: some View {
                if let milesSince = vehicle.milesSince(lineItemType: lineItemType) {
                    OdometerReadingRow(name: name, reading: milesSince)
                }
            }
        }
        
        struct FluidFilter: View {
            @ObservedObject var vehicle: Vehicle
            let fluidLineItemType: String
            let filterLineItemType: String
            let fluidName: String
            
            var body: some View {
                let milesSinceFluid = vehicle.milesSince(lineItemType: fluidLineItemType)
                let milesSinceFilter = vehicle.milesSince(lineItemType: filterLineItemType)
                if let milesSinceFluid = milesSinceFluid, let milesSinceFilter = milesSinceFilter, milesSinceFluid == milesSinceFilter {
                    OdometerReadingRow(name: "\(fluidName) & filter", reading: milesSinceFluid)
                } else {
                    if let milesSinceFluid = milesSinceFluid {
                        OdometerReadingRow(name: fluidName, reading: milesSinceFluid)
                    }
                    if let milesSinceFilter = milesSinceFilter {
                        OdometerReadingRow(name: "\(fluidName) filter", reading: milesSinceFilter)
                    }
                }
            }
        }
        
        struct OdometerReadingForm: View {
            let currentReading: Int64
            let onSubmit: (Int64) -> ()
            let onDismiss: () -> ()
            @StateObject private var reading = NumbersOnly()
            
            var body: some View {
                Form {
                    OdometerReadingRow(name: "Current", reading: currentReading)
                    HStack {
                        TextField("Odometer reading in miles", text: $reading.value)
                            .keyboardType(.decimalPad)
                        Spacer()
                        Text("miles")
                    }
                    Button("Save", action: { onSubmit(reading.numericValue) })
                    Button("Cancel", action: onDismiss)
                }
                .onAppear {
                    reading.numericValue = currentReading
                }
            }
        }
        
        @Environment(\.managedObjectContext) private var viewContext
        
        @ObservedObject var vehicle: Vehicle
        
        @State private var createPresented: Bool = false
        @StateObject private var createReading = NumbersOnly()
        
        var body: some View {
            Section(header: Text("Odometer")) {
                Button("Record odometer reading") {
                    createPresented = true
                }
                .sheet(isPresented: $createPresented) {
                    OdometerReadingForm(currentReading: vehicle.odometer) { value in
                        let reading = OdometerReading(context: viewContext)
                        reading.vehicle = vehicle
                        reading.at = Date.now
                        reading.reading = value
                        ignoreErrors {
                            try viewContext.save()
                        }
                        createPresented = false
                    } onDismiss: {
                        createPresented = false
                    }
                }
                NavigationLink("View odometer readings") {
                    OdometerReadingsView(vehicle: vehicle)
                }
                OdometerReadingRow(name: "Vehicle", reading: vehicle.odometer)
                if let tires = vehicle.currentTireSet {
                    OdometerReadingRow(name: "Tires", reading: tires.odometer)
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
                        LineItem(vehicle: vehicle, lineItemType: lineItemType, name: name)
                    case .fluidFilter(let fluidLineItemType, let filterLineItemType, let fluidName):
                        FluidFilter(vehicle: vehicle, fluidLineItemType: fluidLineItemType, filterLineItemType: filterLineItemType, fluidName: fluidName)
                    }
                }
            }
        }
    }
    
    struct MaintenanceLog: View {
        @Environment(\.managedObjectContext) private var viewContext
        
        @ObservedObject var vehicle: Vehicle
        
        var body: some View {
            Section(header: Text("Maintenance log")) {
                let logItems = vehicle.logItemsInverseChrono
                ForEach(logItems, id: \.self) { logItem in
                    NavigationLink(destination: LogItemView(logItem: logItem)) {
                        LogItemLabelView(logItem: logItem).padding([.top, .bottom], 10)
                    }
                }.onDelete { offsets in
                    withAnimation {
                        offsets.map { logItems[$0] }.forEach(viewContext.delete)
                        
                        ignoreErrors {
                            try viewContext.save()
                        }
                    }
                }
            }
        }
    }
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var vehicle: Vehicle
    
    var body: some View {
        VStack {
            Form {
                VehicleDetails(vehicle: vehicle)
                PartOdometers(vehicle: vehicle)
                MaintenanceLog(vehicle: vehicle)
            }
        }.navigationTitle(vehicle.fullModelName)
    }
}

struct VehicleView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            VehicleView(vehicle: PersistenceController.preview.fixtures.vehicle)
        }
    }
}
