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

extension Shop {
    var logItemsUnordered: Set<LogItem> {
        logItemsNs as? Set<LogItem> ?? []
    }

    var logItemsInverseChrono: [LogItem] {
        logItemsUnordered.sorted {
            ($0.performedAt ?? Date.distantPast) > ($1.performedAt ?? Date.distantPast)
        }
    }

    var vehicles: [Vehicle] {
        logItemsInverseChrono.compactMap({ $0.vehicle }).unique()
    }

    func mergeWith(_ other: Shop) {
        if other == self { return }
        for item in other.logItemsUnordered {
            item.shop = self
        }
        if let context = managedObjectContext {
            context.delete(other)
        }
    }

    override public func willChangeValue(forKey key: String) {
        super.willChangeValue(forKey: key)
        self.objectWillChange.send()
        for logItem in logItemsUnordered {
            logItem.objectWillChange.send()
        }
    }
}
