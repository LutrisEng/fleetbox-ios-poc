//
//  PreviewWrapper.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import SwiftUI

struct PreviewWrapper<Content: View>: View {
    var navigation = true
    let content: (PersistenceController.Fixtures) -> Content

    func withoutNavigation() -> PreviewWrapper<Content> {
        var v = self
        v.navigation = false
        return v
    }

    var body: some View {
        if navigation {
            NavigationView {
                #if targetEnvironment(macCatalyst)
                EmptyView()
                #endif
                content(PersistenceController.preview.fixtures)
            }
                    .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
        } else {
            content(PersistenceController.preview.fixtures)
                    .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
        }
    }
}
