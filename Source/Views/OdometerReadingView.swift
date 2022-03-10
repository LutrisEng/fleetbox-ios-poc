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
    
    class NumbersOnly: ObservableObject {
        @Published var value = "0" {
            didSet {
                let filtered = value.filter { $0.isNumber }
                if value != filtered {
                    value = filtered
                }
            }
        }
        
        var numericValue: Int64 {
            get {
                Int64(value)!
            }
            
            set(newValue) {
                value = String(newValue)
            }
        }
    }
    
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
        try? viewContext.save()
        onSave()
    }
}

struct OdometerReadingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OdometerReadingView(odometerReading: PersistenceController.preview.fixtures.odometerReading) {}
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
