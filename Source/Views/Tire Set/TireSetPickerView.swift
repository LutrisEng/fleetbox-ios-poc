//
//  TireSetPickerView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct TireSetPickerView: View {
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \TireSet.sortOrder, ascending: true)],
            animation: .default)
    private var tireSets: FetchedResults<TireSet>

    let selected: TireSet?
    let action: (TireSet?) -> ()

    var body: some View {
        NavigationView {
            List {
                Button(action: { action(nil) }) {
                    HStack {
                        Text("None")
                                .foregroundColor(.primary)
                        if selected == nil {
                            Spacer()
                            Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                        }
                    }
                }
                ForEach(tireSets, id: \.self) { tireSet in
                    Button(action: { action(tireSet) }) {
                        HStack {
                            Text(tireSet.displayName)
                                    .foregroundColor(.primary)
                            if selected == tireSet {
                                Spacer()
                                Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                            }
                        }
                    }
                }
            }
                    .navigationTitle("Tire sets")
        }
    }
}

struct TireSetPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { fixtures in
            TireSetPickerView(selected: nil) {
                print($0?.displayName ?? "None")
            }
        }
    }
}
