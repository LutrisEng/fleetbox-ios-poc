//
//  PreviewWrapper.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import SwiftUI

struct PreviewWrapper<Content: View>: View {
    let content: () -> Content
    
    var body: some View {
        NavigationView {
            #if targetEnvironment(macCatalyst)
            EmptyView()
            #endif
            content()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
    }
}
