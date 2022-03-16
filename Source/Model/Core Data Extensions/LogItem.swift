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
