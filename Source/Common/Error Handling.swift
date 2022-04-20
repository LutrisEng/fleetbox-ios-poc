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

import Foundation
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

func initSentry() {
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

func sentryCapture(error: Error) {
    print("Captured error: ", error)
    SentrySDK.capture(error: error)
}

func sentryCapture(message: String) {
    print("Captured error message: ", message)
    SentrySDK.capture(message: message)
}

func ignoreErrorsImpl<T>(_ closure: () throws -> T) -> T? {
    do {
        return try closure()
    } catch {
        sentryCapture(error: error)
        return nil
    }
}

func ignoreErrors<T>(_ closure: () throws -> T) -> T? {
    ignoreErrorsImpl(closure)
}

func ignoreErrors<T>(_ closure: () throws -> T?) -> T? {
    ignoreErrorsImpl(closure) ?? nil
}

func ignoreErrorsImpl<T>(_ asyncClosure: () async throws -> T) async -> T? {
    do {
        return try await asyncClosure()
    } catch {
        sentryCapture(error: error)
        return nil
    }
}

func ignoreErrors<T>(_ asyncClosure: () async throws -> T) async -> T? {
    await ignoreErrorsImpl(asyncClosure)
}

func ignoreErrors<T>(_ asyncClosure: () async throws -> T?) async -> T? {
    await ignoreErrorsImpl(asyncClosure) ?? nil
}
