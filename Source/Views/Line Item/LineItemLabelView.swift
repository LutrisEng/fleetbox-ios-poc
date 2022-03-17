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

struct LineItemLabelView: View {
    @ObservedObject var lineItem: LineItem
    var showDetails: Bool = false
    var itemFont: Font = .body
    var detailFont: Font = .caption
    var iconWidth: CGFloat? = 30
    var iconHeight: CGFloat?

    var details: LineItemLabelView {
        var newView = self
        newView.showDetails = true
        return newView
    }

    func font(item: Font? = nil, detail: Font? = nil) -> LineItemLabelView {
        var newView = self
        if let item = item {
            newView.itemFont = item
        }
        if let detail = detail {
            newView.detailFont = detail
        }
        return newView
    }

    func iconFrame(width: CGFloat?, height: CGFloat?) -> LineItemLabelView {
        var newView = self
        newView.iconWidth = width
        newView.iconHeight = height
        return newView
    }

    var mini: LineItemLabelView {
        font(item: .caption)
                .iconFrame(width: 12.5, height: 12.5)
    }

    var body: some View {
        VStack {
            LineItemTypeLabelView(
                type: lineItem.type,
                font: itemFont,
                descriptionFont: detailFont,
                descriptionColor: .gray,
                iconWidth: iconWidth,
                iconHeight: iconHeight
            ) {
                ForEach(showDetails ? lineItem.fields : []) { field in
                    LineItemFieldLabelView(field: field, font: detailFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
    }
}

#if DEBUG
struct LineItemLabelView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PreviewWrapper { fixtures in
                List {
                    ForEach(fixtures.logItem.lineItems) { lineItem in
                        LineItemLabelView(lineItem: lineItem)
                    }
                }
            }
            PreviewWrapper { fixtures in
                List {
                    ForEach(fixtures.logItem.lineItems) { lineItem in
                        LineItemLabelView(lineItem: lineItem).details
                    }
                }
            }
            PreviewWrapper { fixtures in
                List {
                    ForEach(fixtures.logItem.lineItems) { lineItem in
                        LineItemLabelView(lineItem: lineItem).mini
                    }
                }
            }
        }
    }
}
#endif
