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
import CoreData

extension TextField {
    @ViewBuilder func firstResponder() -> some View {
        introspectTextField { textField in
            textField.becomeFirstResponder()
        }
    }
}

extension SecureField {
    @ViewBuilder func firstResponder() -> some View {
        introspectTextField { textField in
            textField.becomeFirstResponder()
        }
    }
}

extension DynamicViewContent {
    func onDelete<T>(deleteFrom: [T], context: NSManagedObjectContext) -> some DynamicViewContent
    where T: NSManagedObject {
        return onDelete { indices in
            withAnimation {
                let objects = indices.map({ deleteFrom[$0] })
                for object in objects {
                    context.delete(object)
                }
            }
        }
    }

    func onMove<T>(moveIn: [T], callback: (() -> Void)?) -> some DynamicViewContent
    where T: Sortable & Hashable {
        return onMove { indices, offset in
            withAnimation {
                var arr = moveIn
                arr.move(fromOffsets: indices, toOffset: offset)
                arr.setSortOrder()
                callback?()
            }
        }
    }
}
