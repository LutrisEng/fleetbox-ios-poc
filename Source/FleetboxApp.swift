//
//  FleetboxApp.swift
//  Shared
//
//  Created by Piper McCorkle on 2/28/22.
//

import SwiftUI
import Sentry

#if DEBUG
    let debug = true
#else
    let debug = false
#endif

func getInfoDictionaryKey(key: String) -> String {
    Bundle.main.object(forInfoDictionaryKey: key) as! String
}

func getSentryRelease() -> String {
    let package = getInfoDictionaryKey(key: "CFBundleIdentifier")
    let version = getInfoDictionaryKey(key: "CFBundleShortVersionString")
    let buildIdentifier = getInfoDictionaryKey(key: "CFBundleVersion")
    return "\(package)@\(version)+\(buildIdentifier)"
}

@main
struct FleetboxApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        if (!debug) {
            SentrySDK.start { options in
                options.dsn = "https://2d3e25e0c99347c3b8bd0a3a8908bcdd@o1155807.ingest.sentry.io/6236540"
                options.tracesSampleRate = 0.5
                options.releaseName = getSentryRelease()
                options.enableFileIOTracking = true
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                VehiclesView()
                    .tabItem {
                        Image(systemName: "car.2")
                        Text("Vehicles")
                    }
                Text("Tire sets")
                    .tabItem {
                        Image(systemName: "circle.circle")
                        Text("Tire sets")
                    }
                Text("Shops")
                    .tabItem {
                        Image(systemName: "building.2")
                        Text("Shops")
                    }
            }
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
