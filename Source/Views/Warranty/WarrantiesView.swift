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

struct WarrantiesView<
    Underlying: Warranty.Underlying & ObservableObject
>: View {
    @Environment(\.editable) private var editable
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var underlying: Underlying

    @State private var creatingWarranty: Warranty?

    @ViewBuilder
    func list(warranties: [Warranty], allowMove: Bool) -> some View {
        ForEachObjects(warranties, allowMove: allowMove) { warranty in
            WarrantyListingView(warranty: warranty)
        }
    }

    @ViewBuilder
    var addWarranty: some View {
        if editable {
            NavigationLink(
                destination: {
                    NewWarrantyView(underlying: underlying)
                },
                label: {
                    Text("\(Image(systemName: "plus")) Add warranty")
                        .foregroundColor(.accentColor)
                }
            )
        }
    }

    var warranties: [Warranty] {
        underlying.warranties.sorted
    }

    @ViewBuilder
    var allWarranties: some View {
        list(warranties: warranties, allowMove: true)
        addWarranty
    }

    var body: some View {
        Section(header: Text("Warranties")) {
            if warranties.count > 3 {
                list(warranties: Array(warranties[0...2]), allowMove: false)
                NavigationLink("All warranties...") {
                    List {
                        allWarranties
                    }
                    .navigationTitle("Warranties")
                    .modifier(WithEditButton())
                }
                addWarranty
            } else {
                allWarranties
            }
        }
    }
}
