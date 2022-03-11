//
//  OdometerReadingView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
//

import SwiftUI

struct OdometerReadingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var odometerReading: OdometerReading
    
    var body: some View {
        Form {
            DatePicker(
                "Performed",
                selection: convertToNonNilBinding(date: $odometerReading.at),
                displayedComponents: [.date]
            )
            FleetboxTextField(
                value: convertToNillableBinding(string: convertToStringBinding(int64: $odometerReading.reading)),
                name: "Odometer reading in miles",
                example: "1000"
            )
                .unit("miles")
                .keyboardType(.decimalPad)
        }
    }
}

struct OdometerReadingView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            OdometerReadingView(odometerReading: PersistenceController.preview.fixtures.odometerReading)
        }
    }
}
