//
//  LineItemTypeLabelView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/11/22.
//

import SwiftUI

struct LineItemTypeLabelView<Content: View>: View {
    let type: LineItemType?
    let font: Font
    let descriptionFont: Font?
    let descriptionColor: Color?
    let iconWidth: CGFloat?
    let iconHeight: CGFloat?
    let details: () -> Content

    init(
        type: LineItemType?,
        font: Font = .body,
        descriptionFont: Font? = nil,
        descriptionColor: Color? = nil,
        iconWidth: CGFloat? = 30,
        iconHeight: CGFloat? = nil,
        @ViewBuilder details: @escaping () -> Content
    ) {
        self.type = type
        self.font = font
        self.descriptionFont = descriptionFont
        self.descriptionColor = descriptionColor
        self.iconWidth = iconWidth
        self.iconHeight = iconHeight
        self.details = details
    }

    var body: some View {
        HStack {
            Image(systemName: type?.icon ?? "wrench.and.screwdriver")
                    .frame(width: iconWidth, height: iconHeight, alignment: .center)
            VStack {
                Text(type?.displayName ?? "Unknown line item")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .minimumScaleFactor(font == .body ? 0.5 : 1)
                        .font(font)
                if let descriptionFont = descriptionFont, let description = type?.description {
                    Text(description)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(descriptionFont)
                        .foregroundColor(descriptionColor)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if let details = details {
                    details()
                }
            }
            Spacer()
        }
    }
}
