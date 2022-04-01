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

struct ForEachObjects<T: NSManagedObject & Sortable, V: View>: View {
    @Environment(\.managedObjectContext) private var viewContext

    let objects: [T]
    var changeCallback: (() -> Void)?
    let allowDelete: Bool
    let allowMove: Bool
    let content: (T) -> V

    init(_ objects: [T], allowDelete: Bool, allowMove: Bool, content: @escaping (T) -> V) {
        self.objects = objects
        self.allowDelete = allowDelete
        self.allowMove = allowMove
        self.content = content
    }

    init(_ objects: [T], content: @escaping (T) -> V) {
        self.init(objects, allowDelete: true, allowMove: true, content: content)
    }

    init(_ objects: [T], allowDelete: Bool, content: @escaping (T) -> V) {
        self.init(objects, allowDelete: allowDelete, allowMove: true, content: content)
    }

    init(_ objects: [T], allowMove: Bool, content: @escaping (T) -> V) {
        self.init(objects, allowDelete: true, allowMove: allowMove, content: content)
    }

    func onMove(_ callback: @escaping () -> Void) -> Self {
        var view = self
        view.changeCallback = callback
        return view
    }

    func addOnDelete<T: DynamicViewContent>(_ view: T) -> some DynamicViewContent {
        view.onDelete(deleteFrom: objects, context: viewContext)
    }

    func addOnMove<T: DynamicViewContent>(_ view: T) -> some DynamicViewContent {
        view.onMove(moveIn: objects, callback: changeCallback)
    }

    var body: some View {
        let baseView = ForEach<[T], T, V>(objects, id: \.self, content: content)
        if allowDelete {
            let deletableView = addOnDelete(baseView)
            if allowMove {
                addOnMove(deletableView)
            } else {
                deletableView
            }
        } else if allowMove {
            addOnMove(baseView)
        } else {
            baseView
        }
    }
}
