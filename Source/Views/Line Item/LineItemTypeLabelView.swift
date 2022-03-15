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
    let descriptionFont: Font?
    let iconWidth: CGFloat?
    let iconHeight: CGFloat?

    init(type: LineItemType?, font: Font = .body, descriptionFont: Font? = nil, iconWidth: CGFloat? = 30, iconHeight: CGFloat? = nil) {
        self.type = type
        self.font = font
        self.descriptionFont = descriptionFont
        self.iconWidth = iconWidth
        self.iconHeight = iconHeight
    }

    var body: some View {
        HStack {
            Image(systemName: type?.icon ?? "wrench.and.screwdriver")
                    .frame(width: iconWidth, height: iconHeight, alignment: .center)
            VStack {
                Text(type?.displayName ?? "Unknown line item")
                        .font(font)
                        .frame(maxWidth: .infinity, alignment: .leading)
                if let descriptionFont = descriptionFont, let description = type?.description {
                    Text(description)
                        .font(descriptionFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            Spacer()
        }
    }
}
