//
//  LineItemPickerView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct LineItemTypePickerView: View {
    let action: (LineItemType) -> Void

    var body: some View {
        List(lineItemTypes.hierarchyItems, children: \.children) { item in
            switch item {
            case .type(let type):
                Button(action: { action(type) }, label: {
                    LineItemTypeLabelView(type: type)
                })
            case .category(let category):
                HStack {
                    Image(systemName: category.icon)
                            .frame(width: 30, alignment: .center)
                    Text(category.displayName)
                    Spacer()
                }
            }
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
