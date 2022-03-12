//
//  PartOdometersView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct PartOdometersView: View {
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
                        OdometerReadingFormView(currentReading: vehicle.odometer) { value in
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
            PartOdometerRowView(name: "Vehicle", reading: vehicle.odometer)
            if let tires = vehicle.currentTireSet {
                PartOdometerRowView(name: "Tires", reading: tires.odometer)
            }
            ForEach(partOdometers) { odometer in
                odometer.view(vehicle: vehicle)
            }
        }
    }
}

struct PartOdometersView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            PartOdometersView(vehicle: fixtures.vehicle)
        }
    }
}
