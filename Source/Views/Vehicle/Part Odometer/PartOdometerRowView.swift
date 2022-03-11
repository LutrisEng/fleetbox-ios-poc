//
//  OdometerReadingRowView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct PartOdometerRowView: View {
    let name: String
    let reading: Int64
    
    var body: some View {
        HStack {
            Text(LocalizedStringKey(name))
            Spacer()
            Text("\(reading) miles")
                .foregroundColor(.secondary)
        }
    }
}

struct PartOdometerRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            PartOdometerRowView(name: "Vehicle", reading: 1000)
        }
    }
}
