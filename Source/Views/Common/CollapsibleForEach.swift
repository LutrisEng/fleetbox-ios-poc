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

struct CollapsibleForEach<T: NSManagedObject & Sortable, V: View>: View {
    @Environment(\.editMode) private var editMode

    let objects: [T]
    let content: (T) -> V

    private var _onMove: () -> Void = {}

    init(_ objects: [T], @ViewBuilder content: @escaping (T) -> V) {
        self.objects = objects
        self.content = content
    }

    func onMove(_ callback: @escaping () -> Void) -> Self {
        var view = self
        view._onMove = callback
        return view
    }

    @State private var collapsed = true

    var collapsible: Bool {
        objects.count > 3 && editMode?.wrappedValue.isEditing != true
    }

    @ViewBuilder func list(objects: [T], allowMove: Bool) -> some View {
        ForEachObjects(objects, allowMove: allowMove, content: content)
            .onMove(_onMove)
    }

    @ViewBuilder var allObjects: some View {
        list(objects: objects, allowMove: true)
    }

    var buttonContent: LocalizedStringKey {
        if collapsed {
            return "\(Image(systemName: "eye")) Show all (showing 3 of \(objects.count))"
        } else {
            return "\(Image(systemName: "eye.slash")) Show fewer"
        }
    }

    var body: some View {
        if collapsible {
            if collapsed {
                list(objects: Array(objects[0...2]), allowMove: false)
            } else {
                allObjects
            }
            Button(buttonContent) {
                withAnimation {
                    collapsed.toggle()
                }
            }
        } else {
            allObjects
        }
    }
}
