//
//  LineItemPickerView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct LineItemTypePickerView: View {
    let action: (LineItemType) -> ()
    
    var body: some View {
        List(lineItemTypes.hierarchyItems, children: \.children) { item in
            switch item {
            case .type(let t):
                Button(action: { action(t) }) {
                    LineItemTypeLabelView(type: t)
                }
            case .category(let c):
                HStack {
                    Image(systemName: c.icon)
                        .frame(width: 30, alignment: .center)
                    Text(c.displayName)
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
