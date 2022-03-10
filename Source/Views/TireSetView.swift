//
//  TireSetView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import SwiftUI

struct TireSetView: View {
    @ObservedObject var tireSet: TireSet
    
    var body: some View {
        Text(tireSet.displayName)
            .navigationTitle(tireSet.displayName)
    }
}

struct TireSetView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper {
            TireSetView(tireSet: PersistenceController.preview.fixtures.tireSet)
        }
    }
}
