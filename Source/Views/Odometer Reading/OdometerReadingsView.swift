//
//  OdometerReadingsView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct OdometerReadingsView: View {
    @ObservedObject var vehicle: Vehicle

    var body: some View {
        List {
            ForEach(vehicle.odometerReadingsInverseChrono, id: \.self) { odometerReading in
                NavigationLink(odometerReading.at?.formatted() ?? "Odometer reading") {
                    OdometerReadingView(odometerReading: odometerReading)
                }
            }
        }
    }
}

struct OdometerReadingsView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            OdometerReadingsView(vehicle: fixtures.vehicle)
        }
    }
}
