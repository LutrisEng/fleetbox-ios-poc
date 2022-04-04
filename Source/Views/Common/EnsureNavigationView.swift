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

struct InsideInternalNavigationViewKey: EnvironmentKey {
    static let defaultValue = false
}

struct InsideRootNavigationViewKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var insideRootNavigationView: Bool {
        get { self[InsideRootNavigationViewKey.self] }
        set { self[InsideRootNavigationViewKey.self] = newValue }
    }

    var insideInternalNavigationView: Bool {
        get { self[InsideInternalNavigationViewKey.self] }
        set { self[InsideInternalNavigationViewKey.self] = newValue }
    }
}

struct EnsureNavigationView<Content: View>: View {
    @Environment(\.insideInternalNavigationView) private var insideInternalNavigationView
    @Environment(\.insideRootNavigationView) private var insideRootNavigationView

    private var _forceRoot = false
    private var _forceStack = false

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    func forceRoot() -> Self {
        var view = self
        view._forceRoot = true
        return view
    }

    func forceStack() -> Self {
        var view = self
        view._forceStack = true
        return view
    }

    func insideSheet() -> Self {
        forceRoot().forceStack()
    }

    private let columnIdioms: Set<UIUserInterfaceIdiom> = [
        UIUserInterfaceIdiom.pad,
        UIUserInterfaceIdiom.mac
    ]

    @ViewBuilder private var stackNavigationView: some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(.stack)
    }

    @ViewBuilder private var columnNavigationView: some View {
        NavigationView {
            content()
        }
        .navigationViewStyle(.columns)
    }

    private var columnRoot: Bool {
        !_forceStack && columnIdioms.contains(UIDevice.current.userInterfaceIdiom)
    }

    @ViewBuilder private var rootNavigationView: some View {
        if columnRoot {
            columnNavigationView
                .environment(\.insideRootNavigationView, true)
        } else {
            stackNavigationView
                .environment(\.insideRootNavigationView, true)
        }
    }

    @ViewBuilder private var internalNavigationView: some View {
        if columnRoot {
            stackNavigationView
                .navigationBarHidden(true)
                .environment(\.insideInternalNavigationView, true)
        } else {
            content()
                .environment(\.insideInternalNavigationView, true)
        }
    }

    var body: some View {
        if _forceRoot {
            rootNavigationView
                .environment(\.insideInternalNavigationView, false)
        } else if insideRootNavigationView && !insideInternalNavigationView {
            internalNavigationView
        } else if !insideRootNavigationView {
            rootNavigationView
        }
    }
}
