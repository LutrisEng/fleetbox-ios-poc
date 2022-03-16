//
//  LineItemPickerView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

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
