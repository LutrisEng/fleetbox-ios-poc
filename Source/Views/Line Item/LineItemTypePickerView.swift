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

struct LineItemTypePickerView: View {
    @Environment(\.dismiss) var dismiss

    let action: (LineItemType) -> Void
    @State private var searchQuery: String = ""

    var body: some View {
        List(searchResults, children: \.children) { item in
            switch item {
            case .type(let type):
                Button(action: {
                    action(type)
                    dismiss()
                }, label: {
                    LineItemTypeLabelView(type: type, descriptionFont: .caption) {}
                })
            case .category(let category, _, _):
                HStack {
                    Image(systemName: category.icon)
                            .frame(width: 30, alignment: .center)
                    Text(category.displayName)
                    Spacer()
                }
            }
        }
        .searchable(text: $searchQuery, placement: .toolbar)
    }

    private var searchResults: [LineItemTypeHierarchyItem] {
        if searchQuery == "" {
            return lineItemTypes.hierarchyItems
        } else {
            return lineItemTypes.search(query: searchQuery)
        }
    }
}

struct LineItemTypePickerView_Previews: PreviewProvider {
    static var previews: some View {
        LineItemTypePickerView {
            print($0.displayName)
        }
    }
}
