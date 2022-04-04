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
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification),
            perform: { _ in
                FileManager.default.clearTmpDirectory()
            }
        )
        .sheet(isPresented: $showPreview) {
            if previewError {
                Text("An error occurred opening this file.")
            } else if let previewImportState = previewImportState {
                EnsureNavigationView {
                    VehicleView(vehicle: previewImportState.vehicle)
                        .toolbar {
                            ToolbarItemGroup(placement: .navigationBarLeading) {
                                Button(action: cancelPreview) {
                                    Label("Close preview", systemImage: "xmark")
                                }
                            }
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
                .insideSheet()
                .environment(\.managedObjectContext, previewImportState.persistence.container.viewContext)
                .modifier(NotEditable())
            } else {
                ProgressView()
            }
        }
        .onOpenURL { url in
            showPreview = true
            previewImportState = nil
            let persistence = PersistenceController(inMemory: true)
            _ = url.startAccessingSecurityScopedResource()
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let gzipped = try Data(contentsOf: url)
                    let json = gzipped.isGzipped ? try gzipped.gunzipped() : gzipped
                    guard let vehicle = try Vehicle.importData(json, context: persistence.container.viewContext) else {
                        throw ImportError.invalidData
                    }
                    DispatchQueue.main.async {
                        url.stopAccessingSecurityScopedResource()
                        previewImportState = PreviewImportState(
                            url: url,
                            vehicle: vehicle,
                            persistence: persistence
                        )
                    }
                } catch {
                    SentrySDK.capture(error: error)
                    print("error importing", error)
                    DispatchQueue.main.async {
                        url.stopAccessingSecurityScopedResource()
                        previewError = true
                    }
                }
            }
        }
    }

    private func cancelPreview() {
        withAnimation {
            previewError = false
            showPreview = false
            importing = false
            previewImportState = nil
        }
    }

    private func importPreview() {
        if let previewImportState = previewImportState {
            importing = true
            _ = previewImportState.url.startAccessingSecurityScopedResource()
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
                            previewImportState.url.stopAccessingSecurityScopedResource()
                            self.previewImportState = nil
                            previewError = false
                            showPreview = false
                            importing = false
                        }
                    }
                } catch {
                    SentrySDK.capture(error: error)
                    print("import error", error)
                    DispatchQueue.main.async {
                        previewImportState.url.stopAccessingSecurityScopedResource()
                        importing = false
                    }
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
                .onAppear {
                    let window = UIApplication
                        .shared
                        .connectedScenes
                        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                        .first { $0.isKeyWindow }
                    let tint = UIColor(named: debug ? "AccentColor-Debug" : "AccentColor")
                    window?.tintColor = tint
                }
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .navigationViewStyle(.columns)
        }
    }
}
