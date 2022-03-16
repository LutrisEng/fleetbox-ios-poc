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
