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

enum ImportError: Error {
    case invalidData
}

struct FleetboxAppMainWindow: View {
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.colorScheme) var colorScheme

    struct PreviewImportState {
        let url: URL
        let vehicle: Vehicle
        let persistence: PersistenceController
    }

    @State private var previewImportState: PreviewImportState?
    @State private var showPreview: Bool = false
    @State private var previewError: Bool = false
    @State private var importing: Bool = false

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
        .sheet(isPresented: $showPreview) {
            if previewError {
                Text("An error occurred opening this file.")
            } else if let previewImportState = previewImportState {
                NavigationView {
                    VehicleView(vehicle: previewImportState.vehicle)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarTrailing) {
                                if importing {
                                    ProgressView()
                                } else {
                                    Button(action: importPreview) {
                                        Label("Import vehicle", systemImage: "square.and.arrow.down")
                                    }
                                }
                            }
                        }
                }
                .environment(\.managedObjectContext, previewImportState.persistence.container.viewContext)
                .environment(\.editable, false)
                .deleteDisabled(true)
                .moveDisabled(true)
            } else {
                ProgressView()
            }
        }
        .onOpenURL { url in
            showPreview = true
            previewImportState = nil
            let persistence = PersistenceController(inMemory: true)
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let gzipped = try Data(contentsOf: url)
                    let json = gzipped.isGzipped ? try gzipped.gunzipped() : gzipped
                    guard let vehicle = try Vehicle.importData(json, context: persistence.container.viewContext) else {
                        throw ImportError.invalidData
                    }
                    DispatchQueue.main.async {
                        previewImportState = PreviewImportState(
                            url: url,
                            vehicle: vehicle,
                            persistence: persistence
                        )
                    }
                } catch {
                    SentrySDK.capture(error: error)
                    print(error)
                    DispatchQueue.main.async {
                        previewError = true
                    }
                }
            }
        }
    }

    private func importPreview() {
        if let previewImportState = previewImportState {
            importing = true
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let gzipped = try Data(contentsOf: previewImportState.url)
                    let json = gzipped.isGzipped ? try gzipped.gunzipped() : gzipped
                    DispatchQueue.main.async {
                        withAnimation {
                            do {
                                _ = try Vehicle.importData(json, context: viewContext)
                                try viewContext.save()
                            } catch {
                                SentrySDK.capture(error: error)
                            }
                            self.previewImportState = nil
                            previewError = false
                            showPreview = false
                            importing = false
                        }
                    }
                } catch {
                    SentrySDK.capture(error: error)
                    importing = false
                }
            }
        }
    }
}

@main
struct FleetboxApp: App {

    let persistenceController = PersistenceController.shared

    init() {
        #if !DEBUG
        SentrySDK.start { options in
            options.dsn = "https://2d3e25e0c99347c3b8bd0a3a8908bcdd@o1155807.ingest.sentry.io/6236540"
            options.tracesSampleRate = 1.0
            options.releaseName = getSentryRelease()
            options.enableFileIOTracking = true
            options.enableAutoPerformanceTracking = true
            options.debug = debug
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            FleetboxAppMainWindow()
                // Sometimes SwiftUI decides not to apply the accent color from the bundle
                .accentColor(Color(debug ? "AccentColor-Debug" : "AccentColor"))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .navigationViewStyle(.columns)
        }
    }
}
