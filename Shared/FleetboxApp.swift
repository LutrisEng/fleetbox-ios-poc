//
//  FleetboxApp.swift
//  Shared
//
//  Created by Piper McCorkle on 2/28/22.
//

import SwiftUI

@main
struct FleetboxApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
