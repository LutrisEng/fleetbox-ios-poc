//
//  Error Handling.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import Sentry

func ignoreErrors<T>(_ closure: () throws -> T) -> T? {
    do {
        return try closure()
    } catch {
        SentrySDK.capture(error: error)
        print("error", error)
        return nil
    }
}

func ignoreErrors<T>(_ asyncClosure: () async throws -> T) async -> T? {
    do {
        return try await asyncClosure()
    } catch {
        SentrySDK.capture(error: error)
        print("error", error)
        return nil
    }
}
