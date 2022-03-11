//
//  LineItemTypeLabelView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct LineItemTypeLabelView: View {
    let type: LineItemType?
    let font: Font
    let iconWidth: CGFloat?
    let iconHeight: CGFloat?
    
    init(type: LineItemType?, font: Font = .body, iconWidth: CGFloat? = 30, iconHeight: CGFloat? = nil) {
        self.type = type
        self.font = font
        self.iconWidth = iconWidth
        self.iconHeight = iconHeight
    }
    
    var body: some View {
        HStack {
            Image(systemName: type?.icon ?? "wrench.and.screwdriver")
                .frame(width: iconWidth, height: iconHeight, alignment: .center)
            Text(type?.displayName ?? "Unknown line item")
                .font(font)
            Spacer()
        }
    }
}
