//
//  OdometerReadingFormView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct OdometerReadingFormView: View {
    let currentReading: Int64
    let onSubmit: (Int64) -> ()
    let onDismiss: () -> ()
    @StateObject private var reading = NumbersOnly()
    
    var body: some View {
        Form {
            PartOdometerRowView(name: "Current", reading: currentReading)
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

struct OdometerReadingFormView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            OdometerReadingFormView(currentReading: 1000, onSubmit: { _ in }, onDismiss: {})
        }
    }
}
