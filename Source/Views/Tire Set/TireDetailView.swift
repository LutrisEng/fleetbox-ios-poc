//
//  TireDetailView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct TireDetailView: View {
    @ObservedObject var tireSet: TireSet

    var body: some View {
        NavigationLink(destination: { TireSetView(tireSet: tireSet) }, label: {
            HStack {
                Text("Tires")
                Spacer()
                Text(tireSet.displayName)
                        .foregroundColor(.secondary)
            }
        })
    }
}

struct TireDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            List {
                TireDetailView(tireSet: fixtures.tireSet)
            }
        }
    }
}
