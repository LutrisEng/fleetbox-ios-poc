//
//  LineItemLabelView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
//

import SwiftUI

struct LineItemLabelView: View {
    @ObservedObject var lineItem: LineItem
    var showDetails: Bool = false
    var itemFont: Font = .body
    var detailFont: Font = .caption
    var iconWidth: CGFloat? = 30
    var iconHeight: CGFloat? = nil

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
            LineItemTypeLabelView(type: lineItem.type, font: itemFont, iconWidth: iconWidth, iconHeight: iconHeight)
            if showDetails {
                ForEach(lineItem.fields) { field in
                    LineItemFieldLabelView(field: field, font: detailFont)
                }
                        .padding(EdgeInsets(top: 0, leading: (iconWidth ?? 0) + 30, bottom: 0, trailing: 0))
            }
        }
    }
}

struct LineItemLabelView_Previews: PreviewProvider {
    static var previews: some View {
        return Group {
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
