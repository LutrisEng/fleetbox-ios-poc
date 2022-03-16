//  SPDX-License-Identifier: GPL-3.0-or-later
//  Fleetbox, a tool for managing vehicle maintenance logs
//  Copyright (C) 2022 Lutris, Inc
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import SwiftUI

struct TireSetPickerView: View {
    @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \TireSet.sortOrder, ascending: true)],
            animation: .default)
    private var tireSets: FetchedResults<TireSet>

    let selected: TireSet?
    let action: (TireSet?) -> Void

    var body: some View {
        NavigationView {
            List {
                Button(action: { action(nil) }, label: {
                    HStack {
                        Text("None")
                                .foregroundColor(.primary)
                        if selected == nil {
                            Spacer()
                            Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                        }
                    }
                })
                ForEach(tireSets, id: \.self) { tireSet in
                    Button(action: { action(tireSet) }, label: {
                        HStack {
                            Text(tireSet.displayName)
                                    .foregroundColor(.primary)
                            if selected == tireSet {
                                Spacer()
                                Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                            }
                        }
                    })
                }
            }
                    .navigationTitle("Tire sets")
        }
    }
}

struct TireSetPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewWrapper { _ in
            TireSetPickerView(selected: nil) {
                print($0?.displayName ?? "None")
            }
        }
    }
}
