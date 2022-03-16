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
import Sentry

#if DEBUG
let debug = true
#else
let debug = false
#endif

func getInfoDictionaryKey(key: String) -> String {
    Bundle.main.object(forInfoDictionaryKey: key) as? String ?? "unknown"
}

func getSentryRelease() -> String {
    let package = getInfoDictionaryKey(key: "CFBundleIdentifier")
    let version = getInfoDictionaryKey(key: "CFBundleShortVersionString")
    let buildIdentifier = getInfoDictionaryKey(key: "CFBundleVersion")
    let debugPart = debug ? "-debug" : ""
    return "\(package)@\(version)+\(buildIdentifier)\(debugPart)"
}

struct FleetboxAppMainWindow: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var viewContext

    var body: some View {
        TabView {
            VehiclesView()
                    .tabItem {
                        Image(systemName: "car.2")
                        Text("Vehicles")
                    }
            TireSetsView()
                    .tabItem {
                        Image(systemName: "circle.circle")
                        Text("Tire sets")
                    }
            ShopsView()
                    .tabItem {
                        Image(systemName: "building.2")
                        Text("Shops")
                    }
            AboutView()
                    .tabItem {
                        Image(systemName: "info.circle")
                        Text("About")
                    }
        }
            .onChange(of: scenePhase) { _ in
                ignoreErrors {
                    try viewContext.save()
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification),
                perform: { _ in
                    ignoreErrors {
                        try viewContext.save()
                    }
                }
            )
    }
}

@main
struct FleetboxApp: App {

    let persistenceController = PersistenceController.shared

    init() {
        SentrySDK.start { options in
            options.dsn = "https://2d3e25e0c99347c3b8bd0a3a8908bcdd@o1155807.ingest.sentry.io/6236540"
            options.tracesSampleRate = 1.0
            options.releaseName = getSentryRelease()
            options.enableFileIOTracking = true
            options.enableAutoPerformanceTracking = true
            options.debug = debug
        }
    }

    var body: some Scene {
        WindowGroup {
            FleetboxAppMainWindow()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
