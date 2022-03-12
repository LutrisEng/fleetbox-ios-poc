//
//  LineItemFieldLabelView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
//

import SwiftUI

struct LineItemFieldLabelView: View {
    @ObservedObject var field: LineItemField
    let font: Font

    var body: some View {
        if let type = field.type {
            if let value = field.displayValue {
                Text("\(type.shortDisplayName): \(value)")
                        .font(font)
                        .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
