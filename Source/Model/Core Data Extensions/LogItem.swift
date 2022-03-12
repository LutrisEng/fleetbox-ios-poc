//
//  LogItem.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/2/22.
//

import Foundation
import CoreData

extension LogItem {
    var lineItemsUnordered: Set<LineItem> {
        lineItemsNs as? Set<LineItem> ?? []
    }

    var lineItems: [LineItem] {
        lineItemsUnordered.sorted {
            $0.sortOrder < $1.sortOrder
        }
    }

    var attachmentsUnordered: Set<Attachment> {
        attachmentsNs as? Set<Attachment> ?? []
    }

    var attachments: [Attachment] {
        attachmentsUnordered.sorted {
            $0.sortOrder < $1.sortOrder
        }
    }

    var formattedDate: String? {
        if let date = performedAt {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("dd MMMM YYYY")
            return formatter.string(from: date)
        } else {
            return nil
        }
    }

    func fixLineItemSortOrder() {
        var counter: Int16 = 0
        for lineItem in lineItems {
            lineItem.sortOrder = counter
            counter += 1
        }
    }

    var nextLineItemSortOrder: Int16 {
        (lineItems.map(\.sortOrder).max() ?? -1) + 1
    }

    var addedTireSets: [TireSet] {
        lineItems.compactMap { lineItem in
            lineItem.typeId == "mountedTires"
                    ? (ignoreErrors {
                try lineItem.getFieldValueTireSet("tireSet")
            } ?? nil)
                    : nil
        }
    }

    var removedTireSets: [TireSet] {
        lineItems.compactMap { lineItem in
            lineItem.typeId == "dismountedTires"
                    ? (ignoreErrors {
                try lineItem.getFieldValueTireSet("tireSet")
            } ?? nil)
                    : nil
        }
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        vehicle?.objectWillChange.send()
    }
}
