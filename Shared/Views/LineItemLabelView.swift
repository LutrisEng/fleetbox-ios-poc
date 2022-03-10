//
//  LineItemLabelView.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/9/22.
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

struct LineItemLabelView: View {
    @ObservedObject var lineItem: LineItem
    var showDetails: Bool = false
    var itemFont: Font = .body
    var detailFont: Font = .caption
    var iconWidth: CGFloat? = 30
    var iconHeight: CGFloat? = nil
    
    func details() -> LineItemLabelView {
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
                }.padding(EdgeInsets(top: 0, leading: (iconWidth ?? 0) + 30, bottom: 0, trailing: 0))
            }
        }
    }
}

struct LineItemLabelView_Previews: PreviewProvider {
    static var previews: some View {
        let lineItems = PersistenceController.preview.fixtures.logItem.lineItems
        return Group {
            List {
                ForEach(lineItems) { lineItem in
                    LineItemLabelView(lineItem: lineItem)
                }
            }
            List {
                ForEach(lineItems) { lineItem in
                    LineItemLabelView(lineItem: lineItem).details()
                }
            }
            List {
                VStack {
                    ForEach(lineItems) { lineItem in
                        LineItemLabelView(lineItem: lineItem).mini
                    }
                }
            }
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
