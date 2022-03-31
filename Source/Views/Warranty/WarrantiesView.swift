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
    @Environment(\.editMode) private var editMode

    @ObservedObject var underlying: Underlying

    @State private var showingAll: Bool = false

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
                        .onAppear {
                            withAnimation {
                                showingAll = true
                            }
                        }
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
    }

    var buttonContent: LocalizedStringKey {
        if showingAll {
            return "\(Image(systemName: "square.3.stack.3d.slash")) Show fewer"
        } else {
            return "\(Image(systemName: "square.3.stack.3d")) Show all"
        }
    }

    var body: some View {
        Section(header: Text("Warranties")) {
            if warranties.count > 3 && editMode?.wrappedValue.isEditing != true {
                if showingAll {
                    allWarranties
                } else {
                    list(warranties: Array(warranties[0...2]), allowMove: false)
                }
                Button(buttonContent) {
                    withAnimation {
                        showingAll.toggle()
                    }
                }
            } else {
                allWarranties
            }
            addWarranty
        }
    }
}
