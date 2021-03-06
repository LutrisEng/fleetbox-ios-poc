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

#if DEBUG
import SwiftUI

struct PreviewWrapper<Content: View>: View {
    var navigation = true
    let content: (PersistenceController.Fixtures) -> Content

    func withoutNavigation() -> PreviewWrapper<Content> {
        var view = self
        view.navigation = false
        return view
    }

    var body: some View {
        if navigation {
            EnsureNavigationView {
                #if targetEnvironment(macCatalyst)
                EmptyView()
                #endif
                content(PersistenceController.preview.fixtures)
            }
            .forceRoot()
            .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
        } else {
            content(PersistenceController.preview.fixtures)
                .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
        }
    }
}
#endif
