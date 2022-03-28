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
    var showCategories = true

    var details: LineItemLabelView {
        var view = self
        view.showDetails = true
        return view
    }

    func font(item: Font? = nil, detail: Font? = nil) -> LineItemLabelView {
        var view = self
        if let item = item {
            view.itemFont = item
        }
        if let detail = detail {
            view.detailFont = detail
        }
        return view
    }

    func iconFrame(width: CGFloat?, height: CGFloat?) -> LineItemLabelView {
        var view = self
        view.iconWidth = width
        view.iconHeight = height
        return view
    }

    var withoutCategories: Self {
        var view = self
        view.showCategories = false
        return view
    }

    var mini: Self {
        font(item: .caption)
            .iconFrame(width: 12.5, height: 12.5)
            .withoutCategories
    }

    var body: some View {
        VStack {
            LineItemTypeLabelView(
                type: lineItem.type,
                font: itemFont,
                descriptionFont: detailFont,
                descriptionColor: .secondary,
                iconWidth: iconWidth,
                iconHeight: iconHeight,
                showCategories: showCategories
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
                    ForEach(fixtures.logItem.lineItems.sorted) { lineItem in
                        LineItemLabelView(lineItem: lineItem)
                    }
                }
            }
            PreviewWrapper { fixtures in
                List {
                    ForEach(fixtures.logItem.lineItems.sorted) { lineItem in
                        LineItemLabelView(lineItem: lineItem).details
                    }
                }
            }
            PreviewWrapper { fixtures in
                List {
                    ForEach(fixtures.logItem.lineItems.sorted) { lineItem in
                        LineItemLabelView(lineItem: lineItem).mini
                    }
                }
            }
        }
    }
}
#endif
