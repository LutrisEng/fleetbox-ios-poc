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
    
    let onSave: () -> ()
    
    @ObservedObject private var editingReading = NumbersOnly()
    
    var body: some View {
        VStack {
            Form {
                TextField("Odometer reading in miles", text: $editingReading.value)
                    .keyboardType(.decimalPad)
            }
            Spacer()
            Button("Save", action: saveReading)
        }
        .padding()
        .onAppear(perform: setupReading)
    }
    
    private func setupReading() {
        editingReading.numericValue = odometerReading.reading
    }
    
    private func saveReading() {
        odometerReading.reading = editingReading.numericValue
        ignoreErrors {
            try viewContext.save()
        }
        onSave()
    }
}

struct OdometerReadingView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            OdometerReadingView(odometerReading: PersistenceController.preview.fixtures.odometerReading) {}
        }
    }
}
