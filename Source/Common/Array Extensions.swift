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

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

extension Sequence where Iterator.Element: Dated {
    var chrono: [Iterator.Element] {
        return sorted { ($0.at ?? Date.distantPast) < ($1.at ?? Date.distantPast) }
    }

    var inverseChrono: [Iterator.Element] {
        return sorted { ($0.at ?? Date.distantPast) > ($1.at ?? Date.distantPast) }
    }

    func first(before: Date) -> Iterator.Element? {
        return inverseChrono.first { ($0.at ?? Date.distantFuture) < before }
    }

    func first(after: Date) -> Iterator.Element? {
        return chrono.first { ($0.at ?? Date.distantFuture) > after }
    }
}

extension Sequence where Iterator.Element: Sortable {
    var sorted: [Iterator.Element] {
        return sorted { $0.sortOrder < $1.sortOrder }
    }

    func fixSortOrder() -> Self {
        var arr = sorted
        for index in 0..<arr.count {
            arr[index].sortOrder = Int16(index)
        }
        return self
    }

    var nextSortOrder: Int16 {
        (map(\.sortOrder).max() ?? -1) + 1
    }
}

extension Array where Array.Element: Sortable {
    mutating func setSortOrder() {
        for index in 0..<count {
            self[index].sortOrder = Int16(index)
        }
    }
}
