//
//  NumbersOnly.swift
//  Fleetbox
//
//  Created by Piper McCorkle on 3/10/22.
//

import Foundation
import SwiftUI

class NumbersOnly: ObservableObject {
    @Published var value = "0" {
        didSet {
            let filtered = value.filter {
                $0.isNumber
            }
            if value != filtered {
                value = filtered
            }
        }
    }

    var numericValue: Int64 {
        get {
            Int64(value)!
        }

        set(newValue) {
            value = String(newValue)
        }
    }
}

func convertToStringBinding(int64: Binding<Int64>) -> Binding<String> {
    Binding<String>(
            get: { String(int64.wrappedValue) },
            set: { value in
                let filtered = value.filter {
                    $0.isNumber
                }
                int64.wrappedValue = Int64(filtered) ?? 0
            }
    )
}

func convertToNillableBinding(string: Binding<String>) -> Binding<String?> {
    Binding<String?>(
            get: { string.wrappedValue },
            set: { value in
                string.wrappedValue = value ?? ""
            }
    )
}

func convertToNonNilBinding(date: Binding<Date?>) -> Binding<Date> {
    Binding<Date>(
            get: { date.wrappedValue ?? Date.distantPast },
            set: { value in
                date.wrappedValue = value
            }
    )
}

func convertToNonNilBinding(string: Binding<String?>) -> Binding<String> {
    Binding<String>(
            get: { string.wrappedValue ?? "" },
            set: { value in
                string.wrappedValue = value
            }
    )
}
